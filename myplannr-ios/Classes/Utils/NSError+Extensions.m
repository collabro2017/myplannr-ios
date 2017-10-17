//
//  NSError+Extensions.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 16/02/2017.
//
//

#import "NSError+Extensions.h"

@implementation NSError (Extensions)

+ (instancetype)errorWithDomain:(NSString *)domain code:(NSInteger)code localizedDescription:(NSString *)description {
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : (description) ? description : [NSNull null]};
    NSError *error = [NSError errorWithDomain:domain
                                         code:code
                                     userInfo:userInfo];
    return error;
}

+ (instancetype)errorWithUnderlyingError:(NSError *)underlyingError localizedDescription:(NSString *)description {
    NSError *newError = [NSError errorWithDomain:underlyingError.domain
                                            code:underlyingError.code
                            localizedDescription:description];
    newError = [newError errorWithUnderlyingError:underlyingError];
    return newError;
}

- (NSError *)errorWithUnderlyingError:(NSError *)underlyingError {
    if (!underlyingError || self.userInfo[NSUnderlyingErrorKey]) {
        return self;
    }
    
    NSMutableDictionary *mutableUserInfo = [self.userInfo mutableCopy];
    mutableUserInfo[NSUnderlyingErrorKey] = underlyingError;
    
    return [[NSError alloc] initWithDomain:self.domain code:self.code userInfo:[mutableUserInfo copy]];
}

- (NSError *)errorByAddingUserInfo:(NSDictionary *)userInfo {
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
    [info addEntriesFromDictionary:userInfo];
    return [[NSError alloc] initWithDomain:self.domain code:self.code userInfo:[info copy]];
}

@end
