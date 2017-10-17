//
//  MYPManageBinderUsersViewController.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 06/10/2016.
//
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "MYPManageBinderUsersViewController.h"
#import "MYPManageBinderUsersModel.h"
#import "MYPBinderUserCell.h"
#import "MYPInvitedUser.h"
#import "MYPConstants.h"
#import "UIImageView+Letters.h"

static NSString * const kBinderUserCellReuseIfentifier = @"binderUserCellReuseIdentifier";

static NSInteger const kRightUtilityDeleteButtonIndex = 0;

static CGFloat const kHeaderFooterViewHeight = 24.0f;
static CGFloat const kRowHeight = 64.0f;

@interface MYPManageBinderUsersViewController () <SWTableViewCellDelegate,
MYPBinderUserCellDelegate,
FCCollectionModelDelegate>

@property (strong, nonatomic) MYPManageBinderUsersModel *model;
@property (strong, nonatomic) NSMutableDictionary *selectedCells;

@end

@implementation MYPManageBinderUsersViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.selectedCells = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.model) {
        self.model.delegate = self;
    }
    
    [self.labelBottomBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}
                                           forState:UIControlStateDisabled];
    [self.labelBottomBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}
                                           forState:UIControlStateNormal];
    
    UIView *headerFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 1.0f, kHeaderFooterViewHeight)];
    self.tableView.tableHeaderView = headerFooterView;
    self.tableView.tableFooterView = headerFooterView;
    
    [self enterEditingMode:NO];
    [self updateBottomBarLabel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self subscribeForAlertNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    [self unsubscribeForAlertNotifications];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.binderUsers.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kRowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MYPBinderUserCell *cell = [tableView dequeueReusableCellWithIdentifier:kBinderUserCellReuseIfentifier
                                                              forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - Table view delegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - FCCollectionModelDelegate

- (void)model:(id)model didDeleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)paths {
    [self.tableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if (self.binderUsers.count == 0) {
        self.editBarButtonItem.enabled = NO;
        [self enterEditingMode:NO];
        [self popViewController];
    }
}

#pragma mark - MYPBinderUserCellDelegate

- (void)binderUserCell:(UITableViewCell *)cell didChangeCheckedState:(BOOL)checked {
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    if (path != nil) {
        if (checked) [self.selectedCells setObject:@(YES) forKey:path];
        else [self.selectedCells removeObjectForKey:path];;
        
        self.trashBottomBarItem.enabled = (self.selectedCells.count > 0);
        
        [self updateBottomBarLabel];
    }
}

#pragma mark - SWTableViewCell

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    if (index == kRightUtilityDeleteButtonIndex) {
        NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
        id user = self.binderUsers[cellIndexPath.row];
        [self removeUsers:@[user]];
    }
}

#pragma mark - Action handlers

- (IBAction)handleEditBarButtonClick:(UIBarButtonItem *)sender {
    [self enterEditingMode:YES];
}

- (IBAction)handleCancelBarButtonClick:(UIBarButtonItem *)sender {
    [self.selectedCells removeAllObjects];
    
    [self enterEditingMode:NO];
    [self updateBottomBarLabel];
    
    self.trashBottomBarItem.enabled = NO;
}

- (IBAction)handleTrashBottomBarItemClick:(id)sender {
    NSString *message = NSLocalizedString(@"Selected user(s) will no longer have access to this binder.", nil);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Revoke Access", nil)
                                                     style:UIAlertActionStyleDestructive
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       [self removeSelectedUsers];
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

#pragma mark - Public methods and properties

- (void)setBinderUsers:(NSOrderedSet *)binderUsers {
    self.model = [[MYPManageBinderUsersModel alloc] initWithUsers:binderUsers];
}

- (NSOrderedSet *)binderUsers {
    return self.model.binderUsers;
}

#pragma mark - Private methods

- (void)configureCell:(MYPBinderUserCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    /* Rounded corners & Border */
    BOOL isFirstItem = (indexPath.row == 0);
    BOOL isLastItem = (indexPath.row == (self.binderUsers.count - 1));
    UIRectCorner corners = 0;
    if (isFirstItem) corners = (corners | UIRectCornerTopRight | UIRectCornerTopLeft);
    if (isLastItem) corners =  (corners | UIRectCornerBottomRight | UIRectCornerBottomLeft);
    [cell setCardViewCorners:corners];
    
    id user = self.binderUsers[indexPath.row];
    NSString *fullName = [self.model fullNameForUser:user];
    cell.userNameLabel.text = fullName;
    cell.accessTypeImageView.hidden = ([self.model accessTypeForUser:user] == MYPAccessTypeFull);
    
    /* Avatar */
    NSString *avatarUrl = [self.model avatarForUser:user];
    NSData *thumbnailImage = [self.model thumbnailForUser:user];
    if (thumbnailImage.length > 0) {
        UIImage *avatarImage = [UIImage imageWithData:thumbnailImage];
        cell.avatarImageView.image = [avatarImage myp_circleImage];
    } else if (avatarUrl.length > 0) {
        [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatarUrl]
                                placeholderImage:[UIImage imageNamed:@"AvatarPlaceholder"]
                                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
         {
             if (!error) {
                 cell.avatarImageView.image = [image myp_circleImage];
             }
         }];
    } else {
        if (fullName.length > 0) [cell.avatarImageView setImageWithString:fullName color:nil circular:YES];
        else {
            NSString *email = [self.model emailForUser:user];
            [cell.avatarImageView setImageWithString:email color:nil circular:YES];
        }
    }
    
    cell.delegate = self;
    cell.checkedStateDelegate = self;
}

- (void)removeSelectedUsers {
    NSArray *selectedPaths = self.selectedCells.allKeys;
    NSMutableArray *usersToRemove = [NSMutableArray arrayWithCapacity:selectedPaths.count];
    for (NSIndexPath *path in selectedPaths) {
        id obj = self.binderUsers[path.row];
        [usersToRemove addObject:obj];
    }
    
    [self removeUsers:usersToRemove];
    
    [self.selectedCells removeAllObjects];
    [self updateBottomBarLabel];
    self.trashBottomBarItem.enabled = NO;
}

- (void)removeUsers:(NSArray *)users {
    [self.model removeUsers:users];
    
    SEL selector = @selector(manageBinderUsersController:didRevokeAccessForUsers:);
    if ([self.delegate respondsToSelector:selector]) {
        [self.delegate manageBinderUsersController:self didRevokeAccessForUsers:[NSSet setWithArray:users]];
    }
}

- (void)enterEditingMode:(BOOL)enter {
    [self.tableView setEditing:enter animated:YES];
    [self.navigationController setToolbarHidden:!enter animated:YES];
    self.navigationItem.rightBarButtonItems = enter ? @[self.cancelBarButtonItem] : @[self.editBarButtonItem];
}

- (void)updateBottomBarLabel {
    NSString *localizedString = NSLocalizedString(@"Selected", nil);
    NSString *title = [NSString stringWithFormat:@"%@: %li", localizedString, (unsigned long)self.selectedCells.count];
    self.labelBottomBarItem.title = title;
}

- (void)popViewController {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

@end
