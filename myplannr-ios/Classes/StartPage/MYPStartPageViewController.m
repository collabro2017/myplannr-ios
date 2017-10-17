//
//  MYPStartPageViewController.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 16/09/16.
//
//

#import "MYPStartPageViewController.h"
#import "MYPSignUpViewController.h"
#import "MYPSignInViewController.h"
#import "MYPRecoverPasswordViewController.h"
#import "MYPCompleteRegistrationViewController.h"
#import "MYPUserProfile.h"
#import "AppDelegate.h"

@interface MYPStartPageViewController () <MYPSignUpViewControllerDelegate,
                                          MYPSignInViewControllerDelegate,
                                          MYPRecoverPasswordViewControllerDelegate,
                                          MYPCompleteRegistrationViewControllerDelegate>

@end

@implementation MYPStartPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([MYPUserProfile sharedInstance].isAuthorized) {
        [self showBindersListController];
        return;
    }
    
    // Light status bar
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    // Transparent navigation bar
    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    
    self.navigationController.navigationBar.titleTextAttributes = @{
                                                                    NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                    };
    
    [self showSignUpController];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.childViewControllers.firstObject;
}

#pragma mark - MYPSignUpViewControllerDelegate

- (void)signUpController:(UIViewController *)controller didTapSignInButton:(id)button {
    UIViewController *vc = [self childViewControllerForClass:[MYPSignUpViewController class]];
    [self detachChildViewController:vc];
    [self showSignInController];
}

- (void)signUpController:(UIViewController *)controller didRegisterUser:(MYPUser *)user {
    UIViewController *vc = [self childViewControllerForClass:[MYPSignUpViewController class]];
    [self detachChildViewController:vc];
    [self showCompleteRegistrationController];
    
    [AppDelegate startSessionWithUser:user];
}

#pragma mark - MYPSignInViewControllerDelegate

- (void)signInController:(UIViewController *)controller didTapSignUpButton:(id)button {
    UIViewController *vc = [self childViewControllerForClass:[MYPSignInViewController class]];
    [self detachChildViewController:vc];
    [self showSignUpController];
}

- (void)signInController:(UIViewController *)controller didTapRecoverPasswordButton:(id)button {
    UIViewController *vc = [self childViewControllerForClass:[MYPSignInViewController class]];
    [self detachChildViewController:vc];
    [self showRecoverPasswordController];
}

- (void)signInController:(UIViewController *)controller didAuthorizeUser:(MYPUser *)user {
    [self showBindersListController];
    
    [AppDelegate startSessionWithUser:user];
}

#pragma mark - MYPRecoverPasswordViewControllerDelegate

- (void)recoverPasswordControllerShouldDismiss:(UIViewController *)controller {
    UIViewController *vc = [self childViewControllerForClass:[MYPRecoverPasswordViewController class]];
    [self detachChildViewController:vc];
    [self showSignInController];
}

#pragma mark - MYPCompleteRegistrationViewControllerDelegate

- (void)completeRegistrationControllerDidFinishUserSetup:(UIViewController *)controller {
    [self showBindersListController];
}

#pragma mark - Public methods

- (void)showSignUpController {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MYPSignUpStoryboard" bundle:nil];
    MYPSignUpViewController *vc = [sb instantiateInitialViewController];
    vc.delegate = self;
    [self attachChildViewController:vc];
}

- (void)showSignInController {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MYPSignInStoryboard" bundle:nil];
    MYPSignInViewController *vc = [sb instantiateInitialViewController];
    vc.delegate = self;
    [self attachChildViewController:vc];
}

- (void)showRecoverPasswordController {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MYPRecoverPasswordStoryboard" bundle:nil];
    MYPRecoverPasswordViewController *vc = [sb instantiateInitialViewController];
    vc.delegate = self;
    [self attachChildViewController:vc];
}

- (void)showCompleteRegistrationController {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MYPCompleteRegistrationStoryboard" bundle:nil];
    MYPCompleteRegistrationViewController *vc = [sb instantiateInitialViewController];
    vc.delegate = self;
    [self attachChildViewController:vc];
}

- (void)showBindersListController {
    // Rest theme colors to the default state
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor myp_defaultNavigationBarColor]];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.tintColor = [UIColor myp_colorWithHexInt:0x43434E];
    self.navigationController.navigationBar.shadowImage = nil;
    self.navigationController.navigationBar.titleTextAttributes = @{
                                                                    NSForegroundColorAttributeName : [UIColor myp_colorWithHexInt:0x95989A]
                                                                    };

    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MYPBindersListStoryboard"
                                                         bundle:[NSBundle mainBundle]];
    UIViewController *controller = [storyboard instantiateInitialViewController];
    [self.navigationController setViewControllers:@[controller] animated:YES];
    
    self.navigationItem.title = controller.title;
}

#pragma mark - Private methods

- (void)attachChildViewController:(UIViewController *)viewController {
    [self addChildViewController:viewController];
    [self.view addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
    
    self.navigationItem.title = viewController.title;
}

- (void)detachChildViewController:(UIViewController *)viewController {
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
    
    self.navigationItem.title = nil;
}

- (UIViewController *)childViewControllerForClass:(Class)class {
    NSArray *childControllers = self.childViewControllers;
    for (UIViewController *vc in childControllers) {
        if ([vc isMemberOfClass:class]) {
            [self detachChildViewController:vc];
            return vc;
        }
    }
    return nil;
}

@end
