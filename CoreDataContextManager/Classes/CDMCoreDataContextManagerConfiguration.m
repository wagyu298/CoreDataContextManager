// This is free and unencumbered software released into the public domain.
// For more information, please refer to <http://unlicense.org/>

#import "CDMCoreDataContextManagerConfiguration.h"

@interface CDMCoreDataContextManagerConfiguration ()

@end

@implementation CDMCoreDataContextManagerConfiguration

#pragma mark - Mapping model URL

- (NSURL * _Nonnull)mappingModelURLWithBundle:(NSBundle * _Nonnull)bundle databaseName:(NSString * _Nonnull)databaseName {
    return [bundle URLForResource:databaseName withExtension:@"momd"];
}

- (NSURL * _Nonnull)mappingModelURLWithDatabaseName:(NSString * _Nonnull)databaseName {
    // Create mapping model URL with main bundle
    return [self mappingModelURLWithBundle:[NSBundle mainBundle] databaseName:databaseName];
}

- (void)setMappingModelURLWithBundle:(NSBundle * _Nonnull)bundle databaseName:(NSString * _Nonnull)databaseName {
    self.mappingModelURL = [self mappingModelURLWithBundle:bundle databaseName:databaseName];
}

- (void)setMappingModelURLWithDatabaseName:(NSString * _Nonnull)databaseName {
    self.mappingModelURL = [self mappingModelURLWithDatabaseName:databaseName];
}

#pragma mark - Persistent store URL

- (NSString * _Nullable)databaseFileNameWithStoreType:(NSString * _Nonnull)storeType databaseName:(NSString * _Nonnull)databaseName {
    NSString *fileName;
    if ([storeType isEqualToString:NSSQLiteStoreType]) {
        fileName = [NSString stringWithFormat:@"%@.sqlite", databaseName];
    } else if ([storeType isEqualToString:NSBinaryStoreType]) {
        fileName = [NSString stringWithFormat:@"%@.binary", databaseName];
    } else {
        fileName = databaseName;    // Unknown store type
    }
    return fileName;
}

- (NSURL * _Nullable)persistentStoreURLWithStoreType:(NSString * _Nonnull)storeType directoryURL:(NSURL * _Nullable)directoryURL databaseName:(NSString * _Nonnull)databaseName {
    if ([storeType isEqualToString:NSInMemoryStoreType]) {
        return nil;
    } else {
        NSString *fileName = [self databaseFileNameWithStoreType:storeType databaseName:databaseName];
        return [directoryURL URLByAppendingPathComponent:fileName];
    }
}

- (NSURL * _Nullable)persistentStoreURLWithStoreType:(NSString * _Nonnull)storeType URLsForDirectory:(NSSearchPathDirectory)URLsForDirectory databaseName:(NSString * _Nonnull)databaseName {
    NSURL *directoryURL = [[[NSFileManager defaultManager] URLsForDirectory:URLsForDirectory inDomains:NSUserDomainMask] lastObject];
    return [self persistentStoreURLWithStoreType:storeType directoryURL:directoryURL databaseName:databaseName];
}

- (NSURL * _Nullable)persistentStoreURLWithStoreType:(NSString * _Nonnull)storeType databaseName:(NSString * _Nonnull)databaseName {
    // Create persistent store URL with document directory
    return [self persistentStoreURLWithStoreType:storeType URLsForDirectory:NSDocumentDirectory databaseName:databaseName];
}

- (void)setPersistentStoreURLWithStoreType:(NSString * _Nonnull)storeType directoryURL:(NSURL * _Nullable)directoryURL databaseName:(NSString * _Nonnull)databaseName {
    self.persistentStoreURL = [self persistentStoreURLWithStoreType:storeType directoryURL:directoryURL databaseName:databaseName];
}

- (void)setPersistentStoreURLWithStoreType:(NSString * _Nonnull)storeType URLsForDirectory:(NSSearchPathDirectory)URLsForDirectory databaseName:(NSString * _Nonnull)databaseName {
    self.persistentStoreURL = [self persistentStoreURLWithStoreType:storeType URLsForDirectory:URLsForDirectory databaseName:databaseName];
}

- (void)setPersistentStoreURLWithStoreType:(NSString * _Nonnull)storeType databaseName:(NSString * _Nonnull)databaseName {
    self.persistentStoreURL = [self persistentStoreURLWithStoreType:storeType databaseName:databaseName];
}

- (instancetype _Nonnull)init {
    self = [super init];
    if (self) {
        self.autoSave = YES;
    }
    return self;
}

- (instancetype _Nonnull)initWithStoreType:(NSString * _Nonnull)storeType {
    self = [super init];
    if (self) {
        self.storeType = storeType;
        self.autoSave = YES;
    }
    return self;
}

- (instancetype _Nonnull)initWithStoreType:(NSString * _Nonnull)storeType databaseName:(NSString * _Nonnull)databaseName {
    self = [super init];
    if (self) {
        self.storeType = storeType;
        self.autoSave = YES;
        [self setMappingModelURLWithDatabaseName:databaseName];
        [self setPersistentStoreURLWithStoreType:storeType databaseName:databaseName];
    }
    return self;
}

@end

@implementation CDMCoreDataContextManagerSQLLiteConfiguration

- (instancetype _Nonnull)initWithDatabaseName:(NSString * _Nonnull)databaseName {
    return [super initWithStoreType:NSSQLiteStoreType databaseName:databaseName];
}

@end

@implementation CDMCoreDataContextManagerBinaryConfiguration

- (instancetype _Nonnull)initWithDatabaseName:(NSString * _Nonnull)databaseName {
    return [super initWithStoreType:NSBinaryStoreType databaseName:databaseName];
}

@end

@implementation CDMCoreDataContextManagerInMemoryConfiguration

- (instancetype _Nonnull)initWithDatabaseName:(NSString * _Nonnull)databaseName {
    return [super initWithStoreType:NSInMemoryStoreType databaseName:databaseName];
}

@end
