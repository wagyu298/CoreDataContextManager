// This is free and unencumbered software released into the public domain.
// For more information, please refer to <http://unlicense.org/>

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExampleData : NSManagedObject

+ (ExampleData *)createWithTitle:(NSString *)title section:(NSString *)section number:(int32_t)number;

@end

NS_ASSUME_NONNULL_END

#import "ExampleData+CoreDataProperties.h"
