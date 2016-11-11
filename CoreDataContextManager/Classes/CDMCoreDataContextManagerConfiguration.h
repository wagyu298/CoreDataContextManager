// This is free and unencumbered software released into the public domain.
// For more information, please refer to <http://unlicense.org/>

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/*!
 @class CDMCoreDataContextManagerConfiguration
 @brief It provides CDMCoreDataContextManager configurations
 */
@interface CDMCoreDataContextManagerConfiguration : NSObject

/// @brief storeType; one of the NSSQLiteStoreType, NSBinaryStoreType or NSInMemoryStoreType
@property (nonatomic, strong, nonnull) NSString *storeType;

/// @brief URL of a CoreData model file (.xcdatamodeld file)
@property (nonatomic, strong, nonnull) NSURL *mappingModelURL;

/// @brief URL for NSPersistentStoreCoordinator, it locates a real database file
@property (nonatomic, strong, nonnull) NSURL *persistentStoreURL;

/// @brief Enable auto save
@property (nonatomic) BOOL autoSave;

/// @brief Extra option for initialize NSPersistentStoreCoordinator
@property (nonatomic, strong, nonnull) NSDictionary *storeOptions;

/*!
 @brief Initialize configuration with storeType
 @param storeType NSSQLiteStoreType, NSBinaryStoreType or NSInMemoryStoreType
 */
- (instancetype _Nonnull)initWithStoreType:(NSString * _Nonnull)storeType;

/*!
 @brief Initialize configuration with storeType and database name
 @param storeType NSSQLiteStoreType, NSBinaryStoreType or NSInMemoryStoreType
 @param databaseName Database file name (prefix of .xcdatamodeld file)
 */
- (instancetype _Nonnull)initWithStoreType:(NSString * _Nonnull)storeType databaseName:(NSString * _Nonnull)databaseName;

/*!
 @brief Returns mappingModelURL with NSBundle and database name
 @param bundle A bundle object
 @param databaseName Database file name (prefix of .xcdatamodeld file)
 @return URL for mappingModelURL
 */
- (NSURL * _Nonnull)mappingModelURLWithBundle:(NSBundle * _Nonnull)bundle databaseName:(NSString * _Nonnull)databaseName;

/*!
 @brief Returns mappingModelURL with mainBundle and database name
 @param databaseName Database file name (prefix of .xcdatamodeld file)
 @return URL for mappingModelURL
 */
- (NSURL * _Nonnull)mappingModelURLWithDatabaseName:(NSString * _Nonnull)databaseName;

/*!
 @brief Set mappingModelURL property with NSBundle and database name
 @param bundle A bundle object
 @param databaseName Database file name (prefix of .xcdatamodeld file)
 */
- (void)setMappingModelURLWithBundle:(NSBundle * _Nonnull)bundle databaseName:(NSString * _Nonnull)databaseName;

/*!
 @brief Set mappingModelURL property with mainBundle and database name
 @param databaseName Database file name (prefix of .xcdatamodeld file)
 */
- (void)setMappingModelURLWithDatabaseName:(NSString * _Nonnull)databaseName;

/*!
 @brief Returns real database file name
 @param storeType NSSQLiteStoreType, NSBinaryStoreType or NSInMemoryStoreType
 @param databaseName Database file name (prefix of .xcdatamodeld file)
 @return A database file name
 */
- (NSString * _Nullable)databaseFileNameWithStoreType:(NSString * _Nonnull)storeType databaseName:(NSString * _Nonnull)databaseName;

/*!
 @brief Returns persitent store URL
 @param storeType NSSQLiteStoreType, NSBinaryStoreType or NSInMemoryStoreType
 @param directoryURL A directory URL for persitent store
 @param databaseName Database file name (prefix of .xcdatamodeld file)
 @return URL for persistent store
 */
- (NSURL * _Nullable)persistentStoreURLWithStoreType:(NSString * _Nonnull)storeType directoryURL:(NSURL * _Nullable)directoryURL databaseName:(NSString * _Nonnull)databaseName;

