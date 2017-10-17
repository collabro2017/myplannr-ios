//
//  NSManagedObject+Extensions.h
//  myplannr-ios
//
//  Created by fraggjkee MBP on 06/02/2017.
//
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Extensions)

+ (NSString *)fc_entityName;

+ (NSFetchRequest *)fc_fetchRequest;

@end
