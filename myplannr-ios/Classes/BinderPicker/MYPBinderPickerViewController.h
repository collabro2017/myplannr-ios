//
//  MYPBinderPickerViewController.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 15/11/2016.
//
//

#import <UIKit/UIKit.h>

@interface MYPBinderPickerViewController : UITableViewController

@property (nonatomic, strong) NSArray *binders;

@property (nonatomic, strong) NSData *documentData;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *mimeType;

@end
