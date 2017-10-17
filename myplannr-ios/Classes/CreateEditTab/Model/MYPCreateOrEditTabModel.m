//
//  MYPCreateOrEditTabModel.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 20/02/2017.
//
//

#import "MYPCreateOrEditTabModel.h"

@interface MYPCreateOrEditTabModel ()

@property (strong, nonatomic, readwrite) MYPBinder *binder;
@property (strong, nonatomic, readwrite) MYPBinderTab *editingTab;

@end

@implementation MYPCreateOrEditTabModel

- (instancetype)initWithBinder:(MYPBinder *)binder {
    return [self initWithBinder:binder editingTab:nil];
}

- (instancetype)initWithBinder:(MYPBinder *)binder editingTab:(MYPBinderTab *)tab {
    self = [super init];
    if (self) {
        self.binder = binder;
        self.editingTab = tab;
    }
    return self;
}

#pragma mark - Public methods

- (void)createTabWithTitle:(NSString *)title
                     color:(UIColor *)color
                completion:(void (^)(MYPBinderTab *, NSError *))completion
{
    NSManagedObjectContext *context = [MYPService sharedInstance].managedObjectContext;
    MYPBinderTab *tab = [[MYPBinderTab alloc] initWithTitle:title
                                                      color:color
                                                   binderId:self.binder.binderId
                                                    context:context];
    
    [[MYPService sharedInstance] createTab:tab
                                   handler:^(MYPBinderTab *object, NSData *responseData, NSInteger statusCode, NSError *error)
     {
         if (error) {
             [context deleteObject:tab];
             [[MYPService sharedInstance] saveManagedObjectContextToPersistentStore];
             if (completion) {
                 completion(nil, error);
             }
             return;
         }
         
         if (completion) {
             completion(object, nil);
         }
     }];

}

- (void)updateTabWithTitle:(NSString *)title
                     color:(UIColor *)color
                completion:(void (^)(MYPBinderTab *, NSError *))completion
{
    if (self.editingTab == nil) {
        @throw [NSException exceptionWithName:[NSString stringWithFormat:@"%s: illegal state", __PRETTY_FUNCTION__]
                                       reason:@"self.editingTab == nil"
                                     userInfo:nil];
    }
    
    if (![self.editingTab.title isEqualToString:title]) self.editingTab.title = title;
    if (![self.editingTab.color isEqual:color]) self.editingTab.color = color;
    
    if (!self.editingTab.hasChanges) {
        return;
    }
    
    [[MYPService sharedInstance] updateTab:self.editingTab
                                   handler:^(MYPBinderTab *object, NSData *responseData, NSInteger statusCode, NSError *error)
     {
         if (completion) {
             completion(object, error);
         }
     }];
}

@end
