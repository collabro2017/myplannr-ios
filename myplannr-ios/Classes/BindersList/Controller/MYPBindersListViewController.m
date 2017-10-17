//
//  MYPBindersListViewController.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 19/09/16.
//
//

#import <StoreKit/StoreKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "MYPBindersListViewController.h"
#import "MYPStartPageViewController.h"
#import "MYPBinderCollectionViewCell.h"
#import "MYPCreateBinderViewController.h"
#import "MYPEditBinderViewController.h"
#import "MYPUserProfile.h"
#import "MYPUser.h"
#import "MYPDocumentPicker.h"
#import "MYPTooBigDocumentWarningAlert.h"
#import "SVProgressHUD.h"
#import "UIImageView+Letters.h"
#import "MYPStoreManager.h"
#import "MYPChatModel.h"
#import "MYPFileUtils.h"

static NSString * const kBinderCellReuseIdentifier = @"BinderCell";

@interface MYPBindersListViewController () <MYPCreateBinderViewControllerDelegate,
                                            MYPEditBinderViewControllerDelegate,
                                            MYPBinderCollectionViewCellDelegate,
                                            MYPDocumentPickerDelegate,
                                            FCCollectionModelDelegate>

@property (nonatomic, strong) MYPDocumentPicker *documentPicker;

@end

@implementation MYPBindersListViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.model = [[MYPBindersListModel alloc] init];
        self.documentPicker = [[MYPDocumentPicker alloc] initWithViewController:self cropImages:NO];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[MYPStoreManager sharedInstance]];
    
    if (self.navigationController.isNavigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    
    UIImage *logo = [UIImage imageNamed:@"NavBarLogo"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:logo];
    
    self.model.delegate = self;
    self.documentPicker.delegate = self;
    
    self.addBinderButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.addBinderButton.layer.borderWidth = 1.0f;
    
    UINib *nib = [UINib nibWithNibName:@"MYPBinderCollectionViewCell" bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:kBinderCellReuseIdentifier];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleImportDocumentNotification:)
                                                 name:kImportDocumentAtURLNotification
                                               object:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadBinders];
    });
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.addBinderButton.layer.cornerRadius = (CGRectGetWidth(self.addBinderButton.bounds) / 2);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    MYPUser *user = [MYPUserProfile sharedInstance].currentUser;
    if (user.firstName.length == 0 || user.lastName.length == 0) {
        // Force the user to specify first and last names
        [self showCompleteRegistrationController];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kImportDocumentAtURLNotification object:nil];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.model.binders.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MYPBinderCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:kBinderCellReuseIdentifier
                                                                      forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"showBinderTabsController" sender:cell];
}

#pragma mark - FCCollectionModelDelegate

- (void)model:(MYPBindersListModel *)model didInsertItemsAtIndexPaths:(NSArray<NSIndexPath *> *)paths {
    [self.collectionView performBatchUpdates:^{
        [self.collectionView insertItemsAtIndexPaths:paths];
    } completion:^(BOOL finished) {
        [self.collectionView scrollToItemAtIndexPath:paths.firstObject
                                    atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                            animated:YES];
    }];
}

- (void)model:(MYPBindersListModel *)model didUpdateItemsAtIndexPaths:(NSArray<NSIndexPath *> *)paths {
    [self.collectionView reloadItemsAtIndexPaths:paths];
}

- (void)model:(MYPBindersListModel *)model didDeleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)paths {
    [self.collectionView deleteItemsAtIndexPaths:paths];
}

- (void)model:(MYPBindersListModel *)model didMoveItemFromIndexPath:(NSIndexPath *)fromPath
  toIndexPath:(NSIndexPath *)toPath
{
    [self.collectionView performBatchUpdates:^{
        [self.collectionView moveItemAtIndexPath:fromPath toIndexPath:toPath];
    } completion:^(BOOL finished) {
        [self.collectionView reloadItemsAtIndexPaths:@[toPath]];
    }];
}

#pragma mark - MYPDocumentPickerDelegate

