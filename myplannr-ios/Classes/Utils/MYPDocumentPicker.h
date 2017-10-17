//
//  MYPDocumentPicker.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 19/09/16.
//
//

@class MYPDocumentPicker;

@protocol MYPDocumentPickerDelegate <NSObject>

@optional

- (void)documentPicker:(MYPDocumentPicker *)picker didPickImage:(UIImage *)image;

- (void)documentPicker:(MYPDocumentPicker *)picker
       didPickDocument:(NSData *)data
              fileName:(NSString *)fileName
              mimeType:(NSString *)mimeType;
- (void)documentPicker:(MYPDocumentPicker *)picker didFailWithError:(NSError *)error;

@end

@interface MYPDocumentPicker : NSObject

@property (nonatomic, weak) id<MYPDocumentPickerDelegate> delegate;

@property (nonatomic, weak, readonly) UIViewController *viewController;
@property (nonatomic, assign, readonly) BOOL croppingEnabled;

- (instancetype)initWithViewController:(UIViewController *)controller cropImages:(BOOL)crop NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithViewController:(UIViewController *)controller;

- (void)showPickImageAlert:(UIView *)sourceView;
- (void)showPickDocumentAlert:(UIView *)sourceView;
- (void)importDocumentFromExternalSource:(UIView *)sourceView;

- (void)pickPhotoFromCamera;
- (void)pickPhotoFromLibrary;

@end
