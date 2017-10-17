//
//  FCNetworkServiceBase.m
//  myplannr-ios
//
//  Created by fraggjkee MBP on 22/08/16.
//
//

#import "FCNetworkServiceBase.h"

NSString * const FCHttpStatusKey = @"FCHttpStatusKey";
NSString * const FCIsApiErrorKey = @"FCIsApiErrorKey";

static const NSTimeInterval kPostMultipartDataTimeout = 180;

@interface FCNetworkServiceBase ()

@property (nonatomic, strong, readwrite) FCSession *session;
@property (nonatomic, assign, readwrite) AFRKNetworkReachabilityStatus reachabilityStatus;

@end

@implementation FCNetworkServiceBase

#pragma mark - Public methods and properties

+ (instancetype)sharedInstance {
    static id<FCNetworkService> instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (void)provideSession:(FCSession *)session {
    FCNetworkServiceBase *service = [FCNetworkServiceBase sharedInstance];
    if (service.session != nil) {
        NSString *name = [NSString stringWithFormat:@"%s: illegal state - (self.session != nil)", __PRETTY_FUNCTION__];
        NSString *reason = @"Any previously provided session must be terminated first.";
        @throw [NSException exceptionWithName:name reason:reason userInfo:nil];
    }
    
    service.session  = session;
}

+ (void)terminateSessionWithCompletionBlock:(void (^)(void))block {
    FCNetworkServiceBase *service = [FCNetworkServiceBase sharedInstance];
    if (service.session == nil) {
        NSString *name = [NSString stringWithFormat:@"%s: illegal state - (self.session == nil)", __PRETTY_FUNCTION__];
        NSString *reason = @"Not possible to terminate uninitialized session.";
        @throw [NSException exceptionWithName:name reason:reason userInfo:nil];
    }
    
    service.session = nil;
    
    // Remove all objects from the store
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        RKManagedObjectStore *store = [RKManagedObjectStore defaultStore];
        NSManagedObjectContext *managedObjectContext = store.persistentStoreManagedObjectContext;
        [managedObjectContext performBlockAndWait:^{
            NSError *error = nil;
            for (NSEntityDescription *entity in store.managedObjectModel) {
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                fetchRequest.entity = entity;
                
                NSBatchDeleteRequest *deleteRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchRequest];
                [managedObjectContext executeRequest:deleteRequest error:&error];
                if (error) {
                    NSLog(@"%s: failed to execute DELETE request - %@", __PRETTY_FUNCTION__, error);
                }
            }
            
            [[FCNetworkServiceBase sharedInstance] saveManagedObjectContextToPersistentStore];
        }];
    }];
    [operation setCompletionBlock:^{
        if (block) {
            block();
        }
    }];
    [operation start];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initService];
    }
    return self;
}

- (void)saveManagedObjectContext {
    if (self.managedObjectContext != nil) {
        [self saveContext:self.managedObjectContext toPersistentStore:NO];
    }
}

- (void)saveManagedObjectContextToPersistentStore {
    if (self.managedObjectContext != nil) {
        [self saveContext:self.managedObjectContext toPersistentStore:YES];
    }
}

- (void)logCountForManagedObject:(Class)class {
    if (![class isSubclassOfClass:FCManagedServiceObject.class]) {
        NSLog(@"%s: invalid Class passed", __PRETTY_FUNCTION__);
        return;
    }
    
    NSFetchRequest *fetchRequest = [class fc_fetchRequest];
    NSManagedObjectContext *context = self.managedObjectContext;
    NSError *error;
    NSInteger count = [context countForFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
        return;
    }
    
    NSLog(@"Total amount of %@ objects = %lu", NSStringFromClass(class), (long)count);
}

- (RKObjectManager *)objectManager {
    RKObjectManager *objManager = [RKObjectManager sharedManager];
    if (!objManager) {
        @throw [NSException exceptionWithName:@"objectManager == nil"
                                       reason:@"Make sure that [RKObjectManager setSharedManager] is called"
                                     userInfo:nil];
    }
    return objManager;
}

- (NSManagedObjectContext *)managedObjectContext {
    RKManagedObjectStore *store = self.objectManager.managedObjectStore;
    return store.mainQueueManagedObjectContext;
}

