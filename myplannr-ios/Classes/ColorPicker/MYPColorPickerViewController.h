//
//  MYPColorPickerViewController.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 30/05/2017.
//
//

#import <UIKit/UIKit.h>
#import "HRColorPickerView.h"

@protocol MYPColorPickerViewControllerDelegate <NSObject>

- (void)colorPickerViewController:(UIViewController *)controller didPickColor:(UIColor *)color;

@end

@interface MYPColorPickerViewController : UIViewController

@property (weak, nonatomic) IBOutlet HRColorPickerView *colorPickerView;


@property (nonatomic, weak) id<MYPColorPickerViewControllerDelegate> delegate;
@property (nonatomic, strong) UIColor* color;

@end
