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

+ (AppDelegate *)appDelegate;

@end
```

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

You should pass a model file name prefix to the constructor method `[[CoreDataContext alloc] initWithDatabaseName:]`.
If you create the model file that named `MyDatabase.xcdatamodeld`, call the method like `[context initWithDatabaseName:@"MyDatabase"]`.

## Features

### Auto save when app enter to background

CoreDataContext automatically save uncommited change operations when UIApplicationDidEnterBackgroundNotification posted.

### Auto migration

CoreDataContext automatically migration your xcdatamodeld file changes.
To migrate the database, add model version to your App.
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

### Example implementation of FetchedResultsControllerDelegate

CoreDataContext includes example implementation of FetchedResultsControllerDelegate.
