//
//  NSManagedObject+Extensions.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 06/02/2017.
//
//

#import "NSManagedObject+Extensions.h"

@implementation NSManagedObject (Extensions)

+ (NSString *)fc_entityName {
    NSString *entityName = nil;
    // iOS 10.0 or later
    if ([NSManagedObject respondsToSelector:@selector(entity)]) {
        NSEntityDescription *entity = [self entity];
        entityName = entity.name;
    }
    // Older versions
    else {
        entityName = NSStringFromClass([self class]);
    }
    return entityName;
}

+ (NSFetchRequest *)fc_fetchRequest {
    NSFetchRequest *fetchRequesst = nil;
    // iOS 10.0 or later
    if ([NSManagedObject respondsToSelector:@selector(fetchRequest)]) {
        fetchRequesst = [self fetchRequest];
    }
    // Older versions
    else {
        NSString *entityName = [self fc_entityName];
        fetchRequesst = [NSFetchRequest fetchRequestWithEntityName:entityName];
    }
    return fetchRequesst;
}

@end
