// This is free and unencumbered software released into the public domain.
// For more information, please refer to <http://unlicense.org/>

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CDMCoreDataContextManagerConfiguration : NSObject

@property (nonatomic, strong, nonnull) NSString *storeType;
@property (nonatomic, strong, nonnull) NSURL *mappingModelURL;
@property (nonatomic, strong, nonnull) NSURL *persistentStoreURL;
@property (nonatomic) BOOL autoSave;
@property (nonatomic, strong, nonnull) NSDictionary *storeOptions;

- (instancetype _Nonnull)initWithStoreType:(NSString * _Nonnull)storeType;
- (instancetype _Nonnull)initWithStoreType:(NSString * _Nonnull)storeType databaseName:(NSString * _Nonnull)databaseName;

- (NSURL * _Nonnull)mappingModelURLWithBundle:(NSBundle * _Nonnull)bundle databaseName:(NSString * _Nonnull)databaseName;
- (NSURL * _Nonnull)mappingModelURLWithDatabaseName:(NSString * _Nonnull)databaseName;
- (void)setMappingModelURLWithBundle:(NSBundle * _Nonnull)bundle databaseName:(NSString * _Nonnull)databaseName;
- (void)setMappingModelURLWithDatabaseName:(NSString * _Nonnull)databaseName;

- (NSString * _Nullable)databaseFileNameWithStoreType:(NSString * _Nonnull)storeType databaseName:(NSString * _Nonnull)databaseName;
- (NSURL * _Nullable)persistentStoreURLWithStoreType:(NSString * _Nonnull)storeType directoryURL:(NSURL * _Nullable)directoryURL databaseName:(NSString * _Nonnull)databaseName;
- (NSURL * _Nullable)persistentStoreURLWithStoreType:(NSString * _Nonnull)storeType URLsForDirectory:(NSSearchPathDirectory)URLsForDirectory databaseName:(NSString * _Nonnull)databaseName;
- (NSURL * _Nullable)persistentStoreURLWithStoreType:(NSString * _Nonnull)storeType databaseName:(NSString * _Nonnull)databaseName;

- (void)setPersistentStoreURLWithStoreType:(NSString * _Nonnull)storeType directoryURL:(NSURL * _Nullable)directoryURL databaseName:(NSString * _Nonnull)databaseName;
- (void)setPersistentStoreURLWithStoreType:(NSString * _Nonnull)storeType URLsForDirectory:(NSSearchPathDirectory)URLsForDirectory databaseName:(NSString * _Nonnull)databaseName;
- (void)setPersistentStoreURLWithStoreType:(NSString * _Nonnull)storeType databaseName:(NSString * _Nonnull)databaseName;

@end

@interface CDMCoreDataContextManagerSQLLiteConfiguration : CDMCoreDataContextManagerConfiguration

- (instancetype _Nonnull)initWithDatabaseName:(NSString * _Nonnull)databaseName;

@end

@interface CDMCoreDataContextManagerBinaryConfiguration : CDMCoreDataContextManagerConfiguration

- (instancetype _Nonnull)initWithDatabaseName:(NSString * _Nonnull)databaseName;

@end

@interface CDMCoreDataContextManagerInMemoryConfiguration : CDMCoreDataContextManagerConfiguration

- (instancetype _Nonnull)initWithDatabaseName:(NSString * _Nonnull)databaseName;

@end
