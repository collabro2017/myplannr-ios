//
//  MYPBinderTab.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 29/08/16.
//
//

#import "MYPServiceObject.h"

@class MYPDocument;

@interface MYPBinderTab : MYPServiceObject

@property (nonatomic, strong) NSNumber *tabId;
@property (nonatomic, strong) NSNumber *binderId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *colorString;
@property (nonatomic, strong) NSOrderedSet<MYPDocument *> *documents;

// Transient properties (not persisted to CoreData)

@property (nonatomic, strong) UIColor *color;

- (instancetype)initWithTitle:(NSString *)title
                        color:(UIColor *)color
                     binderId:(NSNumber *)binderId
                      context:(NSManagedObjectContext *)context;

@end

@interface MYPBinderTab (CoreDataGeneratedAccessors)

- (void)insertObject:(MYPDocument *)value inDocumentsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromDocumentsAtIndex:(NSUInteger)idx;
- (void)insertDocuments:(NSArray<MYPDocument *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeDocumentsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInDocumentsAtIndex:(NSUInteger)idx withObject:(MYPDocument *)value;
- (void)replaceDocumentsAtIndexes:(NSIndexSet *)indexes withDocuments:(NSArray<MYPDocument *> *)values;
- (void)addDocumentsObject:(MYPDocument *)value;
- (void)removeDocumentsObject:(MYPDocument *)value;
- (void)addDocuments:(NSOrderedSet<MYPDocument *> *)values;
- (void)removeDocuments:(NSOrderedSet<MYPDocument *> *)values;

@end

