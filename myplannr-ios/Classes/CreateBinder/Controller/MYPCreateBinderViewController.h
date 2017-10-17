//
//  MYPCreateBinderViewController.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 29/09/2016.
//
//

#import <UIKit/UIKit.h>
#import "MYPBaseCreateEditBinderViewController.h"
#import "MYPCreateBinderModel.h"

@protocol MYPCreateBinderViewControllerDelegate <NSObject>

@optional
- (void)createBinderViewController:(UIViewController *)controller didCreateBinder:(MYPBinder *)binder;

@end

@interface MYPCreateBinderViewController : MYPBaseCreateEditBinderViewController

@property (weak, nonatomic) IBOutlet MYPCreateOrEditBinderView *binderView;


@property (strong, nonatomic) NSSet<MYPNonManagedInvitedUser*> *invitedUsers;

@property (strong, nonatomic) MYPCreateBinderModel *model;

@property (weak, nonatomic) id<MYPCreateBinderViewControllerDelegate> delegate;

@end
