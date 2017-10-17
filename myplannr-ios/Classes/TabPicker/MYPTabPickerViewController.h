//
//  MYPTabPickerViewController.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 16/11/2016.
//
//

#import <UIKit/UIKit.h>

@class MYPBinder;

@interface MYPTabPickerViewController : UIViewController

/* UI */

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *placeholderView;

/* Data */

@property (nonatomic, strong) MYPBinder *binder;

@property (nonatomic, strong) NSData *documentData;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *mimeType;

@end
