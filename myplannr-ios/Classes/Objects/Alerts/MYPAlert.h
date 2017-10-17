//
//  MYPAlert.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 06/03/2017.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MYPAlertType) {
    MYPAlertTypeChatMessage = 1,
    MYPAlertTypeNewInvite = 2,
    MYPAlertTypeNewDocument = 3,
    MYPAlertTypeBinderChanged = 4,
    MYPAlertTypeNewTab = 5
};

@interface MYPAlert : NSObject

@property (strong, nonatomic, readonly) NSString *alertText;
@property (assign, nonatomic, readonly) MYPAlertType alertType;

- (instancetype)initWithAlertType:(MYPAlertType)type alertText:(NSString *)alertText NS_DESIGNATED_INITIALIZER;

@end
