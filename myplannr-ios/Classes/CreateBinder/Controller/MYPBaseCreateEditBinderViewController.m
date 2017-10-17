//
//  MYPBaseCreateEditBinderViewController.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 15/02/2017.
//
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "MYPBaseCreateEditBinderViewController.h"
#import "MYPInviteUsersViewController.h"
#import "MYPManageBinderUsersViewController.h"
#import "MYPInvitedUserCollectionViewCell.h"
#import "MYPNonManagedInvitedUser.h"
#import "MYPUtils.h"
#import "UIImageView+Letters.h"

static NSString * const kInvitedUserCellIdentifier = @"invitedUserCell";

static CGFloat const kCollectionViewItemSize = 48.0f;

@interface MYPBaseCreateEditBinderViewController () <UICollectionViewDelegate,
                                                     UICollectionViewDataSource,
                                                     UITextFieldDelegate,
                                                     MYPInviteUsersViewControllerDelegate,
                                                     MYPManageBinderUsersViewControllerDelegate>

@property (strong, nonatomic) NSMutableOrderedSet *mutableInvitedUsers;

@end

@implementation MYPBaseCreateEditBinderViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.mutableInvitedUsers = [NSMutableOrderedSet orderedSet];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *date = [[NSDateFormatter myp_clientDateFormatter] stringFromDate:self.eventdate];
    self.binderView.dateTextField.text = date;
    
    UINib *nib = [UINib nibWithNibName:@"MYPInvitedUserCollectionViewCell" bundle:[NSBundle mainBundle]];
    [self.binderView.usersCollectionView registerNib:nib forCellWithReuseIdentifier:kInvitedUserCellIdentifier];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.binderView.usersCollectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(kCollectionViewItemSize, kCollectionViewItemSize);
    
    [self updateInvitedUsersHintLabel];
    [self showUsersCollectionView:(self.mutableInvitedUsers.count > 0)];
    
    /* Delegates, data sources */
    
    self.binderView.usersCollectionView.delegate = self;
    self.binderView.usersCollectionView.dataSource = self;
    
    self.binderView.nameTextField.delegate = self;
    
    /* Tap gestures and action handlers */
    
    UIGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                      action:@selector(handleNameContainerViewTap:)];
    [self.binderView.nameContainerView addGestureRecognizer:gr];
    
    gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDateContainerViewTap:)];
    [self.binderView.dateContainerView addGestureRecognizer:gr];
    
    [self.binderView.addUserLeftButton addTarget:self
                                          action:@selector(handleAddUserButtonClick:)
                                forControlEvents:UIControlEventTouchUpInside];
    
    [self.binderView.addUserRightButton addTarget:self
                                           action:@selector(handleAddUserButtonClick:)
                                 forControlEvents:UIControlEventTouchUpInside];
    
    [self.binderView.userSettingsButton addTarget:self
                                           action:@selector(handleUserSettingsButtonClick:)
                                 forControlEvents:UIControlEventTouchUpInside];
    
    [self.binderView.datePicker addTarget:self
                                   action:@selector(datePickerDidChangeValue:)
                         forControlEvents:UIControlEventValueChanged];
    
    gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleColorContainerViewTap:)];
    [self.binderView.colorContainerView addGestureRecognizer:gr];
}

#pragma mark - Public Methods & Properties

- (BOOL)validateInput {
    if (self.binderView.nameTextField.text.length == 0) {
        [MYPUtils shakeView:self.binderView.nameContainerView];
        return NO;
    }
    if (self.binderView.dateTextField.text.length == 0) {
        [MYPUtils shakeView:self.binderView.dateContainerView];
        return NO;
    }

    return YES;
}

- (void)configureCell:(MYPInvitedUserCollectionViewCell *)cell withUser:(id)user {
    NSString *email = [user valueForKey:@"email"];
    NSString *fullName = [user valueForKey:@"fullName"];
    if (fullName.length == 0) fullName = email;
    
    SEL avatarSel = NSSelectorFromString(@"avatarUrl");
    SEL thumbnailSel = NSSelectorFromString(@"thumbnailImageData");
    NSString *avatarUrl = [user respondsToSelector:avatarSel] ? [user valueForKey:@"avatarUrl"] : nil;
    NSData *thumbnailImage = [user respondsToSelector:thumbnailSel] ? [user valueForKey:@"thumbnailImageData"] : nil;
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
        else [cell.avatarImageView setImageWithString:email color:nil circular:YES];
    }
}

- (void)setInvitedUsers:(NSSet *)invitedUsers {
    [self.mutableInvitedUsers removeAllObjects];
    [self.mutableInvitedUsers addObjectsFromArray:invitedUsers.allObjects];
    
    [self showUsersCollectionView:(self.mutableInvitedUsers.count > 0)];
    [self.binderView.usersCollectionView reloadData];
    [self updateInvitedUsersHintLabel];
}

- (NSSet *)invitedUsers {
    return self.mutableInvitedUsers.set;
}

- (NSString *)binderName {
    return self.binderView.nameTextField.text;
}

- (UIColor *)binderColor {
    return self.binderView.colorCircleView.circleColor;
}

- (NSDate *)eventdate {
    return self.binderView.datePicker.date;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.mutableInvitedUsers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MYPInvitedUserCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kInvitedUserCellIdentifier
                                                                                       forIndexPath:indexPath];
    id user = self.mutableInvitedUsers[indexPath.row];
    [self configureCell:cell withUser:user];
    return cell;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [self.binderView.nameTextField resignFirstResponder];
    return YES;
}

