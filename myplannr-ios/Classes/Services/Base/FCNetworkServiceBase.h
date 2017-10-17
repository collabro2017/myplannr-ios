//
//  FCNetworkServiceBase.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 22/08/16.
//
//

#import <RestKit/RestKit.h>
#import "FCServiceObject.h"
#import "FCManagedServiceObject.h"
#import "FCSession.h"

typedef void(^RequestCompletionHandler)(NSData *responseData, NSInteger statusCode, NSError *error);
typedef void(^ObjectRequestCompletionHandler)(id object, NSData *responseData, NSInteger statusCode, NSError *error);

@protocol FCNetworkService <NSObject>

@required

/****** To override ******/
@property (nonatomic, assign, readonly) AFRKHTTPClientParameterEncoding parameterEncoding;

@property (nonatomic, strong, readonly) NSString *acceptContentType;
@property (nonatomic, strong, readonly) NSString *requestContentType;

@property (nonatomic, strong, readonly) NSArray *responseDescriptors;
@property (nonatomic, strong, readonly) NSArray *requestDescriptors;

@property (nonatomic, strong, readonly) NSURL *baseUrl;

@property (nonatomic, strong, readonly) NSString *modelFileName;

@property (nonatomic, strong, readonly) NSString *authToken;
/****** To override ******/

- (void)postObject:(id)object
              path:(NSString *)path
        parameters:(NSDictionary *)parameters
           handler:(ObjectRequestCompletionHandler)handler;

- (void)getObjectsAtPath:(NSString *)path
              parameters:(NSDictionary *)parameters
                 handler:(ObjectRequestCompletionHandler)handler;

- (void)putObject:(id)object
             path:(NSString *)path
       parameters:(NSDictionary *)parameters
          handler:(ObjectRequestCompletionHandler)handler;

- (void)deleteObject:(id)object
                path:(NSString *)path
          parameters:(NSDictionary *)parameters
             handler:(ObjectRequestCompletionHandler)handler;

- (void)postDataAsManagedRequest:(NSData *)data
                            path:(NSString *)path
                        partName:(NSString *)partName
                        fileName:(NSString *)fileName
                        mimeType:(NSString *)mimeType
                         handler:(ObjectRequestCompletionHandler)handler;

- (void)postDataAsNonManagedRequest:(NSData *)data
                               path:(NSString *)path
                           partName:(NSString *)partName
                           fileName:(NSString *)fileName
                           mimeType:(NSString *)mimeType
                            handler:(ObjectRequestCompletionHandler)handler;

- (void)postImageAsManagedRequest:(UIImage *)image
                             path:(NSString *)path
                         partName:(NSString *)partName
                         fileName:(NSString *)fileName
                          handler:(ObjectRequestCompletionHandler)handler;

- (void)postImageAsNonManagedRequest:(UIImage *)image
                                path:(NSString *)path
                            partName:(NSString *)partName
                            fileName:(NSString *)fileName
                             handler:(ObjectRequestCompletionHandler)handler;

@end

extern NSString * const FCHttpStatusKey; // NSNumber
extern NSString * const FCIsApiErrorKey; // NSNumber

@interface FCNetworkServiceBase : NSObject<FCNetworkService>

@property (nonatomic, strong, readonly) RKObjectManager *objectManager;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, assign, readonly) AFRKNetworkReachabilityStatus reachabilityStatus;
@property (nonatomic, assign, readonly, getter=isNetworkReachable) BOOL networkReachable;

@property (nonatomic, strong, readonly) FCSession *session;

+ (instancetype)sharedInstance;

+ (void)provideSession:(FCSession *)session;
+ (void)terminateSessionWithCompletionBlock:(void (^)(void))block;

- (void)saveManagedObjectContext; // doesn't persist changes to the database
- (void)saveManagedObjectContextToPersistentStore;

- (void)logCountForManagedObject:(Class)object; // Class must be derieved from FCManagedServiceObject

@end
