//
//  MYPBindersListViewController.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 19/09/16.
//
//

#import <UIKit/UIKit.h>
#import "MYPBindersFlowLayout.h"
#import "MYPAlertsAwareViewController.h"
#import "MYPBindersListModel.h"

@interface MYPBindersListViewController : MYPAlertsAwareViewController <UICollectionViewDataSource,
                                                                        MYPCenteredFlowLayoutDelegate>

@property (weak, nonatomic) IBOutlet UIView *placeholderView;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet MYPBindersFlowLayout *bindersFlowLayout;

@property (weak, nonatomic) IBOutlet UIButton *addBinderButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *createDocumentButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshBarButtonItem;

@property (strong, nonatomic) MYPBindersListModel *model;

@end
