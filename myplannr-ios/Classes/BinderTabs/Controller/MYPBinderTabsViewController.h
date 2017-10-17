//
//  MYPBinderTabsViewController.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 11/10/2016.
//
//

#import <UIKit/UIKit.h>
#import "MYPAlertsAwareViewController.h"
#import "MYPBinderTabsModel.h"

@interface MYPBinderTabsViewController : MYPAlertsAwareViewController

/* Views */

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *addTabButton;

@property (weak, nonatomic) IBOutlet UIView *placeholderView;
@property (weak, nonatomic) IBOutlet UILabel *placeholderPrimaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeholderSecondaryLabel;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *editBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelBarButtonItem;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *labelBottomBarItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *trashBottomBarItem;

/* Data */

@property (strong, nonatomic) MYPBinder *binder;

@property (assign, nonatomic, getter=isCancelBarButtonHidden) BOOL cancelBarButtonHidden;

@end