- (BOOL)isNetworkReachable {
    return self.reachabilityStatus != AFRKNetworkReachabilityStatusUnknown
        && self.reachabilityStatus != AFRKNetworkReachabilityStatusNotReachable;
}

#pragma mark - FCNetworkService

- (NSURL *)baseUrl {
    @throw [NSException exceptionWithName:@"FCNetworkServiceBase: baseURL not overriden"
                                   reason:@"'baseURL' property must not be used directly and should be overriden in subclasses"
                                 userInfo:nil];
}

- (NSString *)modelFileName {
    return nil;
}

- (AFRKHTTPClientParameterEncoding)parameterEncoding {
    return AFRKJSONParameterEncoding;
}

- (NSString *)acceptContentType {
    return RKMIMETypeJSON;
}

- (NSString *)requestContentType {
    return RKMIMETypeJSON;
}

- (NSArray *)responseDescriptors {
    return @[];
}

- (NSArray *)requestDescriptors {
    return @[];
}

- (NSString *)authToken {
    return self.session.authToken;
}

- (void)postObject:(id)object
              path:(NSString *)path
        parameters:(NSDictionary *)parameters
           handler:(ObjectRequestCompletionHandler)handler
{
    [self setupAuthorizationHeader];
    
    [self.objectManager postObject:object
                              path:path
                        parameters:parameters
                           success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
     {
         [self notifyHandler:handler operation:operation mappingResult:mappingResult error:nil];
     } failure:^(RKObjectRequestOperation *operation, NSError *error)
     {
         [self notifyHandler:handler operation:operation mappingResult:nil error:error];
     }];
}

- (void)getObjectsAtPath:(NSString *)path
              parameters:(NSDictionary *)parameters
                 handler:(ObjectRequestCompletionHandler)handler
{
    [self setupAuthorizationHeader];
    
    [self.objectManager getObjectsAtPath:path
                              parameters:parameters
                                 success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
     {
         [self notifyHandler:handler operation:operation mappingResult:mappingResult error:nil];
     } failure:^(RKObjectRequestOperation *operation, NSError *error)
     {
         [self notifyHandler:handler operation:operation mappingResult:nil error:error];
     }];
}

- (void)putObject:(id)object
             path:(NSString *)path
       parameters:(NSDictionary *)parameters
          handler:(ObjectRequestCompletionHandler)handler
{
    [self setupAuthorizationHeader];
    
    [self.objectManager putObject:object
                             path:path
                       parameters:parameters
                          success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
    {
        [self notifyHandler:handler operation:operation mappingResult:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error)
    {
        [self notifyHandler:handler operation:operation mappingResult:nil error:error];
    }];
}

- (void)deleteObject:(id)object
                path:(NSString *)path
          parameters:(NSDictionary *)parameters
             handler:(ObjectRequestCompletionHandler)handler
{
    [self setupAuthorizationHeader];
    
    [self.objectManager deleteObject:object
                                path:path
                          parameters:parameters
                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
    {
        [self notifyHandler:handler operation:operation mappingResult:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error)
    {
        [self notifyHandler:handler operation:operation mappingResult:nil error:error];
    }];
}

- (void)postDataAsManagedRequest:(NSData *)data
            path:(NSString *)path
        partName:(NSString *)partName
        fileName:(NSString *)fileName
        mimeType:(NSString *)mimeType
         handler:(ObjectRequestCompletionHandler)handler
{
    [self postData:data
              path:path
          partName:partName
          fileName:fileName
          mimeType:mimeType
  asManagedRequest:YES
           handler:handler];
}

- (void)postDataAsNonManagedRequest:(NSData *)data
                               path:(NSString *)path
                           partName:(NSString *)partName
                           fileName:(NSString *)fileName
                           mimeType:(NSString *)mimeType
                            handler:(ObjectRequestCompletionHandler)handler
{
    [self postData:data
              path:path
          partName:partName
          fileName:fileName
          mimeType:mimeType
  asManagedRequest:NO
           handler:handler];
}

- (void)postImageAsManagedRequest:(UIImage *)image
                             path:(NSString *)path
                         partName:(NSString *)partName
                         fileName:(NSString *)fileName
                          handler:(ObjectRequestCompletionHandler)handler
{
    [self postDataAsManagedRequest:UIImageJPEGRepresentation(image, 0.85f)
                              path:path
                          partName:partName
                          fileName:fileName
                          mimeType:@"image/jpg"
                           handler:handler];
}

- (void)postImageAsNonManagedRequest:(UIImage *)image
                                path:(NSString *)path
                            partName:(NSString *)partName
                            fileName:(NSString *)fileName
                             handler:(ObjectRequestCompletionHandler)handler
{
    [self postDataAsNonManagedRequest:UIImageJPEGRepresentation(image, 0.85f)
                                 path:path
                             partName:partName
                             fileName:fileName
                             mimeType:@"image/jpg"
                              handler:handler];
}

#pragma mark - Core Data

- (void)setupCoreDataStackWithModelName:(NSString *)modelFileName {
    NSDate *start = [NSDate date];
    
    NSError *error = nil;
    NSURL *modelURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:modelFileName ofType:@"momd"]];
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    
    [managedObjectStore createPersistentStoreCoordinator];
    
    NSString *path = [self storePathForModelName:modelFileName];
    
    NSPersistentStoreCoordinator *psc = managedObjectStore.persistentStoreCoordinator;
    if ([self isCoreDataMigrationNecessaryForCoordinator:psc storeUrl:path]) {
        [self destroyStoreInCoordinator:psc storeUrl:path];
    }
    
    NSPersistentStore __unused *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:path
                                                                              fromSeedDatabaseAtPath:nil
                                                                                   withConfiguration:nil
                                                                                             options:nil
                                                                                               error:&error];
    NSAssert(persistentStore, @"Failed to add persistent store: %@", error);
    
    [managedObjectStore createManagedObjectContexts];
    
    [RKManagedObjectStore setDefaultStore:managedObjectStore];
    
    self.objectManager.managedObjectStore = managedObjectStore;
    
    NSDate *finish = [NSDate date];
    NSTimeInterval executionTime = [finish timeIntervalSinceDate:start];
    NSLog(@"CoreData has been init in %f second(s)", executionTime);
}