/*!
 @brief Returns persitent store URL
 @param storeType NSSQLiteStoreType, NSBinaryStoreType or NSInMemoryStoreType
 @param URLsForDirectory NSSearchPathDirectory for persitent store
 @param databaseName Database file name (prefix of .xcdatamodeld file)
 @return URL for persistent store
 */
- (NSURL * _Nullable)persistentStoreURLWithStoreType:(NSString * _Nonnull)storeType URLsForDirectory:(NSSearchPathDirectory)URLsForDirectory databaseName:(NSString * _Nonnull)databaseName;

/*!
 @brief Returns persitent store URL with NSDocumentDirectory
 @param storeType NSSQLiteStoreType, NSBinaryStoreType or NSInMemoryStoreType
 @param databaseName Database file name (prefix of .xcdatamodeld file)
 @return URL for persistent store
*/
- (NSURL * _Nullable)persistentStoreURLWithStoreType:(NSString * _Nonnull)storeType databaseName:(NSString * _Nonnull)databaseName;

/*!
 @brief Set persitent store URL
 @param storeType NSSQLiteStoreType, NSBinaryStoreType or NSInMemoryStoreType
 @param directoryURL A directory URL for persitent store
 @param databaseName Database file name (prefix of .xcdatamodeld file)
 */
- (void)setPersistentStoreURLWithStoreType:(NSString * _Nonnull)storeType directoryURL:(NSURL * _Nullable)directoryURL databaseName:(NSString * _Nonnull)databaseName;

/*!
 @brief Set persitent store URL
 @param storeType NSSQLiteStoreType, NSBinaryStoreType or NSInMemoryStoreType
 @param URLsForDirectory NSSearchPathDirectory for persitent store
 @param databaseName Database file name (prefix of .xcdatamodeld file)
 */
- (void)setPersistentStoreURLWithStoreType:(NSString * _Nonnull)storeType URLsForDirectory:(NSSearchPathDirectory)URLsForDirectory databaseName:(NSString * _Nonnull)databaseName;

/*!
 @brief Set persitent store URL with NSDocumentDirectory
 @param storeType NSSQLiteStoreType, NSBinaryStoreType or NSInMemoryStoreType
 @param databaseName Database file name (prefix of .xcdatamodeld file)
 */
- (void)setPersistentStoreURLWithStoreType:(NSString * _Nonnull)storeType databaseName:(NSString * _Nonnull)databaseName;

@end

/*!
 @class CDMCoreDataContextManagerSQLLiteConfiguration
 @brief CDMCoreDataContextManager sub class for SQLite database
 */
@interface CDMCoreDataContextManagerSQLLiteConfiguration : CDMCoreDataContextManagerConfiguration

/*!
 @brief Initialize configuration with database name
 @param databaseName Database file name (prefix of .xcdatamodeld file)
 */
- (instancetype _Nonnull)initWithDatabaseName:(NSString * _Nonnull)databaseName;

@end

/*!
 @class CDMCoreDataContextManagerBinaryConfiguration
 @brief CDMCoreDataContextManager sub class for Binary database
 */
@interface CDMCoreDataContextManagerBinaryConfiguration : CDMCoreDataContextManagerConfiguration

/*!
 @brief Initialize configuration with database name
 @param databaseName Database file name (prefix of .xcdatamodeld file)
 */
- (instancetype _Nonnull)initWithDatabaseName:(NSString * _Nonnull)databaseName;

@end

/*!
 @class CDMCoreDataContextManagerInMemoryConfiguration
 @brief CDMCoreDataContextManager sub class for InMemory database
 */
@interface CDMCoreDataContextManagerInMemoryConfiguration : CDMCoreDataContextManagerConfiguration

/*!
 @brief Initialize configuration with database name
 @param databaseName Database file name (prefix of .xcdatamodeld file)
 */
- (instancetype _Nonnull)initWithDatabaseName:(NSString * _Nonnull)databaseName;

@end
