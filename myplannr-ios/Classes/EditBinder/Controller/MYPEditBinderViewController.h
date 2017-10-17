//
//  MYPEditBinderViewController.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 29/09/2016.
//
//

#import <UIKit/UIKit.h>
#import "MYPBaseCreateEditBinderViewController.h"

@class MYPBinder;

@protocol MYPEditBinderViewControllerDelegate <NSObject>

@optional
- (void)editBinderViewController:(UIViewController *)controller didFinishEditingBinder:(MYPBinder *)binder;

- (void)editBinderViewController:(UIViewController *)controller didRemoveBinder:(MYPBinder *)binder;

@end

@interface MYPEditBinderViewController : MYPBaseCreateEditBinderViewController

/* Views */

@property (weak, nonatomic) IBOutlet MYPCreateOrEditBinderView *binderView;

/* Data */

@property (strong, nonatomic) MYPBinder *editingBinder;

@property (weak, nonatomic) id<MYPEditBinderViewControllerDelegate> delegate;

@end
