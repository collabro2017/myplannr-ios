//
//  MYPServiceObject.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 11/11/2016.
//
//

#import <Foundation/Foundation.h>
#import "FCManagedServiceObject.h"

@interface MYPServiceObject : FCManagedServiceObject

@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *updatedAt;

@end
