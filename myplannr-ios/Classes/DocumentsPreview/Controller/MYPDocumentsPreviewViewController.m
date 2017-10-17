//
//  MYPDocumentsPreviewViewController.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 19/10/2016.
//
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "MYPDocumentsPreviewViewController.h"
#import "MYPCenteredFlowLayout.h"
#import "MYPDocumentCell.h"
#import "MYPTabTitleView.h"
#import "MYPFileUtils.h"
#import "MYPService.h"
#import "SVProgressHUD.h"

static NSString * const kDocumentCellReuseIdentifier = @"documentCell";

static CGFloat const kImageViewBorderWidth = 4.0f;
static CGFloat const kImageViewCornerRadius = 4.0f;

@interface MYPDocumentsPreviewViewController () <UICollectionViewDataSource,
                                                 MYPCenteredFlowLayoutDelegate,
                                                 FCCollectionModelDelegate,
                                                 UIDocumentInteractionControllerDelegate>
{
    BOOL _didScrollToInitialPosition;
}

@property (nonatomic, strong) UIDocumentInteractionController *docInteractionController;

@end

@implementation MYPDocumentsPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.model == nil) {
        NSLog(@"%s: model==nil", __PRETTY_FUNCTION__);
    }
    
    self.model.delegate = self;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    
    _didScrollToInitialPosition = NO;
    
    CGFloat height = self.navigationController.navigationBar.frame.size.height;
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), height);
    MYPTabTitleView *titleView = [[MYPTabTitleView alloc] initWithFrame:frame];
    titleView.title = self.model.binderTab.title;
    titleView.color = self.model.binderTab.color;
    self.navigationItem.titleView = titleView;
    
    self.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.imageView.layer.borderWidth = kImageViewBorderWidth;
    self.imageView.layer.cornerRadius = kImageViewCornerRadius;
    
    UINib *nib = [UINib nibWithNibName:@"MYPDocumentCell" bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:kDocumentCellReuseIdentifier];
    
    if (self.model.accessType != MYPAccessTypeFull) {
        self.optionsBarButtonItem.enabled = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.view layoutIfNeeded];
    NSIndexPath *path = [NSIndexPath indexPathForItem:self.selectedDocumentIndex inSection:0];
    [self.collectionView scrollToItemAtIndexPath:path
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:NO];
    _didScrollToInitialPosition = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.model cancelDownloadRequests];
    [SVProgressHUD dismiss];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.model.documentsCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MYPDocumentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kDocumentCellReuseIdentifier
                                                                      forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)interactionController
{
    return self.navigationController;
}

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller {
    self.docInteractionController = nil;
}

#pragma mark - FCCollectionModelDelegate

- (void)model:(id)model didDeleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)paths {
    [self.collectionView deleteItemsAtIndexPaths:paths];
    
    if ([self.delegate respondsToSelector:@selector(documentsPreviewControllerDidModifyDocumentsList:)]) {
        [self.delegate documentsPreviewControllerDidModifyDocumentsList:self];
    }
    
    if (self.model.documentsCount == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - MYPCenteredFlowLayoutDelegate

- (void)collectionView:(UICollectionView *)collectionView
                layout:(UICollectionViewLayout *)collectionViewLayout didCenterItemAtIndexPath:(NSIndexPath *)indexPath
{
    MYPBinderTab *tab = self.model.binderTab;
    MYPDocument *document = tab.documents[indexPath.row];
    [self displayDocument:document];
    if (_didScrollToInitialPosition) {
        self.selectedDocumentIndex = indexPath.row;    
    }
}

#pragma mark - Action handlers

- (IBAction)handleOptionsBarButtonClick:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Share", nil)
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       [self shareSelectedDocument];
                                                   }];
    [alert addAction:action];
    
    action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", nil)
                                      style:UIAlertActionStyleDestructive
                                    handler:^(UIAlertAction * _Nonnull action) {
                                        [self deleteSelectedDocument];
                                    }];
    [alert addAction:action];
    
    action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                      style:UIAlertActionStyleCancel
                                    handler:nil];
    [alert addAction:action];
    
    UIPopoverPresentationController *popoverController = alert.popoverPresentationController;
    popoverController.barButtonItem = sender;
    
    [alert view];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)handleImageViewTapGesture:(UIGestureRecognizer *)sender {
    MYPBinderTab *tab = self.model.binderTab;
    MYPDocument *selectedDocument = tab.documents[self.selectedDocumentIndex];
    if (selectedDocument.isDownloaded) {
        NSURL *url = selectedDocument.downloadedDocumentURL;
        [self setupDocumentControllerWithURL:url];
        [self.docInteractionController presentPreviewAnimated:YES];
    } else {
        self.imageView.userInteractionEnabled = NO;
        self.collectionView.userInteractionEnabled = NO;
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Downloading your Document...", nil)];
        [self.model downloadDocuments:@[selectedDocument] completion:^(NSArray<NSURL *> *fileURLs, NSArray *errors)
         {
             [SVProgressHUD dismiss];
             self.imageView.userInteractionEnabled = YES;
             self.collectionView.userInteractionEnabled = YES;
             
             if (errors.count > 0) {
                 NSLog(@"%s: %@", __PRETTY_FUNCTION__, errors.firstObject);
                 NSString *errorMsg = NSLocalizedString(@"Failed to download the selected Document.", nil);
                 [SVProgressHUD showErrorWithStatus:errorMsg];
                 return;
             }
             
             [self setupDocumentControllerWithURL:fileURLs.firstObject];
             [self.docInteractionController presentPreviewAnimated:YES];
         }];
    }
}

