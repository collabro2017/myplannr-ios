//
//  MYPServiceObject.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 11/11/2016.
//
//

#import "MYPServiceObject.h"
#import "MYPConstants.h"
#import "RKValueTransformer+Extenstions.h"

@implementation MYPServiceObject

@dynamic createdAt;
@dynamic updatedAt;

+ (RKEntityMapping *)responseMappingForManagedObjectStore:(RKManagedObjectStore *)store {
    NSString *entityName = [self fc_entityName];
    RKEntityMapping *objectMapping = [RKEntityMapping mappingForEntityForName:entityName
                                                         inManagedObjectStore:store];
    
    RKValueTransformer *dateTransformer = [RKValueTransformer myp_dateTransformerWithDateFormat:kServerDateTimeFormat];
    
    // "created_at": NSString -> NSDate
    RKAttributeMapping *createdAtMapping = [RKAttributeMapping attributeMappingFromKeyPath:@"created_at"
                                                                                 toKeyPath:@"createdAt"];
    createdAtMapping.valueTransformer = dateTransformer;
    [objectMapping addPropertyMapping:createdAtMapping];
    
    // "updated_at": NSString -> NSDate
    RKAttributeMapping *updatedAtMapping = [RKAttributeMapping attributeMappingFromKeyPath:@"updated_at"
                                                                                 toKeyPath:@"updatedAt"];
    updatedAtMapping.valueTransformer = dateTransformer;
    [objectMapping addPropertyMapping:updatedAtMapping];
    
    return objectMapping;
}

@end
