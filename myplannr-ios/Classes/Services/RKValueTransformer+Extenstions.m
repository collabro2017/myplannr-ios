//
//  RKValueTransformer+Extenstions.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 29/08/16.
//
//

#import <UIKit/UIKit.h>
#import "RKValueTransformer+Extenstions.h"

@implementation RKValueTransformer (Extenstions)

+ (instancetype)myp_colorTransformer {
    static RKValueTransformer *transformer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        BOOL (^validationBlock)(Class, Class) = ^BOOL(__unsafe_unretained Class sourceClass,
                                                      __unsafe_unretained Class destinationClass)
        {
            return ([sourceClass isSubclassOfClass:[NSString class]]
                    && [destinationClass isSubclassOfClass:[UIColor class]]);
        };
        
        BOOL (^transformationBlock)(id, id*, Class, NSError**) = ^BOOL(id inputValue,
                                                                       __autoreleasing id *outputValue,
                                                                       Class outputValueClass,
                                                                       NSError *__autoreleasing *error)
        {
            RKValueTransformerTestInputValueIsKindOfClass(inputValue, [NSString class], error);
            RKValueTransformerTestOutputValueClassIsSubclassOfClass(outputValueClass, [UIColor class], error);
            
            *outputValue = [UIColor myp_colorWithHexString:inputValue];
            return YES;
        };
        
        transformer = [RKBlockValueTransformer valueTransformerWithValidationBlock:validationBlock
                                                               transformationBlock:transformationBlock];
    });
    
    return transformer;
}

+ (instancetype)myp_inversedColorTransformer {
    static RKValueTransformer *transformer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        BOOL (^validationBlock)(Class, Class) = ^BOOL(__unsafe_unretained Class sourceClass,
                                                      __unsafe_unretained Class destinationClass)
        {
            return ([sourceClass isSubclassOfClass:[UIColor class]]
                    && [destinationClass isSubclassOfClass:[NSString class]]);
        };
        
        BOOL (^transformationBlock)(id, id*, Class, NSError**) = ^BOOL(id inputValue,
                                                                       __autoreleasing id *outputValue,
                                                                       Class outputValueClass,
                                                                       NSError *__autoreleasing *error)
        {
            RKValueTransformerTestInputValueIsKindOfClass(inputValue, [UIColor class], error);
            RKValueTransformerTestOutputValueClassIsSubclassOfClass(outputValueClass, [NSString class], error);
            
            UIColor *color = inputValue;
            *outputValue = [color myp_hexString];
            return YES;
        };
        
        transformer = [RKBlockValueTransformer valueTransformerWithValidationBlock:validationBlock
                                                               transformationBlock:transformationBlock];
    });
    
    return transformer;
}

#warning can be simplified to NSDateFormatter?
+ (instancetype)myp_dateTransformerWithDateFormat:(NSString *)format {
    BOOL (^validationBlock)(Class, Class) = ^BOOL(__unsafe_unretained Class sourceClass,
                                                  __unsafe_unretained Class destinationClass)
    {
        return ([sourceClass isSubclassOfClass:[NSString class]] && [destinationClass isSubclassOfClass:[NSDate class]]);
    };
    
    BOOL (^transformationBlock)(id, id*, Class, NSError**) = ^BOOL(id inputValue,
                                                                   __autoreleasing id *outputValue,
                                                                   Class outputValueClass,
                                                                   NSError *__autoreleasing *error)
    {
        RKValueTransformerTestInputValueIsKindOfClass(inputValue, [NSString class], error);
        RKValueTransformerTestOutputValueClassIsSubclassOfClass(outputValueClass, [NSDate class], error);
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = format;
        *outputValue = [formatter dateFromString:inputValue];
        
        return YES;
    };
    
    RKValueTransformer *transformer = [RKBlockValueTransformer valueTransformerWithValidationBlock:validationBlock
                                                                               transformationBlock:transformationBlock];
    return transformer;
}

#warning can be simplified to NSDateFormatter?
+ (instancetype)myp_inversedDateTransformerWithDateFormat:(NSString *)format {
    BOOL (^validationBlock)(Class, Class) = ^BOOL(__unsafe_unretained Class sourceClass,
                                                  __unsafe_unretained Class destinationClass)
    {
        return ([sourceClass isSubclassOfClass:[NSDate class]] && [destinationClass isSubclassOfClass:[NSString class]]);
    };
    
    BOOL (^transformationBlock)(id, id*, Class, NSError**) = ^BOOL(id inputValue,
                                                                   __autoreleasing id *outputValue,
                                                                   Class outputValueClass,
                                                                   NSError *__autoreleasing *error)
    {
        RKValueTransformerTestInputValueIsKindOfClass(inputValue, [NSDate class], error);
        RKValueTransformerTestOutputValueClassIsSubclassOfClass(outputValueClass, [NSString class], error);
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = format;
        *outputValue = [formatter stringFromDate:inputValue];
        
        return YES;
    };
    
    RKValueTransformer *transformer = [RKBlockValueTransformer valueTransformerWithValidationBlock:validationBlock
                                                                               transformationBlock:transformationBlock];
    return transformer;

}

@end
