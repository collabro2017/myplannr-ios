//
//  MYPGetUnlimitedAccessViewController.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 19/11/2016.
//
//

#import <StoreKit/StoreKit.h>
#import <CommonCrypto/CommonCrypto.h>
#import "MYPGetUnlimitedAccessViewController.h"
#import "MYPInAppProductCell.h"
#import "MYPUserProfile.h"
#import "MYPStoreManager.h"
#import "SVProgressHUD.h"

static NSString * const kProductCellIdentifier = @"ProductCell";

static CGFloat const kProductCellHeight = 55.0f;

@interface MYPGetUnlimitedAccessViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *products;

@end

@implementation MYPGetUnlimitedAccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.products = @[];
    
    self.tableView.backgroundColor = [UIColor myp_colorWithHexInt:0xF1F1F1];
    
    [self registerForNotifications];

    MYPStoreManager *storeManager = [MYPStoreManager sharedInstance];
    if (storeManager.canMakePayments) {
        [self.activityIndicator startAnimating];
        [storeManager fetchProductsList];
    } else {
        [self showCannotMakePaymentsAlert];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MYPInAppProductCell *cell = [tableView dequeueReusableCellWithIdentifier:kProductCellIdentifier
                                                                forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kProductCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self purchaseProductAtIndexPath:indexPath];
}

#pragma mark - Notifications

- (void)handleProductsFetchedNotification:(NSNotification *)notification {
    [self.activityIndicator stopAnimating];
    
    self.products = [MYPStoreManager sharedInstance].products;
    [self.tableView reloadData];
}

- (void)handleProductsFetchingErrorNotification:(NSNotification *)notification {
    [self.activityIndicator stopAnimating];
    
    NSString *s = @"Unable to load a list of available in-app purchases. Please try again later";
    NSString *errorMsg = NSLocalizedString(s, nil);
    [self dismissViewControllerAnimated:YES completion:^{
         [SVProgressHUD showErrorWithStatus:errorMsg];
    }];
}

- (void)handleProductPurchasedNotification:(NSNotification *)notification {
    [SVProgressHUD dismiss];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleProductPurchaseFailedNotification:(NSNotification *)notification {
    [SVProgressHUD dismiss];
    
    NSError *validationError = notification.userInfo[kMYPStoreManagerUserInfoValidationErrorKey];
    SKPaymentTransaction *failedTransaction = notification.userInfo[kMYPStoreManagerUserInfoTransactionKey];
    NSLog(@"Purchase failed: validationError=%@, transactionError=%@", validationError, failedTransaction.error);
    NSString *errorMsg = NSLocalizedString(@"Failed to purchase the selected product. Please try again later.", nil);
    if (validationError) {
        errorMsg = NSLocalizedString(@"Unable to validate your transaction's details. Please try again later.", nil);
    }
    
    [SVProgressHUD showErrorWithStatus:errorMsg];
}

#pragma mark - Action hanlders

- (IBAction)handleCancelBarButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)handleWhyToUpgradeBarButtonClick:(id)sender {
    NSString *title = NSLocalizedString(@"Why to upgrade?", nil);
    NSString *message = NSLocalizedString(@"Upgrade to get full access with unlimited binders, tabs and uploads!", nil);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Got it!", nil)
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)handleAboutIAPsButtonClick:(id)sender {
    NSString *title = NSLocalizedString(@"About IAPs", nil);
    NSString *path = [[NSBundle mainBundle] pathForResource:@"iaps_description" ofType:@"txt"];
    NSString *message = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Got it!", nil)
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Private methods

- (void)registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleProductsFetchedNotification:)
                                                 name:kMYPStoreManagerProductsFetchedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleProductsFetchingErrorNotification:)
                                                 name:kMYPStoreManagerProductsFetchingErrorNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleProductPurchasedNotification:)
                                                 name:kMYPStoreManagerProductPurchasedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleProductPurchaseFailedNotification:)
                                                 name:kMYPStoreManagerProductPurchaseFailedNotification
                                               object:nil];
}

- (void)configureCell:(MYPInAppProductCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SKProduct *product = self.products[indexPath.row];
    cell.mainLabel.text = product.localizedTitle;
    cell.secondaryLabel.text = product.localizedDescription;
    cell.rightLabel.text = [self formatPrice:product.price locale:product.priceLocale];
}

- (void)purchaseProductAtIndexPath:(NSIndexPath *)indexPath {
    [SVProgressHUD show];
    SKProduct *product = self.products[indexPath.row];
    NSString *email = [MYPUserProfile sharedInstance].currentUser.email;
    [[MYPStoreManager sharedInstance] purchaseProduct:product onBehalfOfUser:email];
}

- (NSString *)formatPrice:(NSDecimalNumber *)price locale:(NSLocale *)locale {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.formatterBehavior = NSNumberFormatterBehavior10_4;
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    numberFormatter.locale = locale;
    return [numberFormatter stringFromNumber:price];
}

- (void)showCannotMakePaymentsAlert {
    NSString *msg = NSLocalizedString(@"This device or account is restricted from accessing the App Store.", nil);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [alert addAction:action];
    
    UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    [controller presentViewController:controller animated:YES completion:nil];
}

@end
