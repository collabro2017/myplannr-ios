//
//  MYPTooBigDocumentWarningAlert.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 16/11/2016.
//
//

#import "MYPTooBigDocumentWarningAlert.h"

@implementation MYPTooBigDocumentWarningAlert

+ (instancetype)alertWithDocumentSizeLimit:(NSInteger)limitInMB {
    NSString *string = [NSString stringWithFormat:@"Maximum allowed size is %luMB. Please choose a new file matching this criteria.",
                        (long)limitInMB];
    NSString *title = NSLocalizedString(@"Document exceeds size limit", nil);
    NSString *message = NSLocalizedString(string, nil);
    MYPTooBigDocumentWarningAlert *alert = [MYPTooBigDocumentWarningAlert alertControllerWithTitle:title
                                                                                           message:message
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
    return alert;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [self addAction:action];
}

@end
