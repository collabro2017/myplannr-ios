//
//  MYPBinderTabDetailsController.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 13/10/2016.
//
//

#import <UIKit/UIKit.h>
#import "MYPAlertsAwareViewController.h"
#import "MYPEditableCollectionView.h"
#import "MYPBinderTabDocumentsModel.h"

@class MYPBinderTab;

@interface MYPBinderTabDetailsController : MYPAlertsAwareViewController

/* Views */

@property (weak, nonatomic) IBOutlet MYPEditableCollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIView *placeholderView;
@property (weak, nonatomic) IBOutlet UILabel *placeholderPrimaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeholderSecondaryLabel;

@property (weak, nonatomic) IBOutlet UIButton *addDocumentButton;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *selectBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelBarButtonItem;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *labelBottomBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *trashBottomBarItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareBottomBarItem;

/* Data */

@property (strong, nonatomic) MYPBinderTabDocumentsModel *model;

@end
