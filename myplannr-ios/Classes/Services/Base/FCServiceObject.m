//
//  FCServiceObject.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 06/02/2017.
//
//

#import "FCServiceObject.h"

@implementation FCServiceObject

+ (RKObjectMapping *)responseMapping {
    @throw [NSException exceptionWithName:@"FCServiceObject: responseMapping not overriden"
                                   reason:@"This class and its methods shouldn't be used directly"
                                 userInfo:nil];
}

@end