- (void)documentPicker:(MYPDocumentPicker *)picker
       didPickDocument:(NSData *)data
              fileName:(NSString *)fileName
              mimeType:(NSString *)mimeType
{
    if ([self documentExceedsSizeLimit:data]) {
        MYPTooBigDocumentWarningAlert *alert = [MYPTooBigDocumentWarningAlert alertWithDocumentSizeLimit:kDocumentMaxSizeInMB];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    [self showBinderPickerControllerForDocument:data fileName:fileName mimeType:mimeType];
}

- (void)documentPicker:(MYPDocumentPicker *)picker didFailWithError:(NSError *)error {
    NSLog(@"%s - %@", __PRETTY_FUNCTION__, error);
    NSString *errorMsg = NSLocalizedString(@"Failed to handle the selected document. Please try to choose another one.", nil);
    [SVProgressHUD showErrorWithStatus:errorMsg];
}

#pragma mark - MYPCreateBinderViewControllerDelegate

- (void)createBinderViewController:(UIViewController *)controller didCreateBinder:(MYPBinder *)binder {
    [self.model addBinder:binder];
    [self updatePlaceholderVisibility];
    [self updateAddDocumentButtonState];
}

#pragma mark - MYPEditBinderViewControllerDelegate

- (void)editBinderViewController:(UIViewController *)controller didFinishEditingBinder:(MYPBinder *)binder {
    [self.model updateBinder:binder];
}

- (void)editBinderViewController:(UIViewController *)controller didRemoveBinder:(MYPBinder *)binder {
    [self.model deleteBinder:binder];
    [self updatePlaceholderVisibility];
    [self updateAddDocumentButtonState];
}

#pragma mark - MYPBinderCollectionViewCellDelegate

- (void)binderCollectionViewCell:(UICollectionViewCell *)cell didTapBinderButton:(UIButton *)button {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    if (indexPath) {
        MYPBinder *binder = self.model.binders[indexPath.row];
        if (binder.isOwner || binder.accessType == MYPAccessTypeFull) {
            [self performSegueWithIdentifier:@"showEditBinderController" sender:cell];
        }
    }
}

- (void)binderCollectionViewCell:(UICollectionViewCell *)cell didTapChatButton:(UIButton *)button {
    [self performSegueWithIdentifier:@"showChatStoryboard" sender:cell];
}

#pragma mark - Navigation

#warning Can we introduce some independent class responsible for navigation?
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showCreateBinderController"]) {
        UINavigationController *controller = segue.destinationViewController;
        UIViewController *topViewController = controller.topViewController;
        if ([topViewController respondsToSelector:NSSelectorFromString(@"setDelegate:")]) {
            [topViewController setValue:self forKey:@"delegate"];
        }
    } else if ([segue.identifier isEqualToString:@"showEditBinderController"]) {
        UINavigationController *controller = segue.destinationViewController;
        UICollectionViewCell *cell = sender;
        NSIndexPath *path = [self.collectionView indexPathForCell:cell];
        UIViewController *topViewController = controller.topViewController;
        if ([topViewController respondsToSelector:NSSelectorFromString(@"setEditingBinder:")]
            && [topViewController respondsToSelector:NSSelectorFromString(@"setDelegate:")]) {
            [topViewController setValue:self.model.binders[path.row] forKey:@"editingBinder"];
            [topViewController setValue:self forKey:@"delegate"];
        }
    } else if ([segue.identifier isEqualToString:@"showBinderTabsController"]) {
        UICollectionViewCell *cell = sender;
        NSIndexPath *path = [self.collectionView indexPathForCell:cell];
        UIViewController *controller =  segue.destinationViewController;
        if ([controller respondsToSelector:NSSelectorFromString(@"setBinder:")]) {
            [controller setValue:self.model.binders[path.row] forKey:@"binder"];
        }
    } else if ([segue.identifier isEqualToString:@"showChatStoryboard"]) {
        UICollectionViewCell *cell = sender;
        NSIndexPath *path = [self.collectionView indexPathForCell:cell];
        UIViewController *controller = segue.destinationViewController;
        if ([controller respondsToSelector:NSSelectorFromString(@"setModel:")]) {
            [controller setValue:[[MYPChatModel alloc] initWithBinder:self.model.binders[path.row]] forKey:@"model"];
        }
    }
}

#pragma mark - Button Handlers

- (IBAction)handleCreateDocumentButtonClick:(id)sender {
    [self.documentPicker showPickDocumentAlert:sender];
}

- (IBAction)handleRefreshBarButtonClick:(id)sender {
    [self loadBinders];
}

#pragma mark - Private Methods

- (void)showCompleteRegistrationController {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    MYPStartPageViewController *startPageVC = [sb instantiateViewControllerWithIdentifier:@"StartPageController"];
    [startPageVC showCompleteRegistrationController];
    
    CATransition* transition = [CATransition animation];
    transition.duration = 0.5f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController pushViewController:startPageVC animated:NO];
}

