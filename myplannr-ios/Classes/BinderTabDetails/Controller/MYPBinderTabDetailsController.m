//
//  MYPBinderTabDetailsController.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 13/10/2016.
//
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "MYPBinderTabDetailsController.h"
#import "MYPDocumentsPreviewViewController.h"
#import "MYPDocumentCell.h"
#import "MYPTabTitleView.h"
#import "MYPService.h"
#import "MYPFileUtils.h"
#import "MYPDocumentPicker.h"
#import "MYPTooBigDocumentWarningAlert.h"
#import "SVProgressHUD.h"

static NSString * const kDocumentCellIdentifier = @"documentCell";
static NSString * const kDocumentCellNibName = @"MYPDocumentCell";

static CGFloat const kCollectionViewSectionInset = 12.0f;
static CGFloat const kCollectionViewMinInteritemSpacing = 12.0f;
static CGFloat const kCollectionViewMinLineSpacing = 12.0f;

@interface MYPBinderTabDetailsController () <UICollectionViewDataSource,
                                             UICollectionViewDelegateFlowLayout,
                                             MYPDocumentPickerDelegate,
                                             MYPDocumentsPreviewViewControllerDelegate,
                                             FCCollectionModelDelegate>

@property (strong, nonatomic, readonly) UICollectionViewFlowLayout *flowLayout;
@property (strong, nonatomic) MYPDocumentPicker *documentPicker;

@end

