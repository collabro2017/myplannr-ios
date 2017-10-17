//
//  MYPDocumentsPreviewViewController.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 19/10/2016.
//
//

#import <UIKit/UIKit.h>
#import "MYPAlertsAwareViewController.h"
#import "MYPBinderTabDocumentsModel.h"

@class MYPBinderTab;

@protocol MYPDocumentsPreviewViewControllerDelegate <NSObject>

@optional

- (void)documentsPreviewControllerDidModifyDocumentsList:(UIViewController *)controller;

@end

@interface MYPDocumentsPreviewViewController : MYPAlertsAwareViewController

/* View */

@property (weak, nonatomic) IBOutlet UIView *imageContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewAspectRationConstraint;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *optionsBarButtonItem;

/* Data */

@property (strong, nonatomic) MYPBinderTabDocumentsModel *model;
@property (nonatomic, assign) NSInteger selectedDocumentIndex;

@property (weak, nonatomic) id<MYPDocumentsPreviewViewControllerDelegate> delegate;

@end
