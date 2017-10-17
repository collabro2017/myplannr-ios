//
//  MYPCreateBinderViewController.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 29/09/2016.
//
//

#import "MYPCreateBinderViewController.h"
#import "MYPConstants.h"
#import "SVProgressHUD.h"

@implementation MYPCreateBinderViewController

@dynamic binderView;
@dynamic invitedUsers;

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.model = [[MYPCreateBinderModel alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    
    (self.binderView.deleteBinderButton).hidden = YES;
}

#pragma mark - Button Handlers

- (IBAction)handleDoneBarButtonClick:(id)sender {
    if (![self validateInput]) {
        return;
    }
    
    [self createBinder];
}

- (IBAction)handleCancelBarButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private methods

- (void)createBinder {
    NSString *name = self.binderName;
    UIColor *color = self.binderColor;
    NSDate *date = self.eventdate;
    NSSet *users = self.invitedUsers;
    
    [SVProgressHUD show];
    [self.model createBinderWithName:name
                               color:color
                                date:date
                               users:users
                          completion:^(MYPBinder *binder, NSError *error)
     {
         [SVProgressHUD dismiss];
         
         if (error) {
             NSNumber *statusCode = error.userInfo[FCHttpStatusKey];
             if (statusCode.integerValue == kHttpCode402PaymentRequired) {
                 [self showPaymentRequiredAlert];
             } else {
                 NSString *errorStatus = NSLocalizedString(@"Failed to create binder. Please try again later.", nil);
                 [SVProgressHUD showErrorWithStatus:errorStatus];
             }
             return;
         }
         
         void (^dismissCompletion)(void) = ^void(void)  {
             SEL selector = @selector(createBinderViewController:didCreateBinder:);
             if ([self.delegate respondsToSelector:selector]) {
                 [self.delegate createBinderViewController:self didCreateBinder:binder];
             }
         };
         
         [self dismissViewControllerAnimated:YES completion:dismissCompletion];
     }];
}

- (void)showPaymentRequiredAlert {
    NSString *title = NSLocalizedString(@"Unable to create Binder", nil);
    NSString *msg = NSLocalizedString(@"Please upgrade to get unlimited access.", nil);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    void (^actionHandler)(UIAlertAction*) = ^(UIAlertAction * _Nonnull action) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MYPGetUnlimitedAccessStoryboard"
                                                             bundle:[NSBundle mainBundle]];
        UIViewController *vc = [storyboard instantiateInitialViewController];
        [self presentViewController:vc animated:YES completion:nil];
    };
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Upgrade", nil)
                                                     style:UIAlertActionStyleDefault
                                                   handler:actionHandler];
    [alert addAction:action];
    
    action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                      style:(UIAlertActionStyleCancel)
                                    handler:nil];
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