#pragma mark - UIDatePicker Actions

- (void)datePickerDidChangeValue:(UIDatePicker *)sender {
    NSDate *date = sender.date;
    self.binderView.dateTextField.text = [[NSDateFormatter myp_clientDateFormatter] stringFromDate:date];
}

#pragma mark - MYPInviteUsersViewControllerDelegate

- (void)inviteUsersController:(UIViewController *)controller didInviteUser:(MYPNonManagedInvitedUser *)user {
    [self showUsersCollectionView:YES];
    
    NSInteger idx = [self.mutableInvitedUsers indexOfObjectPassingTest:
                     ^BOOL(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                         NSString *email1 = [obj valueForKey:@"email"];
                         NSString *email2 = user.email;
                         return [email1 isEqualToString:email2];
                     }];
    if (idx != NSNotFound) {
        [self.mutableInvitedUsers removeObjectAtIndex:idx];
        [self.binderView.usersCollectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:idx inSection:0]]];
    }
    
    [self.mutableInvitedUsers addObject:user];
    NSIndexPath *path = [NSIndexPath indexPathForItem:(self.mutableInvitedUsers.count - 1) inSection:0];
    [self.binderView.usersCollectionView insertItemsAtIndexPaths:@[path]];
    [self updateInvitedUsersHintLabel];
}

#pragma mark - MYPManageBinderUsersViewControllerDelegate

- (void)manageBinderUsersController:(UIViewController *)controller didRevokeAccessForUsers:(NSSet *)users {
    [self.mutableInvitedUsers removeObjectsInArray:users.allObjects];
    [self.binderView.usersCollectionView reloadData];
    [self showUsersCollectionView:self.mutableInvitedUsers.count > 0];
    [self updateInvitedUsersHintLabel];
}

#pragma mark - MYPColorPickerViewControllerDelegate

- (void)colorPickerViewController:(UIViewController *)controller didPickColor:(UIColor *)color {
    self.binderView.colorCircleView.circleColor = color;
}

#pragma mark - Action handlers & gestures

- (void)handleAddUserButtonClick:(id)sender {
    NSBundle *bundle = [NSBundle mainBundle];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MYPInviteUsersStoryboard" bundle:bundle];
    UIViewController *vc = [storyboard instantiateInitialViewController];
    if ([vc respondsToSelector:NSSelectorFromString(@"setDelegate:")]) {
        [vc setValue:self forKey:@"delegate"];
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)handleUserSettingsButtonClick:(id)sender {
    NSBundle *bundle = [NSBundle mainBundle];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MYPManageBinderUsersStoryboard" bundle:bundle];
    UIViewController *vc = [storyboard instantiateInitialViewController];
    if ([vc respondsToSelector:NSSelectorFromString(@"setDelegate:")]) {
        [vc setValue:self forKey:@"delegate"];
    }
    if ([vc respondsToSelector:NSSelectorFromString(@"setBinderUsers:")]) {
        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithSet:self.invitedUsers];
        [vc setValue:orderedSet forKey:@"binderUsers"];
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)handleNameContainerViewTap:(id)sender {
    if (!self.binderView.nameTextField.isFirstResponder) {
        [self.binderView.nameTextField becomeFirstResponder];
    }
}

- (void)handleDateContainerViewTap:(id)sender {
    BOOL hidden = self.binderView.datePicker.hidden;
    CGFloat alpha = hidden ? 1.0f : 0.0f;
    self.binderView.datePicker.alpha = alpha;
    [UIView animateWithDuration:0.25f animations:^{
        self.binderView.datePicker.hidden = !hidden;
    }];
}

- (void)handleColorContainerViewTap:(id)sender {
    NSBundle *bundle = [NSBundle mainBundle];
    UIStoryboard *storyborad = [UIStoryboard storyboardWithName:@"MYPColorPickerStoryboard" bundle:bundle];
    UINavigationController *navVC = [storyborad instantiateInitialViewController];
    UIViewController *vc = navVC.topViewController;
    if ([vc respondsToSelector:NSSelectorFromString(@"setDelegate:")]) {
        [vc setValue:self forKey:@"delegate"];
    }
    if ([vc respondsToSelector:NSSelectorFromString(@"setColor:")]) {
        [vc setValue:self.binderColor forKey:@"color"];
    }
    [self presentViewController:navVC animated:YES completion:nil];
}

#pragma mark - Private methods

- (void)updateInvitedUsersHintLabel {
    NSInteger count = self.mutableInvitedUsers.count;
    NSString *localizedString = NSLocalizedString(@"user(s) and you", nil);
    self.binderView.usersHintLabel.text = [NSString stringWithFormat:@"%li %@", (long)count, localizedString];
}

- (void)showUsersCollectionView:(BOOL)show {
    if (show) {
        self.binderView.usersCollectionView.hidden = NO;
        self.binderView.addUserLeftButton.hidden = YES;
        self.binderView.addUserRightButton.hidden = NO;
        self.binderView.userSettingsButton.hidden = NO;
    } else {
        self.binderView.usersCollectionView.hidden = YES;
        self.binderView.addUserLeftButton.hidden = NO;
        self.binderView.addUserRightButton.hidden = YES;
        self.binderView.userSettingsButton.hidden = YES;
    }
}

@end
