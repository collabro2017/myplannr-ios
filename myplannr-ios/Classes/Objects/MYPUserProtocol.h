//
//  MYPUserProtocol.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 27/02/2017.
//
//

#import <Foundation/Foundation.h>

@protocol MYPUserProtocol <NSObject>

@required

@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *avatarUrl;

@property (nonatomic, strong, readonly) NSString *fullName;

@end
