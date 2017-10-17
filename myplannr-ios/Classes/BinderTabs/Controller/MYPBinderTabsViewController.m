//
//  MYPBinderTabsViewController.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 11/10/2016.
//
//

#import "MYPBinderTabsViewController.h"
#import "MYPBinderTabCell.h"
#import "MYPCreateOrEditTabViewController.h"
#import "MYPBinderTabDetailsController.h"
#import "SVProgressHUD.h"

static NSString * const kTabCellIdentifier = @"TabCell";

static NSInteger const kRightUtilityEditButtonIndex = 0;
static NSInteger const kRightUtilityDeleteButtonIndex = 1;

static CGFloat const kHeaderViewHeight = 24.0f;
static CGFloat const kFooterViewHeight = 84.0f;
static CGFloat const kRowHeight = 64.0f;

@interface MYPBinderTabsViewController () <UITableViewDelegate,
UITableViewDataSource,
SWTableViewCellDelegate,
MYPBinderTabCellDelegate,
MYPCreateOrEditTabViewControllerDelegate,
FCCollectionModelDelegate>

@property (strong, nonatomic) MYPBinderTabsModel *model;

@property (strong, nonatomic) NSMutableDictionary *selectedCells;

@end

@implementation MYPBinderTabsViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.selectedCells = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.cancelBarButtonHidden = YES; // invisible by default
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
    
    [self.labelBottomBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}
                                           forState:UIControlStateDisabled];
    [self.labelBottomBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}
                                           forState:UIControlStateNormal];
    
    UINib *nib = [UINib nibWithNibName:@"MYPBinderTabCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:nib forCellReuseIdentifier:kTabCellIdentifier];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 1.0f, kHeaderViewHeight)];
    self.tableView.tableHeaderView = headerView;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 1.0f, kFooterViewHeight)];
    self.tableView.tableFooterView = footerView;
    
    [self updateBottomBarLabel];
    [self enterEditingMode:NO];
    
    if (!self.binder.isOwner && self.binder.accessType == MYPAccessTypeReadOnly) {
        NSString *secondaryLabel = NSLocalizedString(@"The Binder's owner haven't added any tabs yet.", nil);
        self.addTabButton.hidden = YES;
        self.placeholderSecondaryLabel.text = secondaryLabel;
        self.editBarButtonItem.enabled = NO;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadTabs];
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setToolbarHidden:YES animated:NO];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.model.tabs.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kRowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MYPBinderTabCell *cell = [tableView dequeueReusableCellWithIdentifier:kTabCellIdentifier
                                                             forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - Table view delegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - FCCollectionModelDelegate

- (void)model:(id)model didInsertItemsAtIndexPaths:(NSArray<NSIndexPath *> *)paths {
    [self.tableView reloadData];
    [self updatePlaceholderVisibility];
}

- (void)model:(id)model didUpdateItemsAtIndexPaths:(NSArray<NSIndexPath *> *)paths {
    [self.tableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)model:(id)model didDeleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)paths {
    [self.tableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationAutomatic];
    [self updatePlaceholderVisibility];
}

#pragma mark - MYPBinderUserCellDelegate

- (void)binderTabCell:(UITableViewCell *)cell didChangeCheckedState:(BOOL)checked {
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    if (path != nil) {
        if (checked) [self.selectedCells setObject:@(YES) forKey:path];
        else [self.selectedCells removeObjectForKey:path];;
        self.trashBottomBarItem.enabled = (self.selectedCells.count > 0);
        [self updateBottomBarLabel];
    }
}

- (void)binderTabCellDidTapCard:(UITableViewCell *)cell {
    [self performSegueWithIdentifier:@"showTabDetailsController" sender:cell];
}

#pragma mark - MYPCreateOrEditTabViewControllerDelegate

- (void)createOrEditTabViewController:(UIViewController *)controller didCreateTab:(MYPBinderTab *)tab {
    [self.model addTab:tab];
}

- (void)createOrEditTabViewController:(UIViewController *)controller didFinishEditingTab:(MYPBinderTab *)tab {
    [self.model updateTab:tab];
}

#pragma mark - SWTableViewCell

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    if (index == kRightUtilityEditButtonIndex) {
        [self performSegueWithIdentifier:@"showEditTabController" sender:cell];
    } else if (index == kRightUtilityDeleteButtonIndex) {
        NSString *title = NSLocalizedString(@"This Tab will be completely removed (including its Documents).", nil);
        [self showDeleteConfirmationAlertWithTitle:title deleteActionHandler:^(UIAlertAction *action) {
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            [self deleteTabsAtIndexPaths:@[cellIndexPath] completion:^(BOOL success) {
                // Do nothing
            }];
        }];
    }
    
    [cell hideUtilityButtonsAnimated:YES];
}

