//
//  NSError+Extensions.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 16/02/2017.
//
//

#import <Foundation/Foundation.h>

@interface NSError (Extensions)

+ (instancetype)errorWithDomain:(NSString *)domain code:(NSInteger)code localizedDescription:(NSString *)description;

+ (instancetype)errorWithUnderlyingError:(NSError *)underlyingError localizedDescription:(NSString *)description;

- (NSError *)errorWithUnderlyingError:(NSError *)underlyingError;
- (NSError *)errorByAddingUserInfo:(NSDictionary *)userInfo;

@end
