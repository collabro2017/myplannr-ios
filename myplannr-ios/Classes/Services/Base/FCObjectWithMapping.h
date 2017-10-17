//
//  FCObjectWithMapping.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 22/08/16.
//
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@protocol FCObjectWithMapping <NSObject>

+ (RKObjectMapping *)responseMapping;

@optional
+ (RKObjectMapping *)requestMapping;

@end