#pragma mark - Action Handlers

- (IBAction)handlEditBarButtonClick:(id)sender {
    [self enterEditingMode:YES];
}

- (IBAction)handleDoneBarButtonClick:(id)sender {
    [self.selectedCells removeAllObjects];
    [self enterEditingMode:NO];
    [self updateBottomBarLabel];
    self.trashBottomBarItem.enabled = NO;
}

- (IBAction)handleTrashBottomBarItemClick:(id)sender {
    NSString *title = NSLocalizedString(@"Selected Tabs will be completely removed (including Documents).", nil);
    [self showDeleteConfirmationAlertWithTitle:title deleteActionHandler:^(UIAlertAction *action) {
        [self removeSelectedTabs];
    }];
}

- (IBAction)handleCancelBarButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showCreateTabController"]
        || [segue.identifier isEqualToString:@"showEditTabController"])
    {
        UINavigationController *navController = segue.destinationViewController;
        MYPCreateOrEditTabViewController *createTabController = navController.viewControllers[0];
        MYPCreateOrEditTabModel *model = nil;
        if ([segue.identifier isEqualToString:@"showCreateTabController"]) {
            model = [[MYPCreateOrEditTabModel alloc] initWithBinder:self.binder];
        } else if ([segue.identifier isEqualToString:@"showEditTabController"]) {
            UITableViewCell *cell = sender;
            NSIndexPath *path = [self.tableView indexPathForCell:cell];
            MYPBinderTab *tab = self.model.tabs[path.row];
            model = [[MYPCreateOrEditTabModel alloc] initWithBinder:self.binder editingTab:tab];
        }
        createTabController.delegate = self;
        createTabController.model = model;
    } else if ([segue.identifier isEqualToString:@"showTabDetailsController"]) {
        UITableViewCell *cell = sender;
        NSIndexPath *path = [self.tableView indexPathForCell:cell];
        MYPBinderTabDetailsController *controller = segue.destinationViewController;
        MYPAccessType accessType = self.binder.isOwner ? MYPAccessTypeFull : self.binder.accessType;
        MYPBinderTabDocumentsModel *model = [[MYPBinderTabDocumentsModel alloc] initWithTab:self.model.tabs[path.row]
                                                                                 accessType:accessType];
        controller.model = model;
    }
}

#pragma mark - Public methods and properties

- (void)setBinder:(MYPBinder *)binder {
    self.model = [[MYPBinderTabsModel alloc] initWithBinder:binder];
    self.model.delegate = self;
}

- (MYPBinder *)binder {
    return self.model.binder;
}

- (void)setCancelBarButtonHidden:(BOOL)cancelBarButtonHidden {
    _cancelBarButtonHidden = cancelBarButtonHidden;
    
    self.navigationItem.leftBarButtonItem = cancelBarButtonHidden ? nil : self.cancelBarButtonItem;
}

#pragma mark - Private methods

- (void)configureCell:(MYPBinderTabCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    /* Rounded corners & Border */
    BOOL isFirstItem = (indexPath.row == 0);
    BOOL isLastItem = (indexPath.row == (self.model.tabs.count - 1));
    UIRectCorner corners = 0;
    if (isFirstItem) corners = (corners | UIRectCornerTopRight | UIRectCornerTopLeft);
    if (isLastItem) corners =  (corners | UIRectCornerBottomRight | UIRectCornerBottomLeft);
    [cell setCardViewCorners:corners];
    
    cell.delegate = self;
    cell.binderTabDelegate = self;
    
    MYPBinderTab *tab = self.model.tabs[indexPath.row];
    cell.tabNameLabel.text = tab.title;
    cell.tabColorView.backgroundColor = tab.color;
    
    if (!self.binder.isOwner && self.binder.accessType == MYPAccessTypeReadOnly) {
        cell.rightUtilityButtons = @[];
    }
}

