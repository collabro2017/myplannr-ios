//
//  MYPColorPickerView.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 30/09/2016.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MYPColorPickerViewAlignment) {
    MYPColorPickerViewAlignmentLeft,
    MYPColorPickerViewAlignmentRight
};

IB_DESIGNABLE
@interface MYPCircleView : UIView

@property (nonatomic, strong) UIColor *circleColor;

- (instancetype)initWithColor:(UIColor *)color;

@end

IB_DESIGNABLE
@interface MYPColorPickerView : UIView

@property (nonatomic, assign) IBInspectable CGFloat circleItemSize;
@property (nonatomic, assign) IBInspectable CGFloat circleItemMargin;

@property (nonatomic, strong, readonly) NSArray<UIColor*> *colors;
@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, assign) NSInteger selectedColorIndex;

@property (nonatomic, assign) MYPColorPickerViewAlignment alignment;

+ (instancetype)colorPickerViewWithColors:(NSArray<UIColor*> *)colors;
- (instancetype)initWithColors:(NSArray<UIColor*> *)colors;

@end
