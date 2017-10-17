//
//  MYPStoreManager.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 23/11/2016.
//
//

#import <CommonCrypto/CommonCrypto.h>
#import <StoreKit/StoreKit.h>
#import "MYPStoreManager.h"
#import "MYPService.h"

NSString * const kMYPStoreManagerProductsFetchedNotification = @"kMYPStoreManagerProductsFetchedNotification";
NSString * const kMYPStoreManagerProductsFetchingErrorNotification = @"kMYPStoreManagerProductsFetchingErrorNotification";

NSString * const kMYPStoreManagerProductPurchasedNotification = @"kMYPStoreManagerProductPurchasedNotification";
NSString * const kMYPStoreManagerProductPurchaseFailedNotification = @"kMYPStoreManagerProductPurchaseFailedNotification";

NSString * const kMYPStoreManagerRefreshRequestCompletedNotification = @"kMYPStoreManagerRefreshRequestCompletedNotification";
NSString * const kMYPStoreManagerRefreshRequestFailedNotification = @"kMYPStoreManagerRefreshRequestFailedNotification";

NSString * const kMYPStoreManagerUserInfoTransactionKey = @"store_manager.transaction";
NSString * const kMYPStoreManagerUserInfoValidationErrorKey = @"store_manager.validation_error";
NSString * const kMYPStoreManagerUserInfoProductIdentifierKey = @"store_manager.product_id";

static NSString * const kProductIDsPlistFilename = @"product_ids";

@interface MYPStoreManager ()

@property (nonatomic, strong, readwrite) NSArray<SKProduct *> *products;
@property (nonatomic, strong, readwrite) NSArray<NSString *> *invalidProductIdentifiers;

@property (nonatomic, strong) SKProductsRequest *productsRequest;

@property (nonatomic, strong) SKReceiptRefreshRequest *refreshRequest;

@end

@implementation MYPStoreManager

+ (instancetype)sharedInstance {
    static MYPStoreManager * _sharedInstance;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];;
    });
    return _sharedInstance;
}

#pragma mark - Public methods

- (BOOL)canMakePayments {
    return [SKPaymentQueue canMakePayments];
}

- (NSURL *)receiptURL {
    NSURL *receiptURL = [NSBundle mainBundle].appStoreReceiptURL;
    return receiptURL;
}

- (void)fetchProductsList {
    NSURL *url = [[NSBundle mainBundle] URLForResource:kProductIDsPlistFilename withExtension:@"plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:url.path] == NO) {
        NSLog(@"%s: file doesn't exist at path %@", __PRETTY_FUNCTION__, url);
        [[NSNotificationCenter defaultCenter] postNotificationName:kMYPStoreManagerProductsFetchingErrorNotification
                                                            object:self];
        return;
    }
    
    NSArray *productIdentifiers = [NSArray arrayWithContentsOfURL:url];
    NSSet *idsSet = [NSSet setWithArray:productIdentifiers];
    [self fetchProductsListForIDs:idsSet];
}

- (void)fetchProductsListForIDs:(NSSet<NSString *> *)productIDs {
    if ([self canMakePayments] == NO) {
        NSLog(@"%s: [SKPaymentQueue canMakePayments] returned NO", __PRETTY_FUNCTION__);
        [[NSNotificationCenter defaultCenter] postNotificationName:kMYPStoreManagerProductsFetchingErrorNotification
                                                            object:self];
        return;
    }
    
    if (productIDs.count == 0) {
        NSLog(@"%s: the list if IDs is empty or nil", __PRETTY_FUNCTION__);
        [[NSNotificationCenter defaultCenter] postNotificationName:kMYPStoreManagerProductsFetchingErrorNotification
                                                            object:self];
        return;
    }
    
    self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIDs];
    self.productsRequest.delegate = self;
    [self.productsRequest start];
}

- (void)purchaseProduct:(SKProduct *)product onBehalfOfUser:(NSString *)username {
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    payment.simulatesAskToBuyInSandbox = YES;
    payment.applicationUsername = [self hashedValueForAccountName:username];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)refreshReceipt {
    SKReceiptRefreshRequest *request = [[SKReceiptRefreshRequest alloc] init];
    request.delegate = self;
    [request start];
    
    self.refreshRequest = request;
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    self.invalidProductIdentifiers = response.invalidProductIdentifiers;
    if (self.invalidProductIdentifiers.count > 0) {
        NSLog(@"Invalid product identifiers: %@", response.invalidProductIdentifiers);
    }
    
    self.products = [response.products sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSDecimalNumber *first = ((SKProduct *) obj1).price;
        NSDecimalNumber *second = ((SKProduct *) obj2).price;
        return [first compare:second];
    }];;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMYPStoreManagerProductsFetchedNotification
                                                        object:self];
}

#pragma mark - SKRequestDelegate

