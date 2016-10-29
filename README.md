# CoreDataContextManager

CoreData helpers for auto-migration and multi threading.

## Usage

Modify your AppDelegate like this.
If you already enabled CoreData with Xcode default templates, remove entire code before using CoreDataContextManager.

```
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonnull, strong, nonatomic) UIWindow *window;
@property (nonnull, strong, nonatomic) CDMCoreDataContextManager *coreDataContextManager;
@property (nonnull, strong, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

@end
```

You should pass a model file name prefix to the constructor method `[[CDMCoreDataContextManager alloc] initWithDatabaseName:]`.
If you create the model file that named `MyDatabase.xcdatamodeld`, call the method like `[[CDMCoreDataContextManager alloc] initWithDatabaseName:@"MyDatabase"]`.

```
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.coreDataContextManager = [[CoreDataContextManager alloc] initWithDatabaseName:@"MyDatabase"];
    return YES;
}

- (NSManagedObjectContext * _Nonnull)managedObjectContext {
    return self.coreDataContextManager.managedObjectContext;
}

@end
```

All settings are done. You can get NSManagedObjectContext by the following code.

```
AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
NSManagedObjectContext *moc = appDelegate.managedObjectContext;
```

## Features

### Auto migration

CoreDataContextManager automatically migration your xcdatamodeld file changes.
To migrate the database, add new model version to your App.
You can add model version from Xcode menu `Editor -> Add Model Version...`.

### Multi threading

You can create NSManagedObjectContext for none-UI thread by `[coreDataContextManager createBackgroundContext]` method.

```
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSManagedObjectContext *managedObjectContext = [self.coreDataContextManager createBackgroundContext];
    // CoreData operations...

    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
        NSLog(@"%@", error);
    }
});
```

CoreDataContextManager object observe NSManagedObjectContextDidSaveNotification notifiation.
`[managedObjectContext save:]` will trigger mergeChangesFromContextDidSaveNotification with main context.
It means, you does not need to do anything after [managedObjectContext save:] in background thread.

### Auto save when app resign active

CoreDataContextManager automatically save uncommited change operations when your App will resign active (UIApplicationWillResignActiveNotification posted).

To enable this feature, initialize CoreDataContextManager with `CoreDataContextManagerOptionsAutoSave`.

```
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.coreDataContextManager = [[CoreDataContextManager alloc] initWithDatabaseName:@"MyDatabase" options:CoreDataContextManagerOptionsAutoSave];
    return YES;
}

@end
```

### Example implementation of FetchedResultsControllerDelegate

CoreDataContextManager includes example implementation of FetchedResultsControllerDelegate (that named CDMFetchedResultsControllerDelegateDataSource).
