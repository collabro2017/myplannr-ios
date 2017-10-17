//
//  MYPChatViewController.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 27/12/2016.
//
//

#import "MYPChatViewController.h"
#import "MYPService.h"
#import "SVProgressHUD.h"
#import "MYPConstants.h"
#import "MYPChatMessageAlert.h"

static NSString * const kChatMessageCellReuseIdentifier = @"chatMessageCell";

@implementation MYPChatViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.doneBarButtonHidden = YES; // invisible by default
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showLoadEarlierMessagesHeader = YES;
    self.automaticallyScrollsToMostRecentMessage = YES;
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeMake(kChatAvatarSize, kChatAvatarSize);
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeMake(kChatAvatarSize, kChatAvatarSize);
    
    [self loadMessages];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self subscribeForAlertNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self unsubscribeForAlertNotifications];
}

#pragma mark - JSQMessagesViewController method overrides

- (BOOL)isOutgoingMessage:(id<JSQMessageData>)messageItem {
    return [self.model isOutgoingMessage:(MYPChatMessage *)messageItem];
}

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    [self.model sendMessage:text
                   senderId:senderId
          senderDisplayName:senderDisplayName
                       date:date
                 completion:^(MYPChatMessage *msg, BOOL success, NSError *error)
     {
         if (!success) {
             NSNumber *statusCode = error.userInfo[FCHttpStatusKey];
             NSString *localizedString = NSLocalizedString(@"Failed to deliver your message (error %lu)", nil);
             NSString *errorMsg = [NSString stringWithFormat:localizedString, statusCode.integerValue];
             [SVProgressHUD showErrorWithStatus:errorMsg];
             
             [self removeMessage:msg];
         }
     }];
    
    [self finishSendingMessageAnimated:YES];
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.model.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView
                                                                          cellForItemAtIndexPath:indexPath];
    cell.textView.textColor = [UIColor blackColor];
    return cell;
}

#pragma mark - JSQMessagesCollectionViewDataSource

- (NSString *)senderId {
    return self.model.senderID;
}

- (NSString *)senderDisplayName {
    return self.model.senderDisplayName;
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView
       messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.model.messages[indexPath.item];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath {
    [self.model.messages removeObjectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
             messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MYPChatMessage *message = [self.model.messages objectAtIndex:indexPath.item];
    if ([self isOutgoingMessage:message]) {
        return self.model.outgoingBubbleImageData;
    }
    
    return self.model.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
                    avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MYPChatMessage *message = [self.model.messages objectAtIndex:indexPath.item];
    JSQMessagesAvatarImage *avatarData = self.model.placeholderAvatarImage;
    [self.model avatarForMessage:message completion:^(UIImage *image, NSError *error)
     {
         avatarData.avatarImage = image;
         JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
         cell.avatarImageView.image = avatarData.avatarImage;
     }];
    
    return avatarData;
}

#pragma mark - Timestamps (as cell's top label)

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.model timestampForMessageAtIndexPath:indexPath];
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.model heightForCellTimestampLabelAtIndexPath:indexPath];
}

#pragma mark - Bubble top messages (senders' names)

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.model senderNameForMessageAtIndexPath:indexPath];
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.model heightForCellSenderNameLabelAtIndexPath:indexPath];
}

#pragma mark - Handling tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    [self loadMessages];
}

#pragma mark - Incomming messages handling

- (void)handleAlert:(MYPAlert *)alert {
    if (alert.alertType != MYPAlertTypeChatMessage) {
        [super handleAlert:alert];
        return;
    }
    
    NSNumber *currentBinderID = self.model.binderID;
    MYPChatMessageAlert *chatAlert = (MYPChatMessageAlert *)alert;
    MYPChatMessage *msg = chatAlert.message;
    if (![currentBinderID isEqual:msg.binderId]) {
        [super handleAlert:alert];
    } else {
        [self.model.messages addObject:msg];
        [self finishReceivingMessageAnimated:YES];
    }
}

#pragma mark - Action handlers

- (IBAction)handleDoneBarButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Public methods & properties

- (void)setDoneBarButtonHidden:(BOOL)doneBarButtonHidden {
    _doneBarButtonHidden = doneBarButtonHidden;
    
    self.navigationItem.rightBarButtonItem = doneBarButtonHidden ? nil : self.doneBarButton;
}

#pragma mark - Private methods

- (void)removeMessage:(MYPChatMessage *)msg {
    NSInteger idx = [self.model.messages indexOfObject:msg];
    if (idx != NSNotFound) {
        NSIndexPath *path = [NSIndexPath indexPathForItem:idx inSection:0];
        [self.model.messages removeObjectAtIndex:idx];
        [self.collectionView deleteItemsAtIndexPaths:@[path]];
    }
}

- (void)loadMessages {
    [SVProgressHUD show];
    [self.model loadMessages:^(BOOL success, BOOL allMessagesLoaded, NSError *error) {
        [SVProgressHUD dismiss];
        if (success) {
            [self.collectionView reloadData];
            
            self.showLoadEarlierMessagesHeader = !allMessagesLoaded;
            
            return;
        }
        
        NSString *msg = NSLocalizedString(@"Failed to load messages.", nil);
        [SVProgressHUD showErrorWithStatus:msg];
    }];
}

@end