- (BOOL)isCoreDataMigrationNecessaryForCoordinator:(NSPersistentStoreCoordinator *)coordinator storeUrl:(NSString *)url {
    NSError *error = nil;
    NSURL *storeUrl = [NSURL fileURLWithPath:url];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:url]) {
        return NO;
    }
    
    NSDictionary *metadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
                                                                                        URL:storeUrl
                                                                                    options:nil
                                                                                      error:&error];
    
    if (metadata == nil) {
        NSLog(@"%s: metadata == nil (error = %@", __PRETTY_FUNCTION__, error);
        return NO;
    }
    
    NSManagedObjectModel *destinationModel = coordinator.managedObjectModel;
    return ![destinationModel isConfiguration:nil compatibleWithStoreMetadata:metadata];
}

- (void)destroyStoreInCoordinator:(NSPersistentStoreCoordinator *)coordinator storeUrl:(NSString *)url {
    NSError *destroyError = nil;
    [coordinator destroyPersistentStoreAtURL:[NSURL fileURLWithPath:url]
                                    withType:NSSQLiteStoreType
                                     options:nil
                                       error:&destroyError];
    if (destroyError) {
        NSLog(@"%s: failed to destroy persistent store - %@", __PRETTY_FUNCTION__, destroyError);
    }
}

- (NSString *)storePathForModelName:(NSString *)name {
    NSString *pathComponent = [NSString stringWithFormat:@"%@.sqlite", name];
    NSString *path = [RKApplicationDataDirectory() stringByAppendingPathComponent:pathComponent];
    return path;
}


- (void)saveContext:(NSManagedObjectContext *)context toPersistentStore:(BOOL)persistentStore {
    if (context.hasChanges) {
        NSError *error;
        if (persistentStore) [context saveToPersistentStore:&error];
        else [context save:&error];
        if (error) {
            NSLog(@"%s: %@, persistentStore=%@", __PRETTY_FUNCTION__, error, persistentStore ? @"YES" : @"NO");
            
#ifdef DEBUG
            @throw [NSException exceptionWithName:@"Illegal CoreData state"
                                           reason:@"Context was in invalid state during an attempt to perform save."
                                         userInfo:nil];
#endif
            
        }
    }
}

#pragma mark - Private methods

