// This software is released under the MIT License.
// http://opensource.org/licenses/mit-license.php

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreDataContextManager/CDMCoreDataContextManagerConfiguration.h>

typedef NS_OPTIONS(NSUInteger, CDMCoreDataContextManagerOptions) {
    CDMCoreDataContextManagerOptionsNone = 0,
    CDMCoreDataContextManagerOptionsAutoSave = 0x1,
    CDMCoreDataContextManagerOptionsDefault = 0,
};

/*!
 @class CDMCoreDataContextManager
 @brief NSManagedObjectContext wrapper with light weight migration and thread control
 */
@interface CDMCoreDataContextManager : NSObject

/// @brief configuration passed from constructor */
@property (nonnull, nonatomic, strong, readonly) CDMCoreDataContextManagerConfiguration*configuration;

/// @brief A NSManagedObjectContext object that managed under CDMCoreDataContextManager
@property (nonnull, nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

/// @brief A NSManagedObjectContext object for current thread
@property (nonnull, nonatomic, strong, readonly) NSManagedObjectContext *currentContext;

/// @brief NSPersistentStoreCoordinator for creating managedObjectContext
@property (nonnull, nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/// @brief NSManagedObjectModel for creating managedObjectContext
@property (nonnull, nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;

/*!
 @brief Constructor with CDMCoreDataContextManagerConfiguration
 @param configuration A configuration object
 */
- (instancetype _Nonnull)initWithConfiguration:(CDMCoreDataContextManagerConfiguration * _Nonnull)configuration;

/*!
 @brief Constructor with database name and auto save option
 @param storeType Database store type string that provided by CoreData
 @param databaseName Database file name (prefix of .xcdatamodeld file)
 @param autoSave Execute @c[NSManagedObjectContext save:] when application will resign active
 */
- (instancetype _Nonnull)initWithStoreType:(NSString * _Nonnull)storeType databaseName:(NSString * _Nonnull)databaseName autoSave:(BOOL)autoSave;

/*!
 @brief Constructor with database name and enabled autoSave
 @param storeType Database store type string that provided by CoreData
 @param databaseName Database file name (prefix of .xcdatamodeld file)
 */
- (instancetype _Nonnull)initWithStoreType:(NSString * _Nonnull)storeType databaseName:(NSString * _Nonnull)databaseName;

/*!
 @brief Initialize SQLite database with database name and auto save option
 @param databaseName Database file name (prefix of .xcdatamodeld file)
 @param autoSave Execute @c[NSManagedObjectContext save:] when application will resign active
 */
- (instancetype _Nonnull)initWithSQLiteDatabaseName:(NSString * _Nonnull)databaseName autoSave:(BOOL)autoSave;

/*!
 @brief Initialize SQLite database with database name and enabled autoSave
 @param databaseName Database file name (prefix of .xcdatamodeld file)
 */
- (instancetype _Nonnull)initWithSQLiteDatabaseName:(NSString * _Nonnull)databaseName;

/*!
 @brief Initialize Binary database with database name and auto save option
 @param databaseName Database file name (prefix of .xcdatamodeld file)
 @param autoSave Execute @c[NSManagedObjectContext save:] when application will resign active
 */
- (instancetype _Nonnull)initWithBinaryDatabaseName:(NSString * _Nonnull)databaseName autoSave:(BOOL)autoSave;

/*!
 @brief Initialize Binary database with database name and enabled autoSave
 @param databaseName Database file name (prefix of .xcdatamodeld file)
 */
- (instancetype _Nonnull)initWithBinaryDatabaseName:(NSString * _Nonnull)databaseName;

/*!
 @brief Initialize InMemory database with database name and auto save option
 @param databaseName Database file name (prefix of .xcdatamodeld file)
 @param autoSave Execute @c[NSManagedObjectContext save:] when application will resign active
 */
- (instancetype _Nonnull)initWithInMemoryDatabaseName:(NSString * _Nonnull)databaseName autoSave:(BOOL)autoSave;

/*!
 @brief Initialize InMemory database with database name and enabled autoSave
 @param databaseName Database file name (prefix of .xcdatamodeld file)
 */
- (instancetype _Nonnull)initWithInMemoryDatabaseName:(NSString * _Nonnull)databaseName;

/*!
 @brief Create NSManagedObjectContext to running background thread
 @return NSManagedObjectContext object configured with background thread
 @code
 NSManagedObjectContext *ctx = [manager createBackgroundContext];
 [ctx performBlock:^{
     // This block run in background thread
 }];
 @endcode
 */
- (NSManagedObjectContext * _Nonnull)createBackgroundContext;

@end
