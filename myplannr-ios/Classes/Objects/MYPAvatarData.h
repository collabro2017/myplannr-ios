//
//  MYPAvatarData.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 23/08/16.
//
//

#import <Foundation/Foundation.h>
#import "FCObjectWithMapping.h"

@interface MYPAvatarData : NSObject<FCObjectWithMapping>

@property (nonatomic, copy, readonly) NSString *mimeType;
@property (nonatomic, copy, readonly) NSString *originalFileName;
@property (nonatomic, copy, readonly) NSString *fileName;
@property (nonatomic, copy, readonly) NSString *uploadedURL;

@end
