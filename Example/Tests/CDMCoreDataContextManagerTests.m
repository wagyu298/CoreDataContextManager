// This software is released under the MIT License.
// http://opensource.org/licenses/mit-license.php

#import <string.h>
#import <sqlite3.h>
#import <CoreDataContextManager/CoreDataContextManager.h>

#import "ExampleData+CoreDataClass.h"

static NSMutableArray *tableInfoDest;

static int
eatTableInfo(void *data, int argc, char **argv, char **azColName)
{
    NSMutableDictionary *rowInfo = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < argc; i++) {
        NSString *colName = [NSString stringWithCString:azColName[i] encoding:NSUTF8StringEncoding];
        if (argv[i] != NULL) {
            rowInfo[colName] = [NSString stringWithCString:argv[i] encoding:NSUTF8StringEncoding];
        } else {
            rowInfo[colName] = [NSNull null];
        }
    }
    [tableInfoDest addObject:rowInfo];
    return 0;
}

static NSArray *
tableInfo(sqlite3 *db, NSString *tableName)
{
    NSString *sql = [NSString stringWithFormat:@"PRAGMA table_info(%@)", tableName];
    tableInfoDest = [[NSMutableArray alloc] init];
    
    char *zErrMsg = 0;
    int rc = sqlite3_exec(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], eatTableInfo, NULL, &zErrMsg);
    if (rc != SQLITE_OK) {
        NSLog(@"SQL error: %s", zErrMsg);
        sqlite3_free(zErrMsg);
        return nil;
    }
    
    NSArray *rv = tableInfoDest;
    tableInfoDest = nil;
    return rv;
}

SpecBegin(CDMCoreDataContextManagerSpecs)

describe(@"CDMCoreDataContextManager", ^{
    __block CDMCoreDataContextManager *manager;
    
    beforeEach(^{
        manager = [[CDMCoreDataContextManager alloc] initWithInMemoryDatabaseName:@"CoreDataContextManagerExample"];
    });
    
    it(@"create context manager", ^{
        expect(manager).to.beTruthy();
    });
    
    it(@"create data from main thread", ^{
        NSManagedObjectContext *context = manager.managedObjectContext;
        ExampleData *data = [NSEntityDescription insertNewObjectForEntityForName:@"ExampleData" inManagedObjectContext:context];
        data.title = @"title";
        data.section = @"section";
        data.number = 1;
        data.updatedAt = [NSDate date];
        
        NSError *error = nil;
        BOOL rv = [context save:&error];
        expect(rv).to.beTruthy();
        expect(error).to.beNil();
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"ExampleData" inManagedObjectContext:context]];
        
        NSArray *results = [context executeFetchRequest:request error:&error];
        expect(results).to.beTruthy();
        expect(error).to.beNil();
        expect([results count]).to.equal(1);
        data = results[0];
        expect(data.title).to.equal(@"title");
        expect(data.section).to.equal(@"section");
        expect(data.number).to.equal(1);
    });
    
    it(@"create data from child thread", ^{
        waitUntil(^(DoneCallback done) {
            NSManagedObjectContext *context = [manager createBackgroundContext];
            [context performBlock:^{
                ExampleData *data = [NSEntityDescription insertNewObjectForEntityForName:@"ExampleData" inManagedObjectContext:context];
                data.title = @"title";
                data.section = @"section";
                data.number = 1;
                data.updatedAt = [NSDate date];
                
                NSError *error = nil;
                BOOL rv = [context save:&error];
                expect(rv).to.beTruthy();
                expect(error).to.beNil();
                
                done();
            }];
        });
        
        NSManagedObjectContext *context = manager.managedObjectContext;
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"ExampleData" inManagedObjectContext:context]];
        
        NSError *error = nil;
        NSArray *results = [context executeFetchRequest:request error:&error];
        expect(results).to.beTruthy();
        expect(error).to.beNil();
        expect([results count]).to.equal(1);
        ExampleData *data = results[0];
        expect(data.title).to.equal(@"title");
        expect(data.section).to.equal(@"section");
        expect(data.number).to.equal(1);
    });
    
    describe(@"currentContext", ^{
        it(@"w/ main thread", ^{
            expect(manager.currentContext).to.equal(manager.managedObjectContext);
        });
        
        it(@"create data w/ current thread context", ^{
            NSManagedObjectContext *managedContext = manager.managedObjectContext;
            
            waitUntil(^(DoneCallback done) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSManagedObjectContext *context = [manager currentContext];
                    expect(managedContext).notTo.equal(context);
                    expect([manager currentContext]).to.equal(context);
                    
                    [context performBlock:^{
                        ExampleData *data = [NSEntityDescription insertNewObjectForEntityForName:@"ExampleData" inManagedObjectContext:context];
                        data.title = @"title";
                        data.section = @"section";
                        data.number = 1;
                        data.updatedAt = [NSDate date];
                        
                        NSError *error = nil;
                        BOOL rv = [context save:&error];
                        expect(rv).to.beTruthy();
                        expect(error).to.beNil();
                        
                        done();
                    }];
                });
            });
            
            NSManagedObjectContext *context = manager.managedObjectContext;
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:[NSEntityDescription entityForName:@"ExampleData" inManagedObjectContext:context]];
            
            NSError *error = nil;
            NSArray *results = [context executeFetchRequest:request error:&error];
            expect(results).to.beTruthy();
            expect(error).to.beNil();
            expect([results count]).to.equal(1);
            ExampleData *data = results[0];
            expect(data.title).to.equal(@"title");
            expect(data.section).to.equal(@"section");
            expect(data.number).to.equal(1);
        });
    });
    
});

