//
//  MYPGetUnlimitedAccessViewController.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 19/11/2016.
//
//

#import <UIKit/UIKit.h>
#import "MYPAlertsAwareViewController.h"

@interface MYPGetUnlimitedAccessViewController : MYPAlertsAwareViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *whyToUpgradeBarButton;

@end
