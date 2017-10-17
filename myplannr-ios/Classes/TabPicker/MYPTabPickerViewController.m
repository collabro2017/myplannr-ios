//
//  MYPTabPickerViewController.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 16/11/2016.
//
//

#import "MYPTabPickerViewController.h"
#import "MYPBinderTabCell.h"
#import "MYPBinderTab.h"
#import "MYPService.h"
#import "MYPConstants.h"
#import "SVProgressHUD.h"

static NSString * const kTabCellIdentifier = @"TabCell";

static CGFloat const kCellHeight = 55.0f;
static CGFloat const kColorImageSize = 25.0f;

@interface MYPTabPickerViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *tabs;

@end

@implementation MYPTabPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSAssert(self.binder, @"Illegal state: binder == nil");
    NSAssert(self.documentData, @"Illegal state: documentData == nil");
    NSAssert(self.fileName.length > 0, @"Illegal state: fileName is empty");
    NSAssert(self.mimeType.length > 0, @"Illegal state: mimeType is empty");
    
    self.tableView.backgroundColor = [UIColor myp_colorWithHexInt:0xF1F1F1];
    
    self.placeholderView.hidden = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadTabs];
    });
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tabs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTabCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTabCellIdentifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MYPBinderTab *tab = self.tabs[indexPath.row];
    [self uploadDocumentIntoTab:tab];
}

#pragma mark - Private methods

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    MYPBinderTab *tab = self.tabs[indexPath.row];
    cell.textLabel.text = tab.title;
    
    UIImage *image = [UIImage myp_imageWithColor:tab.color andSize:CGSizeMake(kColorImageSize, kColorImageSize)];
    cell.imageView.image = [image myp_circleImage];
}

- (void)loadTabs {
    [SVProgressHUD show];
    [[MYPService sharedInstance] tabsForBinder:self.binder
                                       handler:^(NSArray *object, NSData *responseData, NSInteger statusCode, NSError *error)
    {
        [SVProgressHUD dismiss];
        
        if (error) {
            NSString *errorMsg = NSLocalizedString(@"Failed to load tabs. Please try again later.", nil);
            [SVProgressHUD showErrorWithStatus:errorMsg];
            self.tabs = nil;
        } else {
            self.tabs = [object sortedArrayUsingSelector:@selector(compare:)];
        }
        
        self.placeholderView.hidden = (self.tabs.count > 0);
        
        [self.tableView reloadData];
    }];
}

- (void)uploadDocumentIntoTab:(MYPBinderTab *)tab {
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationItem.hidesBackButton = YES;
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Uploading your document...", nil)];
    [[MYPService sharedInstance] uploadDocument:self.documentData
                                       fileName:self.fileName
                                       mimeType:self.mimeType
                                            tab:tab
                                        handler:^(MYPDocument *object, NSData *responseData, NSInteger statusCode, NSError *error)
     {
         [SVProgressHUD dismiss];
         self.navigationController.interactivePopGestureRecognizer.enabled = YES;
         self.navigationItem.hidesBackButton = NO;
         
         if (error) {
             if (statusCode == kHttpCode402PaymentRequired) {
                 [self showPaymentRequiredAlert];
             } else {
                 NSString *string = @"Failed to upload the selected document to our servers. Please try again later.";
                 NSString *errorMsg = NSLocalizedString(string, nil);
                 [SVProgressHUD showErrorWithStatus:errorMsg];
             }
             return;
         }
         
         NSString *successMsg = NSLocalizedString(@"Done!", nil);
         [SVProgressHUD showSuccessWithStatus:successMsg];
         
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [self dismissViewControllerAnimated:YES completion:^{
                 id<UIApplicationDelegate> applicationDelegate = [UIApplication sharedApplication].delegate;
                 UIViewController *rootViewController =  applicationDelegate.window.rootViewController;
                 if ([rootViewController respondsToSelector:@selector(popToRootViewControllerAnimated:)]) {
                     [((UINavigationController *)rootViewController) popToRootViewControllerAnimated:YES];
                 }
             }];
         });
     }];
}

- (void)showPaymentRequiredAlert {
    NSString *title = NSLocalizedString(@"Unable to create Document", nil);
    NSString *msg = NSLocalizedString(@"Please upgrade to get unlimited access.", nil);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    void (^handler)(UIAlertAction*) = ^(UIAlertAction * _Nonnull action)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MYPGetUnlimitedAccessStoryboard"
                                                             bundle:[NSBundle mainBundle]];
        UIViewController *vc = [storyboard instantiateInitialViewController];
        [self presentViewController:vc animated:YES completion:nil];
    };
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Upgrade", nil)
                                                     style:UIAlertActionStyleDefault
                                                   handler:handler];
    [alert addAction:action];
    
    action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                      style:(UIAlertActionStyleCancel)
                                    handler:nil];
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