- (void)initService {
    [AFRKNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:self.baseUrl];
    objectManager.requestSerializationMIMEType = self.requestContentType;
    objectManager.HTTPClient.parameterEncoding = self.parameterEncoding;
    [objectManager.HTTPClient setDefaultHeader:@"Accept" value:self.acceptContentType];
    
    [objectManager.HTTPClient setReachabilityStatusChangeBlock:^(AFRKNetworkReachabilityStatus status) {
        self.reachabilityStatus = status;
    }];
    
    [RKObjectManager setSharedManager:objectManager];
    
    if (self.modelFileName.length > 0) {
        [self setupCoreDataStackWithModelName:self.modelFileName];
    }
    
    [self initDescriptors];
}

- (void)initDescriptors {
    [self.objectManager addResponseDescriptorsFromArray:self.responseDescriptors];
    [self.objectManager addRequestDescriptorsFromArray:self.requestDescriptors];
}

- (void)setupAuthorizationHeader {
    NSString *token = self.authToken;
    if (token.length > 0) {
        [self.objectManager.HTTPClient setDefaultHeader:@"Authorization" value:token];
    }
}

- (void)notifyHandler:(ObjectRequestCompletionHandler)handler
            operation:(RKObjectRequestOperation *)operation
        mappingResult:(RKMappingResult *)mappingResult
                error:(NSError *)error
{
    if (handler) {
        NSInteger status = operation.HTTPRequestOperation.response.statusCode;
        BOOL success = (error == nil);
        if (success) {
            NSArray *values = mappingResult.dictionary.allValues;
            id object = values.firstObject;
            // id object = (array.count > 1) ? array : array.firstObject;
            NSData *data = operation.HTTPRequestOperation.responseData;
            handler(object, data, status, nil);
        } else {
            NSMutableDictionary *userInfo = error.userInfo.mutableCopy;
            if (userInfo == nil) {
                userInfo = [NSMutableDictionary dictionary];
            }
            BOOL isApiError = status >= 100 &&
                ![RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful) containsIndex:status];
            [userInfo setObject:@(isApiError) forKey:FCIsApiErrorKey];
            [userInfo setObject:@(status) forKey:FCHttpStatusKey];
            NSError *e = [NSError errorWithDomain:error.domain code:error.code userInfo:userInfo];
            handler(nil, nil, status, e);
        }
    }
}

- (void)postData:(NSData *)data
            path:(NSString *)path
        partName:(NSString *)partName
        fileName:(NSString *)fileName
        mimeType:(NSString *)mimeType
asManagedRequest:(BOOL)isManagedRequest
         handler:(ObjectRequestCompletionHandler)handler
{
    [self setupAuthorizationHeader];
    
    NSMutableURLRequest *request = [self.objectManager multipartFormRequestWithObject:nil
                                                                               method:RKRequestMethodPOST
                                                                                 path:path
                                                                           parameters:nil
                                                            constructingBodyWithBlock:^(id<AFRKMultipartFormData> formData)
                                    {
                                        [formData appendPartWithFileData:data
                                                                    name:partName
                                                                fileName:fileName
                                                                mimeType:mimeType];
                                    }];
    
    RKObjectManager *om = self.objectManager;
    
    void (^successBlock)(RKObjectRequestOperation*, RKMappingResult*) = ^(RKObjectRequestOperation *operation, RKMappingResult *result)
    {
        [self notifyHandler:handler operation:operation mappingResult:result error:nil];
    };
    
    void (^failureBlock)(RKObjectRequestOperation*, NSError*) = ^(RKObjectRequestOperation *operation, NSError *error)
    {
        [self notifyHandler:handler operation:operation mappingResult:nil error:error];
    };
    
    RKObjectRequestOperation *operation = nil;
    if (isManagedRequest) {
        operation = [om managedObjectRequestOperationWithRequest:request
                                            managedObjectContext:self.managedObjectContext
                                                         success:successBlock
                                                         failure:failureBlock];
    } else {
        operation = [om objectRequestOperationWithRequest:request
                                                  success:successBlock
                                                  failure:failureBlock];
    }
    
    ((NSMutableURLRequest *)operation.HTTPRequestOperation.request).timeoutInterval = kPostMultipartDataTimeout;
    [om enqueueObjectRequestOperation:operation];
}

@end
