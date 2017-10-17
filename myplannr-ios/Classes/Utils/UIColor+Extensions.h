//
//  UIColor+Extensions.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 24/08/16.
//
//

#import <UIKit/UIKit.h>

@interface UIColor (Extensions)

+ (UIColor *)myp_colorWithHexInt:(int) hexColor;

+ (UIColor *)myp_colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;

+ (UIColor *)myp_colorWithHexString:(NSString *)hexString;

- (NSString *)myp_hexString;

#pragma mark - Theme colors

+ (UIColor *)myp_defaultNavigationBarColor;

@end
