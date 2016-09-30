// This is free and unencumbered software released into the public domain.
// For more information, please refer to <http://unlicense.org/>

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObjectContext+BackgroundThread.h"
#import "FetchedResultsControllerDelegate.h"

@interface CoreDataContext : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSURL *urlOfPersistentStore;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (readonly, strong, nonatomic) NSString *databaseName;
@property (readonly, strong, nonatomic) NSURL *directory;

- (id)initWithDatabaseName:(NSString *)databaseName directory:(NSURL *)directory;
- (id)initWithDatabaseName:(NSString *)databaseName;

- (NSManagedObjectContext *)createBackgroundContext;
- (NSManagedObjectContext *)currentManagedObjectContext;

@end
