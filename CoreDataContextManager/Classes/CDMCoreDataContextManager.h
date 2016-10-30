// This software is released under the MIT License.
// http://opensource.org/licenses/mit-license.php

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreDataContextManager/CoreDataContextManager.h>

typedef NS_OPTIONS(NSUInteger, CDMCoreDataContextManagerOptions) {
    CDMCoreDataContextManagerOptionsNone = 0,
    CDMCoreDataContextManagerOptionsAutoSave = 0x1,
    CDMCoreDataContextManagerOptionsDefault = 0,
};

@interface CDMCoreDataContextManager : NSObject

@property (nonnull, nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonnull, nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonnull, nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (instancetype _Nonnull)initWithConfiguration:(CDMCoreDataContextManagerConfiguration * _Nonnull)configuration;

- (instancetype _Nonnull)initWithStoreType:(NSString * _Nonnull)storeType databaseName:(NSString * _Nonnull)databaseName autoSave:(BOOL)autoSave;
- (instancetype _Nonnull)initWithStoreType:(NSString * _Nonnull)storeType databaseName:(NSString * _Nonnull)databaseName;

- (instancetype _Nonnull)initWithSQLiteDatabaseName:(NSString * _Nonnull)databaseName autoSave:(BOOL)autoSave;
- (instancetype _Nonnull)initWithSQLiteDatabaseName:(NSString * _Nonnull)databaseName;

- (instancetype _Nonnull)initWithBinaryDatabaseName:(NSString * _Nonnull)databaseName autoSave:(BOOL)autoSave;
- (instancetype _Nonnull)initWithBinaryDatabaseName:(NSString * _Nonnull)databaseName;

- (instancetype _Nonnull)initWithInMemoryDatabaseName:(NSString * _Nonnull)databaseName autoSave:(BOOL)autoSave;
- (instancetype _Nonnull)initWithInMemoryDatabaseName:(NSString * _Nonnull)databaseName;

- (instancetype _Nonnull)initWithDatabaseName:(NSString * _Nonnull)databaseName directory:(NSURL * _Nullable)directory storeType:(NSString * _Nonnull)storeType options:(CDMCoreDataContextManagerOptions)options DEPRECATED_ATTRIBUTE;
- (instancetype _Nonnull)initWithDatabaseName:(NSString * _Nonnull)databaseName storeType:(NSString * _Nonnull)storeType DEPRECATED_ATTRIBUTE;
- (instancetype _Nonnull)initWithDatabaseName:(NSString * _Nonnull)databaseName options:(CDMCoreDataContextManagerOptions)options DEPRECATED_ATTRIBUTE;
- (instancetype _Nonnull)initWithDatabaseName:(NSString * _Nonnull)databaseName DEPRECATED_ATTRIBUTE;

- (NSManagedObjectContext * _Nonnull)createBackgroundContext;
- (NSManagedObjectContext * _Nonnull)currentManagedObjectContext;

- (BOOL)saveIfChanged:(NSError * _Nullable * _Nullable)error DEPRECATED_ATTRIBUTE;

@end
