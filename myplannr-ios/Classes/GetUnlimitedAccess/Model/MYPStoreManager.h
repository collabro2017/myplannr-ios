//
//  MYPStoreManager.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 23/11/2016.
//
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

extern NSString * const kMYPStoreManagerProductsFetchedNotification;
extern NSString * const kMYPStoreManagerProductsFetchingErrorNotification;

extern NSString * const kMYPStoreManagerProductPurchasedNotification;
extern NSString * const kMYPStoreManagerProductPurchaseFailedNotification;

extern NSString * const kMYPStoreManagerRefreshRequestCompletedNotification;
extern NSString * const kMYPStoreManagerRefreshRequestFailedNotification;

extern NSString * const kMYPStoreManagerUserInfoTransactionKey;
extern NSString * const kMYPStoreManagerUserInfoValidationErrorKey;
extern NSString * const kMYPStoreManagerUserInfoProductIdentifierKey;

@interface MYPStoreManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

+ (instancetype)sharedInstance;

@property (nonatomic, strong, readonly) NSArray<SKProduct *> *products;
@property (nonatomic, strong, readonly) NSArray<NSString *> *invalidProductIdentifiers;

@property (nonatomic, strong, readonly) NSURL *receiptURL;
@property (nonatomic, assign, readonly) BOOL canMakePayments;

- (void)fetchProductsList;
- (void)fetchProductsListForIDs:(NSSet<NSString *> *)productIDs;

- (void)purchaseProduct:(SKProduct *)product onBehalfOfUser:(NSString *)username;

- (void)refreshReceipt;

@end