@implementation MYPBinderTabDetailsController {
    CGFloat _cellWidth;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.documentPicker = [[MYPDocumentPicker alloc] initWithViewController:self cropImages:NO];
        _cellWidth = 0.0f;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.model == nil) {
        NSLog(@"%s: model==nil", __PRETTY_FUNCTION__);
    }

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];

    self.collectionView.allowsSelection = YES;
    self.collectionView.allowsMultipleSelection = YES;
    
    [self.labelBottomBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}
                                                 forState:UIControlStateDisabled];
    [self.labelBottomBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}
                                                 forState:UIControlStateNormal];
    
    UINib *nib = [UINib nibWithNibName:kDocumentCellNibName bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:kDocumentCellIdentifier];
    
    UICollectionViewFlowLayout *layout = [self flowLayout];
    layout.sectionInset = UIEdgeInsetsMake(kCollectionViewSectionInset,
                                           kCollectionViewSectionInset,
                                           kCollectionViewSectionInset * 5,
                                           kCollectionViewSectionInset);
    
    layout.minimumInteritemSpacing = kCollectionViewMinInteritemSpacing;
    layout.minimumLineSpacing = kCollectionViewMinLineSpacing;
    
    self.selectBarButtonItem.enabled = (self.model.documentsCount > 0);
    
    self.navigationItem.title = self.model.binderTab.title;
    
    CGFloat height = self.navigationController.navigationBar.frame.size.height;
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), height);
    MYPTabTitleView *titleView = [[MYPTabTitleView alloc] initWithFrame:frame];
    titleView.title = self.model.binderTab.title;
    titleView.color = self.model.binderTab.color;
    self.navigationItem.titleView = titleView;
    
    if (self.model.accessType != MYPAccessTypeFull) {
        self.selectBarButtonItem.enabled = NO;
        self.addDocumentButton.hidden = YES;
        
        NSString *secondaryLabel = NSLocalizedString(@"Binder's owner haven't added any documents yet.", nil);
        self.placeholderSecondaryLabel.text = secondaryLabel;
    }
    
    self.model.delegate = self;
    self.documentPicker.delegate = self;
    
    [self updatePlaceholderVisibility];
    [self updateBottomBarLabel];
    [self enterMultipleSelectionMode:NO];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat collectionViewWidth = CGRectGetWidth(self.collectionView.bounds);
    CGFloat itemSpacing = self.flowLayout.minimumInteritemSpacing;
    UIEdgeInsets sectionInsets = self.flowLayout.sectionInset;
    _cellWidth = ((collectionViewWidth - sectionInsets.left - sectionInsets.right) / 3) - (itemSpacing / 2) - 3;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setToolbarHidden:YES animated:NO];
    [self.model cancelDownloadRequests];
    [SVProgressHUD dismiss];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.model.documentsCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MYPDocumentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kDocumentCellIdentifier
                                                                      forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MYPBinderTab *tab = self.model.binderTab;
    MYPDocument *document = tab.documents[indexPath.row];
    CGFloat cellHeight = CGFLOAT_MIN;
    if (document.isImage) {
        CGSize imageSize = CGSizeMake(document.imgWidth.floatValue, document.imgHeight.floatValue);
        CGFloat scale = _cellWidth / imageSize.width;
        if (scale > 1.0f) {
            scale = 1.0f;
        }
        cellHeight = imageSize.height * scale;
    } else {
        UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:document.storagePreviewUrl];
        cellHeight = (image != nil) ? (image.size.height * (_cellWidth / image.size.width)) : _cellWidth;
    }
    
    return CGSizeMake(_cellWidth, cellHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if (cell) {
        [UIView animateWithDuration:0.25f animations:^{
            cell.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
        }];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if (cell) {
        [UIView animateWithDuration:0.25f animations:^{
            cell.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        }];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.collectionView.isEditingModeEnabled) {
        [self updateBottomBarLabel];
        self.shareBottomBarItem.enabled = YES;
        self.trashBottomBarItem.enabled = YES;
    } else {
        [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];

        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        [self performSegueWithIdentifier:@"showDocumentsPreviewController" sender:cell];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.collectionView.isEditingModeEnabled) {
        [self updateBottomBarLabel];
        
        NSArray *selectedPaths = self.collectionView.indexPathsForSelectedItems;
        BOOL thereAreSelectedCells = (selectedPaths.count > 0);
        self.shareBottomBarItem.enabled = thereAreSelectedCells;
        self.trashBottomBarItem.enabled = thereAreSelectedCells;
    }
}

#pragma mark - MYPDocumentPickerDelegate

- (void)documentPicker:(MYPDocumentPicker *)picker didPickDocument:(NSData *)data fileName:(NSString *)fileName
              mimeType:(NSString *)mimeType
{
    NSInteger length = data.length;
    if ((length / (1024 * 1024)) > kDocumentMaxSizeInMB) {
        MYPTooBigDocumentWarningAlert *alert = [MYPTooBigDocumentWarningAlert alertWithDocumentSizeLimit:kDocumentMaxSizeInMB];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    [self uploadDocument:data filename:fileName mimeType:mimeType];
}

- (void)documentPicker:(MYPDocumentPicker *)picker didFailWithError:(NSError *)error {
    NSLog(@"%s - %@", __PRETTY_FUNCTION__, error);
    NSString *errorMsg = NSLocalizedString(@"Failed to handle the selected document. Please try to choose another one.", nil);
    [SVProgressHUD showErrorWithStatus:errorMsg];
}

#pragma mark - MYPDocumentsPreviewViewControllerDelegate

- (void)documentsPreviewControllerDidModifyDocumentsList:(UIViewController *)controller {
    [self.collectionView reloadData];
    [self updatePlaceholderVisibility];
    self.selectBarButtonItem.enabled = (self.model.documentsCount > 0);
}

#pragma mark - FCCollectionModelDelegate

- (void)model:(id)model didInsertItemsAtIndexPaths:(NSArray<NSIndexPath *> *)paths {
    [self.collectionView insertItemsAtIndexPaths:paths];
    [self updatePlaceholderVisibility];
    self.selectBarButtonItem.enabled = YES;
}

- (void)model:(id)model didDeleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)paths {
    [self.collectionView deleteItemsAtIndexPaths:paths];
    [self updateBottomBarLabel];
    [self updatePlaceholderVisibility];
    
    BOOL allItemsRemoved = (self.model.documentsCount == 0);
    if (allItemsRemoved) {
        self.selectBarButtonItem.enabled = NO;
        [self enterMultipleSelectionMode:NO];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showDocumentsPreviewController"]) {
        UICollectionViewCell *cell = sender;
        NSIndexPath *path = [self.collectionView indexPathForCell:cell];
        MYPDocumentsPreviewViewController *vc = segue.destinationViewController;
        vc.model = [[MYPBinderTabDocumentsModel alloc] initWithTab:self.model.binderTab accessType:self.model.accessType];
        vc.delegate = self;
        vc.selectedDocumentIndex = path.row;
    }
}

#pragma mark - Action handlers

- (IBAction)handleAddDocumentButtonClick:(id)sender {
    [self.documentPicker showPickDocumentAlert:sender];
}

- (IBAction)handleSelectBarButtonItemClick:(id)sender {
    [self enterMultipleSelectionMode:YES];
}

- (IBAction)handleCancelBarButtonClick:(id)sender {
    [self enterMultipleSelectionMode:NO];
    [self updateBottomBarLabel];
}

- (IBAction)handleShareBottomBarButtonClick:(id)sender {
    NSArray *selectedCells = self.collectionView.indexPathsForSelectedItems;
    NSMutableArray *documents = [NSMutableArray arrayWithCapacity:selectedCells.count];
    for (NSIndexPath *path in selectedCells) {
        MYPDocument *document = self.model.binderTab.documents[path.row];
        [documents addObject:document];
    }
    
    [self shareDocuments:documents];
}

- (IBAction)handleTrashBottomBarItemClick:(id)sender {
    NSString *title = NSLocalizedString(@"Selected Document(s) will be completely removed.", nil);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", nil)
                                                     style:UIAlertActionStyleDestructive
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       [self removeSelectedDocuments];
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

#pragma mark - Private methods

- (void)uploadDocument:(NSData *)document filename:(NSString *)filename mimeType:(NSString *)mimeType {
    self.selectBarButtonItem.enabled = NO;
    self.addDocumentButton.enabled = NO;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationItem.hidesBackButton = YES;
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Uploading your document...", nil)];
    [self.model uploadDocument:document filename:filename mimeType:mimeType completion:^(BOOL success, NSError *error)
    {
        [SVProgressHUD dismiss];
        self.selectBarButtonItem.enabled = (self.model.documentsCount > 0);
        self.addDocumentButton.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationItem.hidesBackButton = NO;
        
        if (!success) {
            NSNumber *statusCode = error.userInfo[FCHttpStatusKey];
            if (statusCode.integerValue == kHttpCode402PaymentRequired) {
                [self showPaymentRequiredAlert];
            } else {
                NSString *errorMsg = NSLocalizedString(@"Failed to upload the selected document to our servers. Please try again later.", nil);
                [SVProgressHUD showErrorWithStatus:errorMsg];
            }
            return;
        }
    }];
}

- (void)updatePlaceholderVisibility {
    BOOL thereIsContent = ([self.collectionView numberOfItemsInSection:0] > 0);
    self.placeholderView.hidden = thereIsContent;
    self.collectionView.hidden = !thereIsContent;
}

- (void)updateBottomBarLabel {
    NSString *localizedString = NSLocalizedString(@"Selected", nil);
    NSInteger selectedItemsAmount = self.collectionView.indexPathsForSelectedItems.count;
    NSString *title = [NSString stringWithFormat:@"%@: %li", localizedString, (unsigned long)selectedItemsAmount];
    self.labelBottomBarButtonItem.title = title;
}

- (UICollectionViewFlowLayout *)flowLayout {
    return (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
}

- (void)removeSelectedDocuments {
    NSArray *selectedCells = self.collectionView.indexPathsForSelectedItems;
    NSMutableArray *documentsToRemove = [NSMutableArray arrayWithCapacity:selectedCells.count];
    for (NSIndexPath *path in selectedCells) {
        MYPDocument *d = self.model.binderTab.documents[path.row];
        [documentsToRemove addObject:d];
    }
    
    [SVProgressHUD show];
    [self.model removeDocuments:documentsToRemove completion:^(BOOL success, NSArray *errors)
     {
         [SVProgressHUD dismiss];
         if (!success) {
             NSError *firstError = errors.firstObject;
             NSNumber *statusCode = firstError.userInfo[FCHttpStatusKey];
             NSString *errorMsg = NSLocalizedString(@"Failed to remove one of your documents. Please try again later.", nil);
             if (statusCode.integerValue == kHttpCode403PermissionDenied) {
                 errorMsg = NSLocalizedString(@"You're not allowed to remove documents in this binder.", nil);
             }
             [SVProgressHUD showErrorWithStatus:errorMsg];
             return;
         }
         
         self.shareBottomBarItem.enabled = NO;
         self.trashBottomBarItem.enabled = NO;
     }];
}

- (void)showAddDocumentButton:(BOOL)show {
    if (show && self.model.accessType == MYPAccessTypeFull) {
        self.addDocumentButton.alpha = 0.0f;
        self.addDocumentButton.hidden = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.15f animations:^{
                self.addDocumentButton.alpha = 1.0f;
            }];
        });
    } else {
        self.addDocumentButton.hidden = YES;
    }
}

