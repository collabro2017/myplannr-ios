//
//  FCManagedServiceObject.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 06/02/2017.
//
//

#import <CoreData/CoreData.h>
#import "FCManagedObjectWithMapping.h"
#import "NSManagedObject+Extensions.h"

@interface FCManagedServiceObject : NSManagedObject<FCManagedObjectWithMapping>

@property (nonatomic, assign, readonly, getter=isSaved) BOOL saved;

- (instancetype)initWithContext:(NSManagedObjectContext *)context;

@end
