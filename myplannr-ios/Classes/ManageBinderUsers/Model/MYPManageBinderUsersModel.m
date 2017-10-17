//
//  MYPManageBinderUsersModel.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 17/02/2017.
//
//

#import "MYPManageBinderUsersModel.h"

@interface MYPManageBinderUsersModel ()

@property (strong, nonatomic, readwrite) NSMutableOrderedSet *mutableBinderUsers;

@end

@implementation MYPManageBinderUsersModel

- (instancetype)initWithUsers:(NSOrderedSet *)users {
    self = [super init];
    if (self) {
        self.mutableBinderUsers = users.mutableCopy;
    }
    return self;
}

#pragma mark - Public methods

- (void)removeUsers:(NSArray *)usersToRemove {
    if (usersToRemove.count > 0) {
        NSMutableArray *paths = [NSMutableArray arrayWithCapacity:usersToRemove.count];
        for (id obj in usersToRemove) {
            NSInteger idx = [self.mutableBinderUsers indexOfObject:obj];
            if (idx != NSNotFound) {
                [paths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
            }
        }
        
        [self.mutableBinderUsers removeObjectsInArray:usersToRemove];
        
        if ([self.delegate respondsToSelector:@selector(model:didDeleteItemsAtIndexPaths:)]) {
            [self.delegate model:self didDeleteItemsAtIndexPaths:paths];
        }
    }
}

- (NSOrderedSet *)binderUsers {
    return [NSOrderedSet orderedSetWithOrderedSet:self.mutableBinderUsers];
}

- (MYPAccessType)accessTypeForUser:(id)user {
    MYPAccessType accessType = ((NSNumber *)[user valueForKey:@"accessType"]).integerValue;
    return accessType;
}

- (NSString *)emailForUser:(id)user {
    NSString *email = [user valueForKey:@"email"];
    return email;
}

- (NSString *)fullNameForUser:(id)user {
    NSString *fullName = [user valueForKey:@"fullName"];
    if (fullName.length == 0) {
        NSString *email = [self emailForUser:user];
        fullName = email;
    }
    return fullName;
}

- (NSString *)avatarForUser:(id)user {
    NSString *avatar = [user respondsToSelector:NSSelectorFromString(@"avatarUrl")]
        ? [user valueForKey:@"avatarUrl"]
        : nil;
    return avatar;
}

- (NSData *)thumbnailForUser:(id)user {
    NSData *thumbnailImage = [user respondsToSelector:NSSelectorFromString(@"thumbnailImageData")]
        ? [user valueForKey:@"thumbnailImageData"]
        : nil;
    return thumbnailImage;
}

@end
