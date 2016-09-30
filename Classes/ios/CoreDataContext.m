// This is free and unencumbered software released into the public domain.
// For more information, please refer to <http://unlicense.org/>

#import <UIKit/UIKit.h>
#import "CoreDataContext.h"

static NSString * const kCurrentThreadManagedObjectContext = @"CoreDataContext::currentThreadManagedObjectContext";

@implementation CoreDataContext

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

@synthesize databaseName = _databaseName;
@synthesize directory = _directory;

- (id)initWithDatabaseName:(NSString * _Nonnull)databaseName directory:(NSURL * _Nonnull)directory {
    self = [super init];
    if (self) {
        _databaseName = databaseName;
        if (directory == nil) {
            _directory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        } else {
            _directory = directory;
        }
        
        // Core data auto migration
        if ([self shouldPerformCoreDataMigration]) {
            [self performMigration];
        }
        
        // Instanciate main thread object context
        [self managedObjectContext];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
    }
    return self;
}

- (id)initWithDatabaseName:(NSString * _Nonnull)databaseName {
    return [self initWithDatabaseName:databaseName directory:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
}

#pragma mark - Notification Handlers

- (void)didEnterBackgroundNotification:(NSNotification *)notification {
    NSError *error = nil;
    if ([__managedObjectContext hasChanges] && ![__managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)didSaveNotification:(NSNotification *)notification {
    NSManagedObjectContext *context = notification.object;
    if (context != __managedObjectContext && context.parentContext == __managedObjectContext) {
        [__managedObjectContext performBlock:^{
            NSError *error = nil;
            [__managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
            if (![__managedObjectContext save:&error]) {
                NSLog(@"%@", error);
            }
        }];
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext * _Nonnull)managedObjectContext {
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    assert([NSThread isMainThread]);
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

- (NSManagedObjectContext * _Nonnull)createBackgroundContext {
    return [self.managedObjectContext createChildContext];
}

- (NSManagedObjectContext * _Nonnull)currentManagedObjectContext {
    if ([NSThread isMainThread]) {
        return self.managedObjectContext;
    } else {
        return [self createBackgroundContext];
    }
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel * _Nonnull)managedObjectModel {
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:_databaseName withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the URL of persistent store.
- (NSURL * _Nonnull)urlOfPersistentStore {
    NSString *filename = [NSString stringWithFormat:@"%@.sqlite", _databaseName];
    return [_directory URLByAppendingPathComponent:filename];
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator * _Nonnull)persistentStoreCoordinatorWithOption:(NSDictionary * _Nullable)options {
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [self urlOfPersistentStore];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return __persistentStoreCoordinator;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator * _Nonnull)persistentStoreCoordinator {
    return [self persistentStoreCoordinatorWithOption:nil];
}

#pragma mark - Auto migration

// Returns YES if Core Data needs to migration.
- (BOOL)shouldPerformCoreDataMigration {
    NSError *error = nil;
    NSURL *storeURL = [self urlOfPersistentStore];
#ifdef __IPHONE_9_0
    NSDictionary *storeMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:storeURL options:nil error:&error];
#else
    NSDictionary *storeMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:storeURL error:&error];
#endif
    
    if (storeMetadata == nil) {
        return NO;
    }
    
    BOOL isCompatibile = [[self managedObjectModel] isConfiguration:nil compatibleWithStoreMetadata:storeMetadata];
    return !isCompatibile;
}

// Perform Core Data automatic lightweight migration.
- (void)performMigration {
    __persistentStoreCoordinator = nil;
    NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [[NSNumber alloc] initWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    [self persistentStoreCoordinatorWithOption:options];
}

@end