#pragma mark - Private methods

- (void)configureCell:(MYPDocumentCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    MYPBinderTab *tab = self.model.binderTab;
    MYPDocument *document = tab.documents[indexPath.row];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.editing = NO;
    
    NSURL *url = [NSURL URLWithString:document.storagePreviewUrl];
    [cell.imageView sd_setImageWithURL:url];
}

- (void)displayDocument:(MYPDocument *)document {
    NSLayoutConstraint *c1 = self.imageViewAspectRationConstraint;
    __block NSLayoutConstraint *c2 = nil;
    
    if (document.isImage) {
        NSURL *url = [NSURL URLWithString:document.storageUrl];
        CGFloat aspect = (document.imgWidth.floatValue / document.imgHeight.floatValue);
        c2 = [NSLayoutConstraint constraintWithItem:c1.firstItem
                                          attribute:c1.firstAttribute
                                          relatedBy:c1.relation
                                             toItem:c1.secondItem
                                          attribute:c1.secondAttribute
                                         multiplier:aspect
                                           constant:c1.constant];
        c2.priority = c1.priority;
        self.imageViewAspectRationConstraint = c2;
        c1.active = NO;
        c2.active = YES;
        
        [self.imageView sd_setImageWithURL:url];
    } else {
        NSURL *url = [NSURL URLWithString:document.storagePreviewUrl];
        self.imageView.image = nil;
        [self.imageView sd_setImageWithURL:url
                          placeholderImage:nil
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
        {
            CGFloat aspect = (image.size.width / image.size.height);
            c2 = [NSLayoutConstraint constraintWithItem:c1.firstItem
                                              attribute:c1.firstAttribute
                                              relatedBy:c1.relation
                                                 toItem:c1.secondItem
                                              attribute:c1.secondAttribute
                                             multiplier:aspect
                                               constant:c1.constant];
            c2.priority = c1.priority;
            self.imageViewAspectRationConstraint = c2;
            c1.active = NO;
            c2.active = YES;
        }];
    }
}

- (void)deleteSelectedDocument {
    MYPBinderTab *tab = self.model.binderTab;
    MYPDocument *document = tab.documents[self.selectedDocumentIndex];
    [SVProgressHUD show];
    [self.model removeDocuments:@[document] completion:^(BOOL success, NSArray *errors)
    {
        [SVProgressHUD dismiss];
        
        if (!success) {
            NSError *firstError = errors.firstObject;
            NSNumber *statusCode = firstError.userInfo[FCHttpStatusKey];
            NSString *errorMsg = NSLocalizedString(@"Failed to remove the selected Document.", nil);
            if (statusCode.integerValue == kHttpCode403PermissionDenied) {
                errorMsg = NSLocalizedString(@"You're not allowed to remove documents in this binder.", nil);
            }
            [SVProgressHUD showErrorWithStatus:errorMsg];
            return;
        }
    }];
}

- (void)shareSelectedDocument {
    MYPBinderTab *tab = self.model.binderTab;
    MYPDocument *document = tab.documents[self.selectedDocumentIndex];
    if (document.isDownloaded) {
        [self shareDocumentsAtURLs:@[document.downloadedDocumentURL]];
    } else {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Preparing your Document for sharing...", nil)];
        [self.model downloadDocuments:@[document] completion:^(NSArray<NSURL *> *fileURLs, NSArray *errors)
         {
             [SVProgressHUD dismiss];
             
             if (errors.count > 0) {
                 NSString *errorMsg = NSLocalizedString(@"Failed to share the selected Document. Please try again later.", nil);
                 [SVProgressHUD showErrorWithStatus:errorMsg];
                 return;
             }
             
             NSURL *fileURL = [NSURL fileURLWithPath:fileURLs.firstObject.path];
             [self shareDocumentsAtURLs:@[fileURL]];
         }];
    }
}

- (void)shareDocumentsAtURLs:(NSArray *)fileURLs {
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:fileURLs
                                                                                     applicationActivities:nil];
    activityController.excludedActivityTypes = @[UIActivityTypeAirDrop];
    activityController.popoverPresentationController.barButtonItem = self.optionsBarButtonItem;
    [activityController view];
    [self presentViewController:activityController animated:YES completion:nil];
}

- (void)setupDocumentControllerWithURL:(NSURL *)url {
    if (self.docInteractionController == nil) {
        self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
        self.docInteractionController.delegate = self;
    } else {
        self.docInteractionController.URL = url;
    }
}

@end
