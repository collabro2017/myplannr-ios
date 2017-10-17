//
//  MYPChatViewController.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 27/12/2016.
//
//

#import <UIKit/UIKit.h>
#import "UIViewController+Alerts.h"
#import "JSQMessages.h"
#import "MYPChatModel.h"

@interface MYPChatViewController : JSQMessagesViewController

@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneBarButton;
@property (assign, nonatomic, getter=isDoneBarButtonHidden) BOOL doneBarButtonHidden;

@property (strong, nonatomic) MYPChatModel *model;

@end
