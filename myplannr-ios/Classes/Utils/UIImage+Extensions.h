//
//  UIImage+Extensions.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 12/10/2016.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (Extensions)

+ (UIImage *)myp_imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

+ (UIImage *)myp_imageWithColor:(UIColor *)color andSize:(CGSize)size;

- (UIImage *)myp_circleImage;

- (UIImage *)myp_normalizedImage;

@end
