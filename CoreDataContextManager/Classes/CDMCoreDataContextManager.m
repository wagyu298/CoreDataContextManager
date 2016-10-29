// This software is released under the MIT License.
// http://opensource.org/licenses/mit-license.php

#import <UIKit/UIKit.h>
#import "CDMCoreDataContextManager.h"
#import "NSManagedObjectContext+CoreDataContextManager.h"

@interface CDMCoreDataContextManager ()

@end

@implementation CDMCoreDataContextManager

- (instancetype)initWithDatabaseName:(NSString * _Nonnull)databaseName directory:(NSURL * _Nullable)directory storeType:(NSString * _Nonnull)storeType options:(CDMCoreDataContextManagerOptions)options {
    assert([NSThread isMainThread]);
    
    self = [super init];
    if (self) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:databaseName withExtension:@"momd"];
        NSURL *persistentStoreURL = nil;
        
        if (![storeType isEqualToString:NSInMemoryStoreType]) {
            NSString *filename;
            if ([storeType isEqualToString:NSSQLiteStoreType]) {
                filename = [NSString stringWithFormat:@"%@.sqlite", databaseName];
            } else if ([storeType isEqualToString:NSBinaryStoreType]) {
                filename = [NSString stringWithFormat:@"%@.binary", databaseName];
            } else {
                filename = databaseName;    // Unknown store type
            }
            
            NSURL *directoryURL;
            if (directory == nil) {
                directoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
            } else {
                directoryURL = directory;
            }
            
            persistentStoreURL = [directoryURL URLByAppendingPathComponent:filename];
        }
        
        [self setupManagedObjectCotextWithStoreType:storeType modelURL:modelURL persistentStoreURL:persistentStoreURL];
        
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
    if (context != _managedObjectContext && context.parentContext == _managedObjectContext) {
        [_managedObjectContext performBlock:^{
            NSError *error = nil;
            [_managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
            if (![_managedObjectContext save:&error]) {
                NSLog(@"%@", error);
            }
        }];
    }
}

#pragma mark - CoreData stack

- (void)setupManagedObjectCotextWithStoreType:(NSString * _Nonnull)storeType modelURL:(NSURL * _Nonnull)modelURL persistentStoreURL:(NSURL * _Nullable)persistentStoreURL {
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    NSDictionary *options = nil;
    if (persistentStoreURL != nil) {
        NSError *error = nil;
#ifdef __IPHONE_9_0
        NSDictionary *storeMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:storeType URL:persistentStoreURL options:nil error:&error];
#else
        NSDictionary *storeMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:storeType URL:persistentStoreURL error:&error];
#endif
        
        if (storeMetadata != nil) {
            BOOL isCompatibile = [managedObjectModel isConfiguration:nil compatibleWithStoreMetadata:storeMetadata];
            if (!isCompatibile) {
                // Required migration
                options = @{
                            NSMigratePersistentStoresAutomaticallyOption: @YES,
                            NSInferMappingModelAutomaticallyOption: @YES,
                            };
            }
        }
    }
    
    NSError *error = nil;
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    if (![persistentStoreCoordinator addPersistentStoreWithType:storeType configuration:nil URL:persistentStoreURL options:options error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
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

- (BOOL)saveIfChanged:(NSError **)error {
    if ([self.managedObjectContext hasChanges]) {
        return [self.managedObjectContext save:error];
    } else {
        return YES;
    }
}

@end
