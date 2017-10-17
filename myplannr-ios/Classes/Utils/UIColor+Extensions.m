//
//  UIColor+Extensions.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 24/08/16.
//
//

#import "UIColor+Extensions.h"

@implementation UIColor (Extensions)

+ (UIColor *)myp_colorWithHexInt:(int)hexColor {
    return [UIColor colorWithRed:((float)((hexColor & 0xFF0000) >> 16))/255.0
                           green:((float)((hexColor & 0xFF00) >> 8))/255.0
                            blue:((float)(hexColor & 0xFF))/255.0
                           alpha:1.0];
}

+ (UIColor *)myp_colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
}

+ (UIColor*)myp_colorWithHexString:(NSString *)hexString {
    NSString *cString = [hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].uppercaseString;
    // String should be 6 or 8 characters
    if (cString.length < 6) return [UIColor blackColor];
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if (cString.length != 6) return [UIColor blackColor];
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor myp_colorWithRed:r green:g blue:b];
}


- (NSString *)myp_hexString {
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}

#pragma mark - Theme colors

+ (UIColor *)myp_defaultNavigationBarColor {
    return [UIColor colorWithRed:(247.0f/255.0f) green:(247.0f/255.0f) blue:(247.0f/255.0f) alpha:1];
}

@end
