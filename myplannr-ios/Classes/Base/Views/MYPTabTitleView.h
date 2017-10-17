//
//  MYPTabTitleView.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 12/11/2016.
//
//

#import <UIKit/UIKit.h>

@interface MYPTabTitleView : UIView

@property (strong, nonatomic, readonly) UILabel *titleLabel;
@property (strong, nonatomic, readonly) UIView *colorView;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) UIColor *color;

@end
