//
//  MYPDocumentPicker.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 19/09/16.
//
//

@import MobileCoreServices;
@import Foundation;

#import <AVFoundation/AVFoundation.h>
#import "MYPDocumentPicker.h"
#import "MYPConstants.h"
#import "MYPFileUtils.h"

typedef NS_ENUM(NSInteger, MYPDocumentPickerFlow) {
    MYPDocumentPickerFlowImagesOnly = 1,
    MYPDocumentPickerFlowArbitraryDocument
};

static NSArray * _supportedUTIs = nil;

@interface MYPDocumentPicker() <UINavigationControllerDelegate, UIImagePickerControllerDelegate,
UIDocumentMenuDelegate, UIDocumentPickerDelegate>

@property (nonatomic, weak, readwrite) UIViewController *viewController;
@property (nonatomic, assign, readwrite) BOOL croppingEnabled;

@property (nonatomic, strong, readonly) NSArray *supportedUTIs;

@property (nonatomic, assign) MYPDocumentPickerFlow pickerFlow;

@end

@implementation MYPDocumentPicker

- (instancetype)initWithViewController:(UIViewController *)controller cropImages:(BOOL)crop {
    self = [super init];
    if (self) {
        self.viewController = controller;
        self.croppingEnabled = crop;
        self.pickerFlow = MYPDocumentPickerFlowImagesOnly;
    }
    return self;
}

- (instancetype)initWithViewController:(UIViewController *)controller {
    return [self initWithViewController:controller cropImages:NO];
}

- (instancetype)init {
    return [self initWithViewController:nil cropImages:NO];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = self.croppingEnabled ? info[UIImagePickerControllerOriginalImage] : info[UIImagePickerControllerOriginalImage];
    if (self.pickerFlow == MYPDocumentPickerFlowImagesOnly) {
        SEL selector = @selector(documentPicker:didPickImage:);
        if ([self.delegate respondsToSelector:selector]) {
            [self.delegate documentPicker:self didPickImage:image];
        }
        [self.viewController dismissViewControllerAnimated:YES completion:nil];
    } else if (self.pickerFlow == MYPDocumentPickerFlowArbitraryDocument) {
        SEL selector = @selector(documentPicker:didPickDocument:fileName:mimeType:);
        if ([self.delegate respondsToSelector:selector]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *normalizedImage = image.myp_normalizedImage;
                NSData *document = UIImageJPEGRepresentation(normalizedImage, kJPEGDocumentsCompressionQuality);
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *filename = @"document.jpg";
                    NSString *mime = (__bridge NSString *)(UTTypeCopyPreferredTagWithClass(kUTTypeJPEG, kUTTagClassMIMEType));
                    [self.viewController dismissViewControllerAnimated:YES completion:^{
                        [self.delegate documentPicker:self didPickDocument:document fileName:filename mimeType:mime];
                    }];
                });
            });
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIDocumentMenuDelegate

- (void)documentMenu:(UIDocumentMenuViewController *)documentMenu didPickDocumentPicker:(UIDocumentPickerViewController *)documentPicker
{
    documentPicker.delegate = self;
    [self.viewController presentViewController:documentPicker animated:YES completion:nil];
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    SEL selector = @selector(documentPicker:didPickDocument:fileName:mimeType:);
    if ([self.delegate respondsToSelector:selector]) {
        NSError *error;
        NSData *documentData = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
        if (error) {
            NSLog(@"%@", error);
            if ([self.delegate respondsToSelector:@selector(documentPicker:didFailWithError:)]) {
                [self.delegate documentPicker:self didFailWithError:error];
            }
            return;
        }
        
        NSString *fileName = [url lastPathComponent];
        NSString *mimeType = [MYPFileUtils mimeTypeForItemAtURL:url];
        [self.delegate documentPicker:self
                      didPickDocument:documentData
                             fileName:fileName
                             mimeType:mimeType];
    }
}

#pragma mark - Public Methods

