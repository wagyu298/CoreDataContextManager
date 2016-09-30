// This is free and unencumbered software released into the public domain.
// For more information, please refer to <http://unlicense.org/>

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObjectContext+BackgroundThread.h"
#import "FetchedResultsControllerDelegate.h"

@interface CoreDataContext : NSObject

@property (nonnull, nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonnull, nonatomic, strong, readonly) NSURL *urlOfPersistentStore;
@property (nonnull, nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonnull, nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nullable, nonatomic, strong, readonly) NSString *databaseName;
@property (nullable, nonatomic, strong, readonly) NSURL *directory;

- (id)initWithDatabaseName:(NSString * _Nonnull)databaseName directory:(NSURL * _Nonnull)directory;
- (id)initWithDatabaseName:(NSString * _Nonnull)databaseName;

- (NSManagedObjectContext * _Nonnull)createBackgroundContext;
- (NSManagedObjectContext * _Nonnull)currentManagedObjectContext;

@end