- (void)showDeleteConfirmationAlertWithTitle:(NSString *)title
                         deleteActionHandler:(void (^ __nullable)(UIAlertAction *action))handler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", nil)
                                                     style:UIAlertActionStyleDestructive
                                                   handler:handler];
    [alert addAction:action];
    
    action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                      style:UIAlertActionStyleCancel
                                    handler:nil];
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)updateBottomBarLabel {
    NSString *localizedString = NSLocalizedString(@"Selected", nil);
    NSString *title = [NSString stringWithFormat:@"%@: %li", localizedString, (unsigned long)self.selectedCells.count];
    self.labelBottomBarItem.title = title;
}

- (void)updatePlaceholderVisibility {
    BOOL thereIsContent = self.model.tabs.count > 0;
    self.tableView.hidden = !thereIsContent;
    self.placeholderView.hidden = thereIsContent;
    
    if (self.binder.isOwner || self.binder.accessType == MYPAccessTypeFull) {
        self.editBarButtonItem.enabled = thereIsContent;
    }
}

- (void)enterEditingMode:(BOOL)enter {
    [self.tableView setEditing:enter animated:YES];
    [self.navigationController setToolbarHidden:!enter animated:YES];
    self.navigationItem.rightBarButtonItems = enter ? @[self.doneBarButtonItem] : @[self.editBarButtonItem];
}

- (void)loadTabs {
    [SVProgressHUD show];
    [self.model loadTabsWithCompletionBlock:^(NSArray *results, BOOL fromLocalStorage, NSError *error)
     {
         [SVProgressHUD dismiss];
         
         if (error) {
             NSString *errorMsg = NSLocalizedString(@"Failed to load tabs. Please try again later.", nil);
             [SVProgressHUD showErrorWithStatus:errorMsg];
         }
         
         [self.tableView reloadData];
         [self updatePlaceholderVisibility];
     }];
}

- (void)removeSelectedTabs {
    NSArray *selectedPaths = self.selectedCells.allKeys;
    [self deleteTabsAtIndexPaths:selectedPaths completion:^(BOOL success)
     {
         [self.selectedCells removeAllObjects];
         if (success) {
             [self updateBottomBarLabel];
             self.trashBottomBarItem.enabled = NO;
             BOOL allItemsRemoved = (self.model.tabs.count == 0);
             if (allItemsRemoved) {
                 [self enterEditingMode:NO];
             }
         } else {
             [self enterEditingMode:NO];
         }
     }];
}

- (void)deleteTabsAtIndexPaths:(NSArray<NSIndexPath *>*)indexPaths completion:(void (^)(BOOL success))completion {
    NSInteger count = indexPaths.count;
    NSMutableArray *tabsToRemove = [NSMutableArray arrayWithCapacity:count];
    for (NSIndexPath *path in indexPaths) {
        MYPBinderTab *tab = self.model.tabs[path.row];
        [tabsToRemove addObject:tab];
    }
    
    [SVProgressHUD show];
    [self.model deleteTabs:tabsToRemove completionBlock:^(BOOL success, NSArray *errors)
     {
         [SVProgressHUD dismiss];
         
         if (!success) {
             NSString *errorMsg = NSLocalizedString(@"Failed to remove one of your tabs. Please try again later.", nil);
             NSError *firstError = errors.firstObject;
             NSNumber *statusCode = firstError.userInfo[FCHttpStatusKey];
             if (statusCode.integerValue == kHttpCode403PermissionDenied) {
                 errorMsg = NSLocalizedString(@"You're not allowed to remove tabs in this binder.", nil);
             }
             [SVProgressHUD showErrorWithStatus:errorMsg];
             [self updatePlaceholderVisibility];
             if (completion) {
                 completion(NO);
             }
             return;
         }
         
         if (completion) {
             completion(YES);
         }
     }];
}

@end
