// This software is released under the MIT License.
// http://opensource.org/licenses/mit-license.php

#import <UIKit/UIKit.h>
#import "CDMCoreDataContextManager.h"
#import "NSManagedObjectContext+CoreDataContextManager.h"

static const NSString * const ThreadKeyPrefix = @"CDMCoreDataContextManager:currentContext";

@interface CDMCoreDataContextManager ()

@end

@implementation CDMCoreDataContextManager

@dynamic currentContext;
@dynamic persistentStoreCoordinator;
@dynamic managedObjectModel;

- (instancetype _Nonnull)initWithConfiguration:(CDMCoreDataContextManagerConfiguration * _Nonnull)configuration {
    assert([NSThread isMainThread]);
    
    self = [super init];
    if (self) {
        [self setupWithConfiguration:configuration];
        
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification Handlers

- (void)willResignActiveNotification:(NSNotification *)notification {
    NSError *error = nil;
    if (![self.managedObjectContext cdm_saveChanges:&error]) {
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

- (void)setupWithConfiguration:(CDMCoreDataContextManagerConfiguration * _Nonnull)configuration {
    _configuration = configuration;
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:configuration.mappingModelURL];
    
    NSMutableDictionary *options = [configuration.storeOptions mutableCopy];
    if (configuration.persistentStoreURL != nil) {
        NSError *error = nil;
#ifdef __IPHONE_9_0
        NSDictionary *storeMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:configuration.storeType URL:configuration.persistentStoreURL options:options error:&error];
#else
        NSDictionary *storeMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:configuration.storeType URL:configuration.persistentStoreURL error:&error];
#endif
        
        if (storeMetadata != nil) {
            BOOL isCompatibile = [managedObjectModel isConfiguration:nil compatibleWithStoreMetadata:storeMetadata];
            if (!isCompatibile) {
                // Required migration
                options[NSMigratePersistentStoresAutomaticallyOption] = @YES;
                options[NSInferMappingModelAutomaticallyOption] = @YES;
            }
        }
    }
    
    NSError *error = nil;
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    if (![persistentStoreCoordinator addPersistentStoreWithType:configuration.storeType configuration:nil URL:configuration.persistentStoreURL options:options error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
    _managedObjectContext = managedObjectContext;
}

- (NSManagedObjectContext * _Nonnull)createBackgroundContext {
    return [self.managedObjectContext cdm_createBackgroundContext];
}

#pragma mark - Properties

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    return self.managedObjectContext.persistentStoreCoordinator;
}

- (NSManagedObjectModel *)managedObjectModel {
    return self.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
}

#pragma mark - NSThread helper

- (NSString *)threadKey {
    NSString *key = [NSString stringWithFormat:@"%@:%@:%@", ThreadKeyPrefix, self.managedObjectContext.description, [NSThread currentThread].description];
    return key;
}

- (NSManagedObjectContext *)currentContext {
    if ([NSThread isMainThread]) {
        return self.managedObjectContext;
    }
    
    NSThread *thread = [NSThread currentThread];
    NSString *threadKey = [self threadKey];
    NSManagedObjectContext *context = thread.threadDictionary[threadKey];
    if (context) {
        return context;
    }
    
    context = [self.managedObjectContext cdm_createBackgroundContext];
    thread.threadDictionary[threadKey] = context;
    return context;
}

@end
