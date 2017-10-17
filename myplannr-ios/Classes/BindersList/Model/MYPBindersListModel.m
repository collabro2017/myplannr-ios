//
//  MYPBindersListModel.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 06/02/2017.
//
//

#import "MYPBindersListModel.h"
#import "MYPBinder.h"
#import "MYPUser.h"
#import "MYPService.h"

@interface MYPBindersListModel ()

@property (nonatomic, strong) NSMutableArray<MYPBinder *> *mutableBinders;
@property (nonatomic, assign, readwrite, getter=isLoadingBinders) BOOL loadingBinders;

@end

@implementation MYPBindersListModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.mutableBinders = [NSMutableArray array];
        self.loadingBinders = NO;
    }
    return self;
}

#pragma mark - Public methods & properties

- (NSArray<MYPBinder *> *)binders {
    return [NSArray arrayWithArray:self.mutableBinders];
}

- (NSArray *)bindersWithFullAccess {
    BOOL (^block)(id, NSDictionary *) = ^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings)
    {
        MYPBinder *b = evaluatedObject;
        return (b.isOwner || b.accessType == MYPAccessTypeFull);
    };
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:block];
    NSArray *array = [self.mutableBinders filteredArrayUsingPredicate:predicate];
    return array;
}

- (void)addBinder:(MYPBinder *)binder {
    [self.mutableBinders addObject:binder];
    [self.mutableBinders sortUsingSelector:@selector(compare:)];
    
    if ([self.delegate respondsToSelector:@selector(model:didInsertItemsAtIndexPaths:)]) {
        NSInteger index = [self.mutableBinders indexOfObject:binder];
        if (index != NSNotFound) {
            NSIndexPath *path = [NSIndexPath indexPathForItem:index inSection:0];
            [self.delegate model:self didInsertItemsAtIndexPaths:@[path]];
        }
    }
}

- (void)deleteBinder:(MYPBinder *)binder {
    NSInteger index = [self.mutableBinders indexOfObject:binder];
    if (index != NSNotFound) {
        [self.mutableBinders removeObjectAtIndex:index];
        
        if ([self.delegate respondsToSelector:@selector(model:didDeleteItemsAtIndexPaths:)]) {
            NSIndexPath *path = [NSIndexPath indexPathForItem:index inSection:0];
            [self.delegate model:self didDeleteItemsAtIndexPaths:@[path]];
        }
    }
}

- (void)updateBinder:(MYPBinder *)binder {
    NSInteger index = [self.mutableBinders indexOfObject:binder];
    if (index == NSNotFound) {
        NSLog(@"%s: %@", __PRETTY_FUNCTION__, @"index not found");
        return;
    }
    
    NSIndexPath *path = [NSIndexPath indexPathForItem:index inSection:0];
    [self.mutableBinders sortUsingSelector:@selector(compare:)];
    NSInteger newIndex = [self.mutableBinders indexOfObject:binder];
    if (newIndex == index) {
        if ([self.delegate respondsToSelector:@selector(model:didUpdateItemsAtIndexPaths:)]) {
            [self.delegate model:self didUpdateItemsAtIndexPaths:@[path]];
        }
    } else {
        SEL sel = @selector(model:didMoveItemFromIndexPath:toIndexPath:);
        if ([self.delegate respondsToSelector:sel]) {
            [self.mutableBinders sortUsingSelector:@selector(compare:)];
            NSInteger newIndex = [self.mutableBinders indexOfObject:binder];
            NSIndexPath *newPath = [NSIndexPath indexPathForItem:newIndex inSection:0];
            [self.delegate model:self didMoveItemFromIndexPath:path toIndexPath:newPath];
        }
    }
}

- (void)loadBindersWithCompletionBlock:(void (^)(NSArray *, BOOL, NSError *))completion {
    [self.mutableBinders removeAllObjects];
    self.loadingBinders = YES;
    MYPService *service = [MYPService sharedInstance];
    if (service.isNetworkReachable) {
        [service bindersWithHandler:^(NSArray *array, NSData *responseData, NSInteger statusCode, NSError *error)
        {
            if (error) {
                [self.mutableBinders removeAllObjects];
            } else {
                self.mutableBinders = array.mutableCopy;
            }
            
            self.loadingBinders = NO;
            
            if (completion) {
                completion(self.binders, NO, error);
            }
        }];
    } else {
        NSError *error = nil;
        NSFetchRequest *fetchRequest = [MYPBinder fc_fetchRequest];
        fetchRequest.returnsObjectsAsFaults = NO;
        NSManagedObjectContext *context = service.managedObjectContext;
        NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
        self.mutableBinders = results.mutableCopy;
        
        self.loadingBinders = NO;
        
        if (completion) {
            completion(results, YES, error);
        }
    }
}

#pragma mark - Private methods

- (void)setMutableBinders:(NSMutableArray<MYPBinder *> *)mutableBinders {
    _mutableBinders = mutableBinders;
    [_mutableBinders sortUsingSelector:@selector(compare:)];
}

@end
