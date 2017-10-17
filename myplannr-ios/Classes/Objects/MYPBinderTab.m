//
//  MYPBinderTab.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 29/08/16.
//
//

#import "MYPBinderTab.h"
#import "MYPDocument.h"
#import "MYPConstants.h"
#import "RKValueTransformer+Extenstions.h"

@implementation MYPBinderTab

@dynamic tabId;
@dynamic binderId;
@dynamic title;
@dynamic colorString;
@dynamic documents;

@synthesize color = _color;

- (instancetype)initWithTitle:(NSString *)title
                        color:(UIColor *)color
                     binderId:(NSNumber *)binderId
                      context:(NSManagedObjectContext *)context
{
    self = [super initWithContext:context];
    if (self) {
        self.title = title;
        self.color = color;
        self.binderId = binderId;
    }
    return self;
}

+ (RKEntityMapping *)responseMappingForManagedObjectStore:(RKManagedObjectStore *)store {
    RKEntityMapping *objectMapping = [super responseMappingForManagedObjectStore:store];
    [objectMapping addAttributeMappingsFromDictionary:@{
                                                        @"id"        : @"tabId",
                                                        @"binder_id" : @"binderId",
                                                        @"title"     : @"title",
                                                        @"color"     : @"colorString",
                                                        }];
    
    // Documents
    RKMapping *docMapping = [MYPDocument responseMappingForManagedObjectStore:store];
    RKRelationshipMapping *documentsMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"documents"
                                                                                          toKeyPath:@"documents"
                                                                                        withMapping:docMapping];
    [objectMapping addPropertyMapping:documentsMapping];
    
    objectMapping.identificationAttributes = @[@"tabId"];
    
    return objectMapping;
}

+ (RKObjectMapping *)requestMappingForManagedObjectStore:(RKManagedObjectStore *)store {
    RKObjectMapping *objectMapping = [[self responseMappingForManagedObjectStore:store] inverseMapping]; 
    return objectMapping;
}

- (UIColor *)color {
    return [UIColor myp_colorWithHexString:self.colorString];
}

- (void)setColor:(UIColor *)color {
    _color = color;
    [self setColorString:[color myp_hexString]];
}

// http://stackoverflow.com/questions/7385439/exception-thrown-in-nsorderedset-generated-accessors
- (void)addDocumentsObject:(MYPDocument *)value {
    NSMutableOrderedSet *tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.documents];
    [tempSet addObject:value];
    self.documents = tempSet;
}

#pragma mark - Sorting

- (NSComparisonResult)compare:(MYPBinderTab *)otherObject {
    NSDate *d1 = self.createdAt;
    NSDate *d2 = otherObject.createdAt;
    return [d1 compare:d2];
}

@end