- (void)showPickImageAlert:(UIView *)sourceView {
    self.pickerFlow = MYPDocumentPickerFlowImagesOnly;
    UIAlertController *alert = [self pickerAlertWithSourceView:sourceView];
    [self.viewController presentViewController:alert animated:YES completion:nil];
}

- (void)showPickDocumentAlert:(UIView *)sourceView {
    self.pickerFlow = MYPDocumentPickerFlowArbitraryDocument;
    
    UIAlertController *alert = [self pickerAlertWithSourceView:sourceView];
    alert.title = NSLocalizedString(@"Choose file to attach", nil);
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Import File From...", nil)
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       [self importDocumentFromExternalSource:sourceView];
                                                   }];
    [alert addAction:action];
    
    [self.viewController presentViewController:alert animated:YES completion:nil];
}

- (void)pickPhotoFromCamera {
    // http://stackoverflow.com/questions/25803217/presenting-camera-permission-dialog-in-ios-8
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        // Use dispatch_async for any UI updating code because this block may be executed in a thread.
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                [self pickPhotoFromSource:UIImagePickerControllerSourceTypeCamera];
            } else {
                // Permission has been denied. Show a corresponding alert.
                NSString *title = NSLocalizedString(@"Permission denied", nil);
                NSString *msg = NSLocalizedString(@"Please grant MyPlannr access to your Camera in the Settings.", nil);
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                               message:msg
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                 style:UIAlertActionStyleCancel
                                                               handler:nil];
                [alert addAction:action];
                [self.viewController presentViewController:alert animated:YES completion:nil];
            }
        });
    }];
}

- (void)pickPhotoFromLibrary {
    [self pickPhotoFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)importDocumentFromExternalSource:(UIView *)sourceView {
    NSArray *utis = [self supportedUTIs];
    UIDocumentMenuViewController *importMenu = [[UIDocumentMenuViewController alloc] initWithDocumentTypes:utis
                                                                                                    inMode:UIDocumentPickerModeImport];
    importMenu.delegate = self;
    importMenu.popoverPresentationController.sourceRect = sourceView.bounds;
    importMenu.popoverPresentationController.sourceView = sourceView;
    [self.viewController presentViewController:importMenu animated:YES completion:nil];
}

#pragma mark - Private Methods

- (UIAlertController *)pickerAlertWithSourceView:(UIView *)sourceView {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Choose image", nil)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Take Photo", nil)
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       [self pickPhotoFromCamera];
                                                   }];
    BOOL isCameraSupported = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (isCameraSupported) {
        [alert addAction:action];
    }
    
    action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Choose From Library", nil)
                                      style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * _Nonnull action) {
                                        [self pickPhotoFromLibrary];
                                    }];
    [alert addAction:action];
    
    action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                      style:UIAlertActionStyleCancel
                                    handler:nil];
    [alert addAction:action];
    
    UIPopoverPresentationController *popoverController = alert.popoverPresentationController;
    popoverController.sourceView = sourceView;
    popoverController.sourceRect = sourceView.bounds;
    
    // trying to supress annoying "Snapshotting a view that has not been rendered results in an empty snapshot" warnings
    [alert view];
    
    return alert;
}

- (NSArray *)supportedUTIs {
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _supportedUTIs = @[
                           [MYPConstants kUTI_PNG],
                           [MYPConstants kUTI_JPEG],
                           [MYPConstants kUTI_PDF],
                           [MYPConstants kUTI_XLS],
                           [MYPConstants kUTI_XLSX],
                           [MYPConstants kUTI_DOC],
                           [MYPConstants kUTI_DOCX]
                           ];
    
    });
    return _supportedUTIs;
}

- (void)pickPhotoFromSource:(UIImagePickerControllerSourceType)source {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.allowsEditing = self.croppingEnabled;
    pickerController.delegate = self;
    pickerController.sourceType = source;
    if (pickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
        pickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    }
    [self.viewController presentViewController:pickerController animated:YES completion:nil];
}

@end
