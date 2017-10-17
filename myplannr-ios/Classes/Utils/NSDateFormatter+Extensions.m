//
//  NSDateFormatter+Extensions.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 11/02/2017.
//
//

#import "NSDateFormatter+Extensions.h"
#import "MYPConstants.h"

@implementation NSDateFormatter (Extensions)

+ (NSDateFormatter *)myp_clientDateFormatter {
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = kClientDateFormat;
    });
    return formatter;
}

+ (NSDateFormatter *)myp_serverDateFormatter {
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = kServerDateFormat;
    });
    return formatter;
}

+ (NSDateFormatter *)myp_serverDateTimeFormatter {
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = kServerDateTimeFormat;
    });
    return formatter;
}

@end
