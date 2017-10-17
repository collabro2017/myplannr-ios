//
//  FCManagedObjectWithMapping.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 03/02/2017.
//
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@protocol FCManagedObjectWithMapping <NSObject>

+ (RKEntityMapping *)responseMappingForManagedObjectStore:(RKManagedObjectStore *)store;

@optional
+ (RKObjectMapping *)requestMappingForManagedObjectStore:(RKManagedObjectStore *)store;

@end