describe(@"Light weight migration", ^{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *sqlite3Path = [documentsPath stringByAppendingPathComponent:@"CoreDataContextManagerExample.sqlite"];
    
    beforeAll(^{
        NSError *error = nil;
        BOOL rv = [fileManager removeItemAtPath:sqlite3Path error:&error];
        expect(rv).to.beTruthy();
        expect(error).to.beNil();
        
        NSArray *files = @[
                               @"CoreDataContextManagerExample.sqlite-shm",
                               @"CoreDataContextManagerExample.sqlite-wal",
                               ];
        for (NSString *file in files) {
            NSString *filePath = [documentsPath stringByAppendingPathComponent:file];
            BOOL rv = [fileManager removeItemAtPath:filePath error:&error];
            expect(rv).to.beTruthy();
            expect(error).to.beNil();
        }
    });

    it(@"before migrate", ^{
        CDMCoreDataContextManagerConfiguration *config = [[CDMCoreDataContextManagerSQLLiteConfiguration alloc] initWithDatabaseName:@"CoreDataContextManagerExample"];
        [config setMappingModelURLWithDatabaseName:@"CoreDataContextManagerExample_v1"];
        
        CDMCoreDataContextManager *manager = [[CDMCoreDataContextManager alloc] initWithConfiguration:config];
        expect(manager).to.beTruthy();
        
        NSManagedObjectContext *context = manager.managedObjectContext;
        NSManagedObject *data = [NSEntityDescription insertNewObjectForEntityForName:@"ExampleData" inManagedObjectContext:context];
        [data setValue:@"title" forKey:@"title"];
        [data setValue:@"section" forKey:@"section"];
        [data setValue:@1 forKey:@"number"];
        
        NSEntityDescription *description = [data entity];
        expect([description.properties count]).to.equal(3);
        expect(description.properties[0].name).to.equal(@"number");
        expect(description.properties[1].name).to.equal(@"section");
        expect(description.properties[2].name).to.equal(@"title");
        
        NSError *error = nil;
        BOOL rv = [context save:&error];
        expect(rv).to.beTruthy();
        expect(error).to.beNil();
        
        sqlite3 *db;
        int rc = sqlite3_open([sqlite3Path fileSystemRepresentation], &db);
        expect(rc == 0).to.beTruthy();
        if (rc == 0) {
            NSArray *info = tableInfo(db, @"ZEXAMPLEDATA");
            expect(info).notTo.beNil();
            expect([info count]).to.equal(6);
            expect(info[0][@"name"]).to.equal(@"Z_PK");
            expect(info[1][@"name"]).to.equal(@"Z_ENT");
            expect(info[2][@"name"]).to.equal(@"Z_OPT");
            expect(info[3][@"name"]).to.equal(@"ZNUMBER");
            expect(info[4][@"name"]).to.equal(@"ZSECTION");
            expect(info[5][@"name"]).to.equal(@"ZTITLE");
            sqlite3_close(db);
        }
    });
    
    it(@"Migrate", ^{
        CDMCoreDataContextManagerConfiguration *config = [[CDMCoreDataContextManagerSQLLiteConfiguration alloc] initWithDatabaseName:@"CoreDataContextManagerExample"];
        
        CDMCoreDataContextManager *manager = [[CDMCoreDataContextManager alloc] initWithConfiguration:config];
        expect(manager).to.beTruthy();
        
        NSManagedObjectContext *context = manager.managedObjectContext;
        
        NSError *error = nil;
        NSFetchRequest *req = [[NSFetchRequest alloc] initWithEntityName:@"ExampleData"];
        NSArray *results = [context executeFetchRequest:req error:&error];
        expect(results).to.beTruthy();
        expect(error).to.beNil();
        expect([results count]).to.equal(1);
        
        NSManagedObject *data = results[0];
        expect([data valueForKey:@"title"]).to.equal(@"title");
        expect([data valueForKey:@"section"]).to.equal(@"section");
        expect([data valueForKey:@"number"]).to.equal(@1);
        expect([data valueForKey:@"updatedAt"]).to.beNil();
        
        NSEntityDescription *description = [data entity];
        expect([description.properties count]).to.equal(4);
        expect(description.properties[0].name).to.equal(@"number");
        expect(description.properties[1].name).to.equal(@"section");
        expect(description.properties[2].name).to.equal(@"title");
        expect(description.properties[3].name).to.equal(@"updatedAt");
        
        sqlite3 *db;
        int rc = sqlite3_open([sqlite3Path fileSystemRepresentation], &db);
        expect(rc == 0).to.beTruthy();
        if (rc == 0) {
            NSArray *info = tableInfo(db, @"ZEXAMPLEDATA");
            expect(info).notTo.beNil();
            expect([info count]).to.equal(7);
            expect(info[0][@"name"]).to.equal(@"Z_PK");
            expect(info[1][@"name"]).to.equal(@"Z_ENT");
            expect(info[2][@"name"]).to.equal(@"Z_OPT");
            expect(info[3][@"name"]).to.equal(@"ZNUMBER");
            expect(info[4][@"name"]).to.equal(@"ZUPDATEDAT");
            expect(info[5][@"name"]).to.equal(@"ZSECTION");
            expect(info[6][@"name"]).to.equal(@"ZTITLE");
            sqlite3_close(db);
        }
    });

});

SpecEnd
