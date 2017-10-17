//
//  MYPAvatarData.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 23/08/16.
//
//

#import "MYPAvatarData.h"

@interface MYPAvatarData ()

@property (nonatomic, copy, readwrite) NSString *mimeType;
@property (nonatomic, copy, readwrite) NSString *originalFileName;
@property (nonatomic, copy, readwrite) NSString *fileName;
@property (nonatomic, copy, readwrite) NSString *uploadedURL;

@end

@implementation MYPAvatarData

+ (RKObjectMapping *)responseMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"content_type"      : @"mimeType",
                                                  @"original_filename" : @"originalFileName",
                                                  @"filename"          : @"fileName",
                                                  @"uploaded_url"      : @"uploadedURL"
                                                  }];
    return mapping;
}

@end
