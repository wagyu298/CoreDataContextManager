// This software is released under the MIT License.
// http://opensource.org/licenses/mit-license.php

#import <UIKit/UIKit.h>
#import "CDMCoreDataContextManager.h"
#import "NSManagedObjectContext+CoreDataContextManager.h"

@interface CDMCoreDataContextManager ()

@property (nonnull, nonatomic, strong) NSString *databaseName;
@property (nonnull, nonatomic, strong) NSString *storeType;
@property (nonnull, nonatomic, strong) NSURL *persistentStoreURL;

@end

@implementation CDMCoreDataContextManager

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (instancetype)initWithDatabaseName:(NSString * _Nonnull)databaseName directory:(NSURL * _Nullable)directory storeType:(NSString * _Nonnull)storeType options:(CDMCoreDataContextManagerOptions)options {
    self = [super init];
    if (self) {
        self.databaseName = databaseName;
        self.storeType = storeType;
        
        NSURL *directoryURL;
        if (directory == nil) {
            directoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        } else {
            directoryURL = directory;
        }
        
        if (![self.storeType isEqualToString:NSInMemoryStoreType]) {
            NSString *filename;
            if ([self.storeType isEqualToString:NSSQLiteStoreType]) {
                filename = [NSString stringWithFormat:@"%@.sqlite", databaseName];
            } else if ([self.storeType isEqualToString:NSBinaryStoreType]) {
                filename = [NSString stringWithFormat:@"%@.binary", databaseName];
            } else {
                filename = databaseName;    // Unknown store type
            }
            
            self.persistentStoreURL = [directoryURL URLByAppendingPathComponent:filename];
            
            // Core data auto migration
            if ([self shouldPerformCoreDataMigration]) {
                [self performMigration];
            }
        }
        
        // Instanciate main thread object context
        [self managedObjectContext];
        
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        if (options & CDMCoreDataContextManagerOptionsAutoSave) {
            [defaultCenter addObserver:self selector:@selector(willResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
        }
        [defaultCenter addObserver:self selector:@selector(didSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
    }
    return self;
}

- (instancetype)initWithDatabaseName:(NSString * _Nonnull)databaseName storeType:(NSString * _Nonnull)storeType {
    return [self initWithDatabaseName:databaseName directory:nil storeType:storeType options:CDMCoreDataContextManagerOptionsDefault];
}

- (instancetype)initWithDatabaseName:(NSString * _Nonnull)databaseName options:(CDMCoreDataContextManagerOptions)options {
    return [self initWithDatabaseName:databaseName directory:nil storeType:NSSQLiteStoreType options:options];
}


- (instancetype)initWithDatabaseName:(NSString * _Nonnull)databaseName {
    return [self initWithDatabaseName:databaseName directory:nil storeType:NSSQLiteStoreType options:CDMCoreDataContextManagerOptionsDefault];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification Handlers

- (void)willResignActiveNotification:(NSNotification *)notification {
    NSError *error = nil;
    if (![self saveIfChanged:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
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
    return [self.managedObjectContext cdm_createChildManagedObjectContext];
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
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:self.databaseName withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator * _Nonnull)persistentStoreCoordinatorWithOption:(NSDictionary * _Nullable)options {
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:self.storeType configuration:nil URL:self.persistentStoreURL options:options error:&error]) {
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
#ifdef __IPHONE_9_0
    NSDictionary *storeMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:self.persistentStoreURL options:nil error:&error];
#else
    NSDictionary *storeMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:self.persistentStoreURL error:&error];
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
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption: @YES,
                              NSInferMappingModelAutomaticallyOption: @YES,
                              };
    [self persistentStoreCoordinatorWithOption:options];
}

- (BOOL)saveIfChanged:(NSError **)error {
    if ([__managedObjectContext hasChanges]) {
        return [__managedObjectContext save:error];
    } else {
        return YES;
    }
}

@end