- (void)requestDidFinish:(SKRequest *)request {
    if ([request isKindOfClass:[SKReceiptRefreshRequest class]]) {
        [self handleReceiptRefreshRequestCompletion:(SKReceiptRefreshRequest *)request];
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
    if ([request isKindOfClass:[SKReceiptRefreshRequest class]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kMYPStoreManagerRefreshRequestFailedNotification
                                                            object:self];
    }
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    for (SKPaymentTransaction *transaction in transactions) {
        SKPaymentTransactionState state = transaction.transactionState;
        NSLog(@"Transaction: id=%@, state=%lu", transaction.transactionIdentifier, (long)state);
        if (state == SKPaymentTransactionStatePurchasing) {
            // Do nothing
        }
        else if (state == SKPaymentTransactionStatePurchased || state == SKPaymentTransactionStateRestored) {
            [self handleSuccessfullPurchase:transaction];
        }
        else if (state == SKPaymentTransactionStateFailed) {
            [self handleFailedPurchase:transaction];
        }
        else if (state == SKPaymentTransactionStateDeferred) {
            // Do nothing
        }
    }
}

#pragma mark - Private methods

- (void)handleSuccessfullPurchase:(SKPaymentTransaction *)transaction {
    NSURL *receiptURL = self.receiptURL;
    NSError *readError = nil;
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL options:0 error:&readError];
    __block NSDictionary *userInfo = nil;
    
    NSString *path = receiptURL.path;
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    if (!fileExists || readError) {
        NSLog(@"%s: failed to read receipt's data (fileExists=%@, error=%@", __PRETTY_FUNCTION__, fileExists ? @"YES" : @"NO", readError);
        [self postFailedTransactionNotification:transaction validationError:nil];
        return;
    }
    
    [self validateReceipt:receiptData completion:^(NSError *error) {
        if (error) {
            [self postFailedTransactionNotification:transaction validationError:error];
            return;
        }
        
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        
        userInfo = @{kMYPStoreManagerUserInfoProductIdentifierKey : transaction.payment.productIdentifier};
        [[NSNotificationCenter defaultCenter] postNotificationName:kMYPStoreManagerProductPurchasedNotification
                                                            object:self
                                                          userInfo:userInfo];
    }];
}

- (void)handleFailedPurchase:(SKPaymentTransaction *)transaction {
    NSLog(@"%s: transaction failed - %@", __PRETTY_FUNCTION__, transaction.error);
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    [self postFailedTransactionNotification:transaction validationError:nil];
}

- (void)postFailedTransactionNotification:(SKPaymentTransaction *)transaction validationError:(NSError *)error {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (transaction) [userInfo setValue:transaction forKey:kMYPStoreManagerUserInfoTransactionKey];
    if (error) [userInfo setValue:error forKey:kMYPStoreManagerUserInfoValidationErrorKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:kMYPStoreManagerProductPurchaseFailedNotification
                                                        object:self
                                                      userInfo:userInfo];
}

- (void)validateReceipt:(NSData *)receiptData completion:(void (^)(NSError * error))handler {
    [[MYPService sharedInstance] validateReceipt:receiptData
                                         handler:^(NSData *responseData, NSInteger statusCode, NSError *error)
     {
         if (handler) {
             handler(error);
         }
     }];
}

- (void)handleReceiptRefreshRequestCompletion:(SKReceiptRefreshRequest *)refreshRequest {
    NSURL *receiptURL = self.receiptURL;
    if (![[NSFileManager defaultManager] fileExistsAtPath:receiptURL.path]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kMYPStoreManagerRefreshRequestCompletedNotification
                                                            object:self];
        return;
    }
    
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    [self validateReceipt:receiptData completion:^(NSError *error) {
        if (error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kMYPStoreManagerRefreshRequestFailedNotification
                                                                object:self];
            return;
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kMYPStoreManagerRefreshRequestCompletedNotification
                                                            object:self];
    }];
}

// Custom method to calculate the SHA-256 hash using Common Crypto
- (NSString *)hashedValueForAccountName:(NSString*)userAccountName {
    const int HASH_SIZE = 32;
    unsigned char hashedChars[HASH_SIZE];
    const char *accountName = [userAccountName UTF8String];
    size_t accountNameLen = strlen(accountName);
    
    // Confirm that the length of the user name is small enough
    // to be recast when calling the hash function.
    if (accountNameLen > UINT32_MAX) {
        NSLog(@"Account name too long to hash: %@", userAccountName);
        return nil;
    }
    CC_SHA256(accountName, (CC_LONG)accountNameLen, hashedChars);
    
    // Convert the array of bytes into a string showing its hex representation.
    NSMutableString *userAccountHash = [[NSMutableString alloc] init];
    for (int i = 0; i < HASH_SIZE; i++) {
        // Add a dash every four bytes, for readability.
        if (i != 0 && i%4 == 0) {
            [userAccountHash appendString:@"-"];
        }
        [userAccountHash appendFormat:@"%02x", hashedChars[i]];
    }
    
    return userAccountHash;
}

@end
