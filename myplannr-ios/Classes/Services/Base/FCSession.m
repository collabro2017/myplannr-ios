//
//  FCSession.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 25/02/2017.
//
//

#import "FCSession.h"

@interface FCSession ()

@property (nonatomic, copy, readwrite) NSString *authToken;

@end

@implementation FCSession

+ (instancetype)sessionWithAuthToken:(NSString *)token {
    return [[self alloc] initWithAuthToken:token];
}

- (instancetype)initWithAuthToken:(NSString *)token {
    self = [super init];
    if (self) {
        self.authToken = token;
    }
    return self;
}

@end
