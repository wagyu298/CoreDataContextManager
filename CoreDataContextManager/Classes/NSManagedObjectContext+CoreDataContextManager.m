// This software is released under the MIT License.
// http://opensource.org/licenses/mit-license.php

#import "NSManagedObjectContext+CoreDataContextManager.h"

@implementation NSManagedObjectContext (CoreDataContextManager)

// Create background thread context
- (NSManagedObjectContext * _Nonnull)cdm_createBackgroundContext {
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    NSManagedObjectContext *parentContext = self.parentContext;
    if (!parentContext) {
        parentContext = self;
    }
    [context setParentContext:parentContext];
    return context;
}

// Save if required
- (BOOL)cdm_saveChanges:(NSError * _Nullable * _Nullable)error {
    if ([self hasChanges]) {
        return [self save:error];
    } else {
        return YES;
    }
}

// Delete all object from entity
- (BOOL)cdm_deleteWithEntityName:(NSString * _Nonnull)entityName error:(NSError * _Nullable * _Nullable)error {
    if ([NSBatchDeleteRequest class]) {
        BOOL canBatchRequest = YES;
        for (NSPersistentStore *store in self.persistentStoreCoordinator.persistentStores) {
            if ([store.type isEqualToString:NSInMemoryStoreType]) {
                canBatchRequest = NO;
                break;
            }
        }
        
        if (canBatchRequest) {
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
            NSBatchDeleteRequest *deleteRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
            
            if (![self.persistentStoreCoordinator executeRequest:deleteRequest withContext:self error:error]) {
                return NO;
            }
            return YES;
        }
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:self]];
    request.includesPropertyValues = NO;
    
    NSArray *results = [self executeFetchRequest:request error:error];
    if (!results) {
        return NO;
    }
    for (NSManagedObject *o in results) {
        [self deleteObject:o];
    }
    
    return YES;
}

@end
