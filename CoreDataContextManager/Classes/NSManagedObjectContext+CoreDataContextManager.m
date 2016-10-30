// This software is released under the MIT License.
// http://opensource.org/licenses/mit-license.php

#import "NSManagedObjectContext+CoreDataContextManager.h"

@implementation NSManagedObjectContext (CoreDataContextManager)

- (NSManagedObjectContext * _Nonnull)cdm_createChildManagedObjectContext {
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    NSManagedObjectContext *parentContext = self.parentContext;
    if (!parentContext) {
        parentContext = self;
    }
    [context setParentContext:parentContext];
    return context;
}

- (BOOL)cdm_saveChanges:(NSError * _Nullable * _Nullable)error {
    if ([self hasChanges]) {
        [self save:error];
    } else {
        return YES;
    }
}

@end