- (void)enterMultipleSelectionMode:(BOOL)enter {
    [self.navigationController setToolbarHidden:!enter animated:YES];
    [self showAddDocumentButton:!enter];
    self.collectionView.editingModeEnabled = enter;
    self.navigationItem.rightBarButtonItems = enter ? @[self.cancelBarButtonItem] : @[self.selectBarButtonItem];
    
    if (!enter) {
        // Clear selection
        NSArray *selectedPaths = [self.collectionView indexPathsForSelectedItems];
        for (NSIndexPath *path in selectedPaths) {
            [self.collectionView deselectItemAtIndexPath:path animated:NO];
        }
        
        self.shareBottomBarItem.enabled = NO;
        self.trashBottomBarItem.enabled = NO;
    }
}

- (void)shareDocuments:(NSArray *)documents {
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"isDownloaded == NO"];
    NSArray *documentsToDownload = [documents filteredArrayUsingPredicate:filter];
    if (documentsToDownload.count > 0) {
        /* There are some documents that need to be downloaded first */

        [SVProgressHUD showWithStatus:NSLocalizedString(@"Preparing your Documents for sharing...", nil)];
        [self.model downloadDocuments:documentsToDownload completion:^(NSArray<NSURL *> *fileURLs, NSArray *errors)
         {
             [SVProgressHUD dismiss];
             
             if (errors.count > 0) {
                 NSString *errorMsg = NSLocalizedString(@"Failed to share the selected Documents. Please try again later.", nil);
                 [SVProgressHUD showErrorWithStatus:errorMsg];
                 return;
             }
             
             [self shareDocuments:documents];
         }];
    } else {
        /* All documents are already downloaded */
        
        NSMutableArray *urls = [NSMutableArray arrayWithCapacity:documents.count];
        for (MYPDocument *d in documents) {
            NSURL *u = d.downloadedDocumentURL;
            [urls addObject:u];
        }
        [self shareDocumentsAtURLs:urls];
    }
}

