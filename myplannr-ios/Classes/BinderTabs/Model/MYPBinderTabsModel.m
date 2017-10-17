//
//  MYPBinderTabsModel.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 20/02/2017.
//
//

#import "MYPBinderTabsModel.h"
#import "MYPDocument.h"
#import "MYPFileUtils.h"

@interface MYPBinderTabsModel ()

@property (strong, nonatomic, readwrite) MYPBinder *binder;

@property (strong, nonatomic) NSMutableArray<MYPBinderTab *> *mutableTabs;

@end

@implementation MYPBinderTabsModel

- (instancetype)initWithBinder:(MYPBinder *)binder {
    self = [super init];
    if (self) {
        self.binder = binder;
    }
    return self;
}

#pragma mark - Public methods & properties

- (NSArray<MYPBinderTab *> *)tabs {
    return [NSArray arrayWithArray:self.mutableTabs];
}

- (void)loadTabsWithCompletionBlock:(void (^)(NSArray *, BOOL, NSError *))completion {
    MYPService *service = [MYPService sharedInstance];
    if (service.isNetworkReachable) {
        [service tabsForBinder:self.binder
                       handler:^(NSArray *results, NSData *responseData, NSInteger statusCode, NSError *error)
         {
             if (error) {
                 [self.mutableTabs removeAllObjects];
             } else {
                 self.mutableTabs = results.mutableCopy;
                 [self.mutableTabs sortUsingSelector:@selector(compare:)];
             }
             
             if (completion) {
                 completion(self.tabs, NO, error);
             }
         }];
    } else {
        NSError *error = nil;
        NSFetchRequest *fetchRequest = [MYPBinderTab fc_fetchRequest];
        fetchRequest.returnsObjectsAsFaults = NO;
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"binderId = %@", self.binder.binderId];
        NSManagedObjectContext *context = service.managedObjectContext;
        NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
        self.mutableTabs = results.mutableCopy;
        [self.mutableTabs sortUsingSelector:@selector(compare:)];
        
        if (completion) {
            completion(self.tabs, YES, error);
        }
    }
}

- (void)addTab:(MYPBinderTab *)tab {
    [self.mutableTabs addObject:tab];
    [self.mutableTabs sortUsingSelector:@selector(compare:)];
    
    SEL selector = @selector(model:didInsertItemsAtIndexPaths:);
    if ([self.delegate respondsToSelector:selector]) {
        NSInteger idx = [self.mutableTabs indexOfObject:tab];
        if (idx != NSNotFound) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:idx inSection:0];
            [self.delegate model:self didInsertItemsAtIndexPaths:@[path]];
        } else {
            NSLog(@"%s: object not found", __PRETTY_FUNCTION__);
        }
    }
}

- (void)updateTab:(MYPBinderTab *)tab {
    NSInteger index = [self.tabs indexOfObject:tab];
    if (index != NSNotFound) {
        SEL selector = @selector(model:didUpdateItemsAtIndexPaths:);
        if ([self.delegate respondsToSelector:selector]) {
            NSIndexPath *path = [NSIndexPath indexPathForItem:index inSection:0];
            [self.delegate model:self didUpdateItemsAtIndexPaths:@[path]];
        }
    }
}

- (void)deleteTabs:(NSArray *)tabsToRemove completionBlock:(void (^)(BOOL, NSArray *))completion {
    const NSInteger count = tabsToRemove.count;
    NSMutableArray *errors = [NSMutableArray array];
    __block NSInteger requestsHandled = 0;
    MYPService *service = [MYPService sharedInstance];
    for (MYPBinderTab *tab in tabsToRemove) {
        NSOrderedSet *documents = tab.documents;
        for (MYPDocument *doc in documents) {
            if (doc.isDownloaded) {
                NSURL *url = doc.downloadedDocumentURL;
                [MYPFileUtils removeFilesAtURLs:@[url] error:nil];
            }
        }
        
        [service deleteTab:tab handler:^(NSData *responseData, NSInteger statusCode, NSError *error)
         {
             requestsHandled++;
             
             if (error) {
                 [errors addObject:error];
             } else {
                 NSInteger idx = [self.tabs indexOfObject:tab];
                 if (idx != NSNotFound) {
                     [self.mutableTabs removeObjectAtIndex:idx];
                     
                     SEL selector = @selector(model:didDeleteItemsAtIndexPaths:);
                     if ([self.delegate respondsToSelector:selector]) {
                         NSIndexPath *path = [NSIndexPath indexPathForRow:idx inSection:0];
                         [self.delegate model:self didDeleteItemsAtIndexPaths:@[path]];
                     }
                 } else {
                     NSLog(@"%s: removing tab wasn't found in the model's dataset", __PRETTY_FUNCTION__);
                 }
             }
             
             if (requestsHandled == count) {
                 completion(errors.count == 0, errors);
             }
         }];
    }
}

@end
