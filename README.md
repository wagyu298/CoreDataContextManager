# CoreDataContext

CoreData helpers for auto-migration and multi threading.

## Usage

Modify your AppDelegate like this.
If you already enabled CoreData with Xcode default templates, remove entire code before using CoreDataContext.

```
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonnull, strong, nonatomic) UIWindow *window;
@property (nonnull, strong, nonatomic) CoreDataContext *coreDataContext;
@property (nonnull, strong, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

@end
```

You should pass a model file name prefix to the constructor method `[[CoreDataContext alloc] initWithDatabaseName:]`.
If you create the model file that named `MyDatabase.xcdatamodeld`, call the method like `[context initWithDatabaseName:@"MyDatabase"]`.

```
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.coreDataContext = [[CoreDataContext alloc] initWithDatabaseName:@"MyDatabase"];
    return YES;
}

- (NSManagedObjectContext * _Nonnull)managedObjectContext {
    return self.coreDataContext.managedObjectContext;
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

CoreDataContext automatically migration your xcdatamodeld file changes.
To migrate the database, add new model version to your App.
You can add model version from Xcode menu `Editor -> Add Model Version...`.

### Multi threading

You can create NSManagedObjectContext for none-UI thread by `[context createBackgroundContext]` method.

```
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSManagedObjectContext *context = [coreDataContext createBackgroundContext];
    // CoreData operations...

    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"%@", error);
    }
});
```

CoreDataContext object observe NSManagedObjectContextDidSaveNotification notifiation.
`[context save:]` will trigger mergeChangesFromContextDidSaveNotification with main context.
You does not need to do anything after [context save:] in background thread.

### Auto save when app enter to background

CoreDataContext automatically save uncommited change operations when your App enter to background (UIApplicationDidEnterBackgroundNotification posted).

To disable this feature, initialize CoreDataContext with `CoreDataContextOptionsNone` and call `[context saveIfChanged:]` method instead.

```
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.coreDataContext = [[CoreDataContext alloc] initWithDatabaseName:@"MyDatabase" options:CoreDataContextOptionsNone];
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSError *error = nil;
    if (![self.coreDataContext saveIfChanged:&error]) {
        NSLog(@"Core Data error: %@, %@", error, [error userInfo]);
    }
}
@end
```

### Example implementation of FetchedResultsControllerDelegate

CoreDataContext includes example implementation of FetchedResultsControllerDelegate.
