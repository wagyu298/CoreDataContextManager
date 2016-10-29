// This is free and unencumbered software released into the public domain.
// For more information, please refer to <http://unlicense.org/>

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (CoreDataContextManager)

- (NSManagedObjectContext * _Nonnull)cdm_createChildManagedObjectContext;

@end
