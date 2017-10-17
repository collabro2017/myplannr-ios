//
//  MYPTooBigDocumentWarningAlert.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 16/11/2016.
//
//

#import <UIKit/UIKit.h>

@interface MYPTooBigDocumentWarningAlert : UIAlertController

+ (instancetype)alertWithDocumentSizeLimit:(NSInteger)limitInMB;

@end
