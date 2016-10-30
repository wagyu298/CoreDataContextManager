// This software is released under the MIT License.
// http://opensource.org/licenses/mit-license.php

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <CoreDataContextManager/CoreDataContextManager.h>

#import "ExampleData+CoreDataClass.h"

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
    
});

describe(@"Light weight migration", ^{
    beforeAll(^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSArray *files = @[
                               @"CoreDataContextManagerExample.sqlite",
                               @"CoreDataContextManagerExample.sqlite-shm",
                               @"CoreDataContextManagerExample.sqlite-wal",
                               ];
        for (NSString *file in files) {
            NSString *filePath = [documentsPath stringByAppendingPathComponent:file];
            NSError *error = nil;
            BOOL rv = [fileManager removeItemAtPath:filePath error:&error];
            expect(rv).to.beTruthy();
            expect(error).to.beNil();
        }
    });
    
    it(@"Migrate", ^{
        waitUntil(^(DoneCallback done) {
            CDMCoreDataContextManagerConfiguration *config = [[CDMCoreDataContextManagerSQLLiteConfiguration alloc] initWithDatabaseName:@"CoreDataContextManagerExample"];
            [config setMappingModelURLWithDatabaseName:@"CoreDataContextManagerExample_v1"];
            
            CDMCoreDataContextManager *manager = [[CDMCoreDataContextManager alloc] initWithConfiguration:config];
            expect(manager).to.beTruthy();
            
            NSManagedObjectContext *context = manager.managedObjectContext;
            NSManagedObject *data = [NSEntityDescription insertNewObjectForEntityForName:@"ExampleData" inManagedObjectContext:context];
            [data setValue:@"title" forKey:@"title"];
            [data setValue:@"section" forKey:@"section"];
            [data setValue:@1 forKey:@"number"];
            
            NSError *error = nil;
            BOOL rv = [context save:&error];
            expect(rv).to.beTruthy();
            expect(error).to.beNil();
            
            done();
        });
        
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
        
        ExampleData *data = results[0];
        expect(data.title).to.equal(@"title");
        expect(data.updatedAt).to.beNil();
    });

});

SpecEnd
