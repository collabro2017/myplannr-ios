//
//  NSDateFormatter+Extensions.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 11/02/2017.
//
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (Extensions)

+ (NSDateFormatter *)myp_clientDateFormatter;

+ (NSDateFormatter *)myp_serverDateFormatter;

+ (NSDateFormatter *)myp_serverDateTimeFormatter;

@end