- (void)configureCell:(MYPBinderCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    MYPBinder *binder = self.model.binders[indexPath.row];
    cell.binderNameLabel.text = binder.name;
    cell.eventDateLabel.text = [[NSDateFormatter myp_clientDateFormatter] stringFromDate:binder.eventDate];
    cell.binderContainerView.backgroundColor = binder.color;
    cell.unreadMessagesCount = 0;
    
    if (binder.isOwner) {
        cell.ownerAvatarImageView.hidden = YES;
        cell.ownerNameLabel.hidden = YES;
        cell.ownerNameLabelTopConstraint.constant = 0.0f;
    } else {
        cell.ownerAvatarImageView.hidden = NO;
        cell.ownerNameLabel.hidden = NO;
        cell.ownerNameLabelTopConstraint.constant = 32.0f;
        
        MYPUser *owner = binder.owner;
        cell.ownerNameLabel.text = owner.fullName;
        
        /* Avatar */
        if (owner.avatarUrl.length > 0) {
            [cell.ownerAvatarImageView sd_setImageWithURL:[NSURL URLWithString:owner.avatarUrl]
                                         placeholderImage:[UIImage imageNamed:@"AvatarPlaceholder"]];
        
        } else {
            NSString *fullName = owner.fullName;
            if (fullName.length > 0) {
                [cell.ownerAvatarImageView setImageWithString:fullName color:nil circular:YES];
            } else {
                [cell.ownerAvatarImageView setImageWithString:owner.email color:nil circular:YES];
            }
        }
    }
    
    MYPAccessType accessType = binder.accessType;
    UIImage *buttonImage = (binder.isOwner || accessType == MYPAccessTypeFull)
        ? [UIImage imageNamed:@"EditBinderIcon"]
        : [UIImage imageNamed:@"ReadOnlyBinderIconWhite"];
    [cell.binderButton setImage:buttonImage forState:UIControlStateNormal];
    
    cell.delegate = self;
}

- (void)loadBinders {
    [SVProgressHUD show];
    [self.model loadBindersWithCompletionBlock:^(NSArray *results, BOOL fromLocalStorage, NSError *error) {
        [SVProgressHUD dismiss];
        
        if (error) {
            NSString *errorStatus = NSLocalizedString(@"Failed to load your binders. Please try again later.", nil);
            [SVProgressHUD showErrorWithStatus:errorStatus];
        }
        
        [self.collectionView reloadData];
        [self updatePlaceholderVisibility];
        [self updateAddDocumentButtonState];
    }];
}

- (void)updatePlaceholderVisibility {
    self.collectionView.hidden = (self.model.binders.count == 0);
    self.placeholderView.hidden = (self.model.binders.count > 0);
}

- (void)updateAddDocumentButtonState {
    BOOL enabled = self.model.bindersWithFullAccess.count > 0;
    self.createDocumentButton.enabled = enabled;
}

#warning The code below is not directly related to "binders list", refactoring is needed.

- (void)handleImportDocumentNotification:(NSNotification *)notification {
    NSURL *url = notification.userInfo[kImportDocumentAtURLNotificationURLKey];
    if (self.model.binders.count > 0) {
        [self importExternalFileAtURL:url];
    } else if (self.model.isLoadingBinders) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self handleImportDocumentNotification:notification];
        });
    } else {
        [MYPFileUtils removeFilesAtURLs:@[url] error:nil];
        
        NSString *errorMsg = NSLocalizedString(@"There are no any Binders to upload your document to.", nil);
        [SVProgressHUD showErrorWithStatus:errorMsg];
    }
}

- (void)importExternalFileAtURL:(NSURL *)url {
    NSError *error = nil;
    NSData *documentData = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
    [MYPFileUtils removeFilesAtURLs:@[url] error:nil];
    if (error) {
        NSLog(@"%s: unable to read file at URL=%@", __PRETTY_FUNCTION__, url.path);
        NSString *errorMsg = NSLocalizedString(@"Failed to import the selected file.", nil);
        [SVProgressHUD showErrorWithStatus:errorMsg];
        return;
    }
    
    if ([self documentExceedsSizeLimit:documentData]) {
        MYPTooBigDocumentWarningAlert *alert = [MYPTooBigDocumentWarningAlert alertWithDocumentSizeLimit:kDocumentMaxSizeInMB];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    [self showBinderPickerControllerForDocument:documentData
                                       fileName:[url lastPathComponent]
                                       mimeType:[MYPFileUtils mimeTypeForItemAtURL:url]];
}
     
- (void)showBinderPickerControllerForDocument:(NSData *)document fileName:(NSString *)fileName mimeType:(NSString *)mimeType {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MYPBinderPickerStoryboard" bundle:[NSBundle mainBundle]];
    UINavigationController *navVC = [storyboard instantiateInitialViewController];
    UIViewController *vc = navVC.topViewController;
    [vc setValue:document forKey:@"documentData"];
    [vc setValue:fileName forKey:@"fileName"];
    [vc setValue:mimeType forKey:@"mimeType"];
    [vc setValue:self.model.bindersWithFullAccess forKey:@"binders"];
    [self presentViewController:navVC animated:YES completion:nil];
}

- (BOOL)documentExceedsSizeLimit:(NSData *)data {
    NSInteger length = data.length;
    return ((length / (1024 * 1024)) > kDocumentMaxSizeInMB);
}

@end
