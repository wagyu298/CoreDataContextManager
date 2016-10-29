// This software is released under the MIT License.
// http://opensource.org/licenses/mit-license.php

@import Specta;
@import Expecta;
@import CoreDataContextManager;

#import "ExampleData+CoreDataClass.h"

SpecBegin(CoreDataContextManagerSpecs)

describe(@"CoreDataContextManager", ^{
    __block CDMCoreDataContextManager *manager;
    
    beforeEach(^{
        manager = [[CDMCoreDataContextManager alloc] initWithDatabaseName:@"CoreDataContextManagerExample" directory:nil storeType:NSInMemoryStoreType options:CDMCoreDataContextManagerOptionsAutoSave];
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

SpecEnd
