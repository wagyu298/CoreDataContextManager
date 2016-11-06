// This software is released under the MIT License.
// http://opensource.org/licenses/mit-license.php

#import <UIKit/UIKit.h>
#import "CDMCoreDataContextManager.h"
#import "NSManagedObjectContext+CoreDataContextManager.h"

@interface CDMCoreDataContextManager ()

@end

@implementation CDMCoreDataContextManager

- (instancetype _Nonnull)initWithConfiguration:(CDMCoreDataContextManagerConfiguration * _Nonnull)configuration {
    assert([NSThread isMainThread]);
    
    self = [super init];
    if (self) {
        [self setupManagedObjectCotextWithStoreType:configuration.storeType mappingModelURL:configuration.mappingModelURL persistentStoreURL:configuration.persistentStoreURL];
        
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        if (configuration.autoSave) {
            [defaultCenter addObserver:self selector:@selector(willResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
        }
        [defaultCenter addObserver:self selector:@selector(didSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
    }
    return self;
}

- (instancetype _Nonnull)initWithStoreType:(NSString * _Nonnull)storeType databaseName:(NSString * _Nonnull)databaseName autoSave:(BOOL)autoSave {
    CDMCoreDataContextManagerConfiguration *config = [[CDMCoreDataContextManagerConfiguration alloc] initWithStoreType:storeType databaseName:databaseName];
    config.autoSave = autoSave;
    return [self initWithConfiguration:config];
}

- (instancetype _Nonnull)initWithStoreType:(NSString * _Nonnull)storeType databaseName:(NSString * _Nonnull)databaseName
{
    return [self initWithStoreType:storeType databaseName:databaseName autoSave:YES];
}

- (instancetype _Nonnull)initWithSQLiteDatabaseName:(NSString * _Nonnull)databaseName autoSave:(BOOL)autoSave {
    CDMCoreDataContextManagerConfiguration *config = [[CDMCoreDataContextManagerSQLLiteConfiguration alloc] initWithDatabaseName:databaseName];
    config.autoSave = autoSave;
    return [self initWithConfiguration:config];
}

- (instancetype _Nonnull)initWithSQLiteDatabaseName:(NSString * _Nonnull)databaseName {
    return [self initWithSQLiteDatabaseName:databaseName autoSave:YES];
}

- (instancetype _Nonnull)initWithBinaryDatabaseName:(NSString * _Nonnull)databaseName autoSave:(BOOL)autoSave {
    CDMCoreDataContextManagerConfiguration *config = [[CDMCoreDataContextManagerBinaryConfiguration alloc] initWithDatabaseName:databaseName];
    config.autoSave = autoSave;
    return [self initWithConfiguration:config];
}

- (instancetype _Nonnull)initWithBinaryDatabaseName:(NSString * _Nonnull)databaseName {
    return [self initWithBinaryDatabaseName:databaseName autoSave:YES];
}

- (instancetype _Nonnull)initWithInMemoryDatabaseName:(NSString * _Nonnull)databaseName autoSave:(BOOL)autoSave {
    CDMCoreDataContextManagerConfiguration *config = [[CDMCoreDataContextManagerInMemoryConfiguration alloc] initWithDatabaseName:databaseName];
    config.autoSave = autoSave;
    return [self initWithConfiguration:config];
}

- (instancetype _Nonnull)initWithInMemoryDatabaseName:(NSString * _Nonnull)databaseName {
    return [self initWithInMemoryDatabaseName:databaseName autoSave:YES];
}

- (instancetype _Nonnull)initWithDatabaseName:(NSString * _Nonnull)databaseName directory:(NSURL * _Nullable)directory storeType:(NSString * _Nonnull)storeType options:(CDMCoreDataContextManagerOptions)options DEPRECATED_ATTRIBUTE {
    CDMCoreDataContextManagerConfiguration *config = [[CDMCoreDataContextManagerConfiguration alloc] initWithStoreType:storeType];
    config.autoSave = (options & CDMCoreDataContextManagerOptionsAutoSave);
    [config setMappingModelURLWithDatabaseName:databaseName];
    [config setPersistentStoreURLWithStoreType:storeType directoryURL:directory databaseName:databaseName];
    return [self initWithConfiguration:config];
}

- (instancetype)initWithDatabaseName:(NSString * _Nonnull)databaseName storeType:(NSString * _Nonnull)storeType DEPRECATED_ATTRIBUTE {
    return [self initWithDatabaseName:databaseName directory:nil storeType:storeType options:CDMCoreDataContextManagerOptionsDefault];
}

- (instancetype)initWithDatabaseName:(NSString * _Nonnull)databaseName options:(CDMCoreDataContextManagerOptions)options DEPRECATED_ATTRIBUTE {
    return [self initWithDatabaseName:databaseName directory:nil storeType:NSSQLiteStoreType options:options];
}

- (instancetype)initWithDatabaseName:(NSString * _Nonnull)databaseName DEPRECATED_ATTRIBUTE {
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
                NSLog(@"Unresolved error %@", error);
            }
        }];
    }
}

#pragma mark - CoreData stack

- (void)setupManagedObjectCotextWithStoreType:(NSString * _Nonnull)storeType mappingModelURL:(NSURL * _Nonnull)mappingModelURL persistentStoreURL:(NSURL * _Nullable)persistentStoreURL {
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:mappingModelURL];
    
    NSDictionary *options = nil;
    if (persistentStoreURL != nil) {
        NSError *error = nil;
#ifdef __IPHONE_9_0
        NSDictionary *storeMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:storeType URL:persistentStoreURL options:nil error:&error];
#else
        NSDictionary *storeMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:storeType URL:persistentStoreURL error:&error];
#endif
        
        if (storeMetadata != nil) {
            BOOL isCompatibile = [_managedObjectModel isConfiguration:nil compatibleWithStoreMetadata:storeMetadata];
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
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:storeType configuration:nil URL:persistentStoreURL options:options error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:_persistentStoreCoordinator];
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
