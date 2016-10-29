// This is free and unencumbered software released into the public domain.
// For more information, please refer to <http://unlicense.org/>

#import "NSManagedObjectContext+CoreDataContextManager.h"

@implementation NSManagedObjectContext (CoreDataContextManager)

- (NSManagedObjectContext * _Nonnull)cdm_createChildManagedObjectContext
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    NSManagedObjectContext *parentContext = self.parentContext;
    if (!parentContext) {
        parentContext = self;
    }
    [context setParentContext:parentContext];
    return context;
}

@end
