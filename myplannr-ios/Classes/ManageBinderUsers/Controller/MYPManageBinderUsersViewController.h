//
//  MYPManageBinderUsersViewController.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 06/10/2016.
//
//

#import <UIKit/UIKit.h>
#import "UIViewController+Alerts.h"

@protocol MYPManageBinderUsersViewControllerDelegate <NSObject>

@optional
- (void)manageBinderUsersController:(UIViewController *)controller
            didRevokeAccessForUsers:(NSSet *)users;

@end

@interface MYPManageBinderUsersViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UIBarButtonItem *editBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelBarButtonItem;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *labelBottomBarItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *trashBottomBarItem;


@property (strong, nonatomic) NSOrderedSet *binderUsers; // MYPInvitedUser or MYPNonManagedInvitedUser

@property (weak, nonatomic) id<MYPManageBinderUsersViewControllerDelegate> delegate;

@end
