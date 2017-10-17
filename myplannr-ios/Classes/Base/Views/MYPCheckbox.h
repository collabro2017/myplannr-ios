//
//  MYPCheckbox.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 09/10/2016.
//
//

#import <UIKit/UIKit.h>

extern CGFloat const kCheckbkoxViewSize;

IB_DESIGNABLE
@interface MYPCheckbox : UIView

@property (strong, nonatomic, readonly) UIImageView *imageView;

@property (assign, nonatomic, getter=isChecked) IBInspectable BOOL checked;

@end
