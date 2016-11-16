# CoreDataContextManager

CoreData helpers with lightweight migration and multi threading.

[![Build Status](https://travis-ci.org/wagyu298/CoreDataContextManager.svg?branch=master)](https://travis-ci.org/wagyu298/CoreDataContextManager)

## Features

- Automatically apply lightweight migration with xcdatamodel file versions
- Multi threading with context management
- General implementation of NSFetchedResultsControllerDelegate
- Useful helper category methods for NSManagedObjectContext

## Usage

Add CDMCoreDataContextManager to your AppDelegate class and initialize it in
`[application:didFinishLaunchingWithOptions:]` method.
If you already enabled CoreData with Xcode default templates, remove entire code before using CoreDataContextManager.

```
@import CoreDataContextManager;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonnull, strong, nonatomic) UIWindow *window;
@property (nonnull, strong, nonatomic) CDMCoreDataContextManager *coreDataContextManager;
@property (nonnull, strong, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

@end
```

You should pass a model file name prefix to the constructor method `[[CDMCoreDataContextManager alloc] initWithSQLiteDatabaseName:]`.
If you create the model file that named `MyDatabase.xcdatamodeld`, call the method like `[[CDMCoreDataContextManager alloc] initWithSQLiteDatabaseName:@"MyDatabase"]`.

```
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.coreDataContextManager = [[CoreDataContextManager alloc] initWithSQLiteDatabaseName:@"MyDatabase"];
    return YES;
}

- (NSManagedObjectContext * _Nonnull)managedObjectContext {
    return self.coreDataContextManager.managedObjectContext;
}

@end
```

After that, you can get NSManagedObjectContext by the following code.

```
AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
NSManagedObjectContext *moc = appDelegate.managedObjectContext;
```

### Constructors

CoreDataContextManager has some type constructors to initialize with SQLite, Binary or InMemory type database.

```
// SQLite database
- (instancetype _Nonnull)initWithSQLiteDatabaseName:(NSString * _Nonnull)databaseName autoSave:(BOOL)autoSave;
- (instancetype _Nonnull)initWithSQLiteDatabaseName:(NSString * _Nonnull)databaseName;

// Binary database
- (instancetype _Nonnull)initWithBinaryDatabaseName:(NSString * _Nonnull)databaseName autoSave:(BOOL)autoSave;
- (instancetype _Nonnull)initWithBinaryDatabaseName:(NSString * _Nonnull)databaseName;

// InMemory database
- (instancetype _Nonnull)initWithInMemoryDatabaseName:(NSString * _Nonnull)databaseName autoSave:(BOOL)autoSave;
- (instancetype _Nonnull)initWithInMemoryDatabaseName:(NSString * _Nonnull)databaseName;

// Constructor with specified store type, such as NSSQLiteStoreType
- (instancetype _Nonnull)initWithStoreType:(NSString * _Nonnull)storeType databaseName:(NSString * _Nonnull)databaseName autoSave:(BOOL)autoSave;
- (instancetype _Nonnull)initWithStoreType:(NSString * _Nonnull)storeType databaseName:(NSString * _Nonnull)databaseName;
```

If you want to apply more customization to initialize,
use CDMCoreDataContextManagerConfiguration class and
initWithConfiguration constructor.
Please see CDMCoreDataContextManagerConfiguration source code for more details.

```
- (instancetype _Nonnull)initWithConfiguration:(CDMCoreDataContextManagerConfiguration * _Nonnull)configuration;
```

## Features

### Lightweight migration

CoreDataContextManager automatically migrate your xcdatamodeld file changes
with CoreData lightweight migration.
To migrate the database, add new model version to your App.
You can add model version from Xcode menu `Editor -> Add Model Version...`.

### Multi threading

You can create NSManagedObjectContext for background thread by `[coreDataContextManager createBackgroundContext]` method.

```
NSManagedObjectContext *managedObjectContext = [self.coreDataContextManager createBackgroundContext];

[managedObjectContext performBlock:^{
    // This block run in none-UI thread

    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
        NSLog(@"%@", error);
    }
}];
```

`[managedObjectContext save:]` will trigger mergeChangesFromContextDidSaveNotification with main context.
CoreDataContextManager object observe NSManagedObjectContextDidSaveNotification notifiation and merge changes from background thread into the database.
(You does not need to do anything after [managedObjectContext save:] in background thread.)

### Auto save when app resign active

CoreDataContextManager automatically save uncommited change operations when your App will resign active (UIApplicationWillResignActiveNotification posted).

To disable this feature, call constructor with `autoSave:NO` argument.

```
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.coreDataContextManager = [[CoreDataContextManager alloc] initWithSQLiteDatabaseName:@"MyDatabase" autoSave:NO];
    return YES;
}

@end
```

### General implementation of FetchedResultsControllerDelegate

CoreDataContextManager includes general implementation of FetchedResultsControllerDelegate.
See example application in repository for more details.

### NSManagedObjectContext helper methods

CoreDataContextManager add `NSManagedObjectContext (CoreDataContextManager)` category.
The category contains the following methods.

```
// Create child managed object context for multithreading,
// same as [CoreDataContextManager createBackgroundContext]
- (NSManagedObjectContext * _Nonnull)cdm_createChildManagedObjectContext;

// Save if NSManagedObjectContext has changed
- (BOOL)cdm_saveChanges:(NSError * _Nullable * _Nullable)error;

// Delete all entity objects
- (BOOL)cdm_deleteWithEntityName:(NSString * _Nonnull)entityName error:(NSError * _Nullable * _Nullable)error;
```