- (void)shareDocumentsAtURLs:(NSArray *)urls {
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:urls
                                                                                     applicationActivities:nil];
    activityController.excludedActivityTypes = @[UIActivityTypeAirDrop];
    activityController.completionWithItemsHandler = ^(UIActivityType __nullable activityType,
                                                      BOOL completed,
                                                      NSArray * __nullable returnedItems,
                                                      NSError * __nullable activityError)
    {
        [self enterMultipleSelectionMode:NO];
        [self updateBottomBarLabel];
    };
    
    activityController.popoverPresentationController.barButtonItem = self.shareBottomBarItem;
    
    [self presentViewController:activityController animated:YES completion:nil];
}

- (void)showPaymentRequiredAlert {
    NSString *title = NSLocalizedString(@"Unable to create Document", nil);
    NSString *msg = NSLocalizedString(@"Please upgrade to get unlimited access.", nil);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Upgrade", nil)
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action)
                             {
                                 UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MYPGetUnlimitedAccessStoryboard"
                                                                                      bundle:[NSBundle mainBundle]];
                                 UIViewController *vc = [storyboard instantiateInitialViewController];
                                 [self presentViewController:vc animated:YES completion:nil];
                                 
                             }];
    [alert addAction:action];
    
    action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                      style:(UIAlertActionStyleCancel)
                                    handler:nil];
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)configureCell:(MYPDocumentCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    MYPBinderTab *tab = self.model.binderTab;
    MYPDocument *document = tab.documents[indexPath.row];
    cell.editing = self.collectionView.isEditingModeEnabled;
    
    NSURL *url = [NSURL URLWithString:document.storagePreviewUrl];
    if (document.isImage) {
        [cell.imageView sd_setImageWithURL:url];
    } else {
        [cell.imageView sd_setImageWithURL:url
                          placeholderImage:nil
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
        {
            if (cacheType == SDImageCacheTypeNone) {
                [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }
        }];
    }
}

@end
