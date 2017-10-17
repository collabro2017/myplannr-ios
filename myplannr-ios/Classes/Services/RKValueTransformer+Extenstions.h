//
//  RKValueTransformer+Extenstions.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 29/08/16.
//
//

#import <RKValueTransformers/RKValueTransformers.h>

@interface RKValueTransformer (Extenstions)

+ (instancetype)myp_colorTransformer; // NSStrning -> UIColor
+ (instancetype)myp_inversedColorTransformer; // UIColor -> NSString

+ (instancetype)myp_dateTransformerWithDateFormat:(NSString *)format; // NSString -> NSDate
+ (instancetype)myp_inversedDateTransformerWithDateFormat:(NSString *)format; // NSDate -> NSString

@end
