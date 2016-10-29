// This is free and unencumbered software released into the public domain.
// For more information, please refer to <http://unlicense.org/>

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObjectContext+CoreDataContextManager.h"
#import "CDMFetchedResultsControllerDelegate.h"

typedef NS_OPTIONS(NSUInteger, CDMCoreDataContextManagerOptions) {
    CDMCoreDataContextManagerOptionsNone = 0,
    CDMCoreDataContextManagerOptionsAutoSave = 0x1,
    CDMCoreDataContextManagerOptionsDefault = 0,
};

@interface CDMCoreDataContextManager : NSObject

@property (nonnull, nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonnull, nonatomic, strong, readonly) NSURL *urlOfPersistentStore;
@property (nonnull, nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonnull, nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (instancetype _Nonnull)initWithDatabaseName:(NSString * _Nonnull)databaseName directory:(NSURL * _Nullable)directory storeType:(NSString * _Nonnull)storeType options:(CDMCoreDataContextManagerOptions)options;
- (instancetype _Nonnull)initWithDatabaseName:(NSString * _Nonnull)databaseName storeType:(NSString * _Nonnull)storeType;
- (instancetype _Nonnull)initWithDatabaseName:(NSString * _Nonnull)databaseName options:(CDMCoreDataContextManagerOptions)options;
- (instancetype _Nonnull)initWithDatabaseName:(NSString * _Nonnull)databaseName;

- (NSManagedObjectContext * _Nonnull)createBackgroundContext;
- (NSManagedObjectContext * _Nonnull)currentManagedObjectContext;

- (BOOL)saveIfChanged:(NSError * _Nullable * _Nullable)error;

@end
