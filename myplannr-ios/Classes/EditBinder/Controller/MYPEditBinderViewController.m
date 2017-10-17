//
//  MYPEditBinderViewController.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 29/09/2016.
//
//

#import "MYPEditBinderViewController.h"
#import "MYPEditBinderModel.h"
#import "MYPBinder.h"
#import "MYPInvitedUser.h"
#import "MYPService.h"
#import "SVProgressHUD.h"

@interface MYPEditBinderViewController ()

@property (nonatomic, strong) MYPEditBinderModel *model;

@end

@implementation MYPEditBinderViewController

@dynamic binderView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.model == nil) {
        NSLog(@"%s: model == nil", __PRETTY_FUNCTION__);
    } else {
        MYPBinder *binder = self.editingBinder;
        if (!binder.isOwner && binder.accessType == MYPAccessTypeReadOnly) {
            @throw [NSException exceptionWithName:@"Invalid state: user is not allowed to edit this binder"
                                           reason:[NSString stringWithFormat:@"Binder=%@", binder.name]
                                         userInfo:nil];
        }
    }
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    
    if (!self.editingBinder.isOwner) {
        self.binderView.deleteBinderButton.hidden = YES;
    }
    
    [self.binderView.deleteBinderButton addTarget:self
                                           action:@selector(handleDeleteBinderButtonClick:)
                                 forControlEvents:UIControlEventTouchUpInside];
    
    self.binderView.nameTextField.text = self.editingBinder.name;
    self.binderView.colorCircleView.circleColor = self.editingBinder.color;
    
    NSDate *eventDate = self.editingBinder.eventDate;
    self.binderView.dateTextField.text = [[NSDateFormatter myp_clientDateFormatter] stringFromDate:eventDate];
    self.binderView.datePicker.date = eventDate;
}

#pragma mark - Public methods & properties

- (void)setEditingBinder:(MYPBinder *)editingBinder {
    self.model = [[MYPEditBinderModel alloc] initWithBinder:editingBinder];
    self.invitedUsers = editingBinder.invitedUsers;
}

- (MYPBinder *)editingBinder {
    return self.model.editingBinder;
}

#pragma mark - Button Handlers & Gestures

- (IBAction)handleCancelBarButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)handleSaveBarButtonClick:(id)sender {
    if (![self validateInput]) {
        return;
    }
    
    NSString *name = self.binderName;
    UIColor *color = self.binderColor;
    NSDate *date = self.eventdate;
    NSSet *invitedUsers = self.invitedUsers;
    
    [SVProgressHUD show];
    [self.model updateBinderWithName:name
                               color:color
                           eventDate:date
                          completion:^(BOOL success, NSError *error)
     {
         if (!success) {
             [SVProgressHUD dismiss];
             [SVProgressHUD showErrorWithStatus:error.localizedDescription];
             return;
         }
         
         [self.model updateInvitedUsers:invitedUsers completion:^(BOOL success, NSArray *errors)
          {
              [SVProgressHUD dismiss];
              
              if (!success) {
                  NSError *error = errors.firstObject;
                  [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                  return;
              }
              
              void (^dismissCompletion)(void) = ^void(void)  {
                  SEL selector = @selector(editBinderViewController:didFinishEditingBinder:);
                  if ([self.delegate respondsToSelector:selector]) {
                      MYPBinder *binder = self.model.editingBinder;
                      [self.delegate editBinderViewController:self didFinishEditingBinder:binder];
                  }
              };
              
              [self dismissViewControllerAnimated:YES completion:dismissCompletion];
          }];
     }];
}

- (void)handleDeleteBinderButtonClick:(id)sender {
    NSString *title = NSLocalizedString(@"Your binder will be completely removed.", nil);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action;
    
    NSString *deleteTitle = NSLocalizedString(@"Delete", nil);
    action = [UIAlertAction actionWithTitle:deleteTitle
                                      style:UIAlertActionStyleDestructive
                                    handler:^(UIAlertAction * _Nonnull action) {
                                        [self deleteBinder];
                                    }];
    [alertController addAction:action];
    
    NSString *cancelTitle = NSLocalizedString(@"Cancel", nil);
    action = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:action];
    
    UIPopoverPresentationController *popoverController = alertController.popoverPresentationController;
    popoverController.sourceView = sender;
    popoverController.sourceRect = ((UIView *) sender).bounds;
    
    [alertController view];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Private methods

- (void)deleteBinder {
    void (^deleteCompletion)(void) = ^void(void) {
        if ([self.delegate respondsToSelector:@selector(editBinderViewController:didRemoveBinder:)]) {
            [self.delegate editBinderViewController:self didRemoveBinder:self.editingBinder];
        }
    };
    
    [SVProgressHUD show];
    [self.model deleteBinderWithCompletion:^(BOOL success, NSError *error) {
        [SVProgressHUD dismiss];
        
        if (!success) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }
        
        [self dismissViewControllerAnimated:YES completion:deleteCompletion];
    }];
}

@end
