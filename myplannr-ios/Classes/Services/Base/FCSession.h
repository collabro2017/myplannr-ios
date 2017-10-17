//
//  FCSession.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 25/02/2017.
//
//

#import <Foundation/Foundation.h>

@interface FCSession : NSObject

@property (nonatomic, copy, readonly) NSString *authToken;

+ (instancetype)sessionWithAuthToken:(NSString *)token;

- (instancetype)initWithAuthToken:(NSString *)token;

@end
