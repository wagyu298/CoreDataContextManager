// This software is released under the MIT License.
// http://opensource.org/licenses/mit-license.php

#import <CoreDataContextManager/CoreDataContextManager.h>
#import "ExampleData+CoreDataClass.h"

SpecBegin(NSManagedObjectContext)

describe(@"cdm_createBackgroundContext", ^{
    
    __block CDMCoreDataContextManager *manager;
    
    beforeEach(^{
        manager = [[CDMCoreDataContextManager alloc] initWithInMemoryDatabaseName:@"CoreDataContextManagerExample"];
    });
    
    it(@"create data from child thread", ^{
        waitUntil(^(DoneCallback done) {
            NSManagedObjectContext *context = [manager.managedObjectContext cdm_createBackgroundContext];
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

describe(@"cdm_saveChanges", ^{
    
    __block CDMCoreDataContextManager *manager;
    
    beforeEach(^{
        manager = [[CDMCoreDataContextManager alloc] initWithInMemoryDatabaseName:@"CoreDataContextManagerExample"];
    });

    it(@"nothing to do w/o changes", ^{
        NSManagedObjectContext *context = manager.managedObjectContext;
        expect(context.hasChanges).to.equal(NO);
        
        NSError *error = nil;
        BOOL rv = [context cdm_saveChanges:&error];
        expect(rv).to.equal(YES);
        expect(error).to.beNil();
        
        expect(context.hasChanges).to.equal(NO);
    });
    
    it(@"save changes", ^{
        NSManagedObjectContext *context = manager.managedObjectContext;
        expect(context.hasChanges).to.equal(NO);
        
        ExampleData *data = [NSEntityDescription insertNewObjectForEntityForName:@"ExampleData" inManagedObjectContext:context];
        data.title = @"title";
        data.section = @"section";
        data.number = 1;
        data.updatedAt = [NSDate date];
        
        expect(context.hasChanges).to.equal(YES);
        
        NSError *error = nil;
        BOOL rv = [context cdm_saveChanges:&error];
        expect(rv).to.equal(YES);
        expect(error).to.beNil();
        
        expect(context.hasChanges).to.equal(NO);
    });
    
});

describe(@"cdm_deleteWithEntityName", ^{
    
    __block CDMCoreDataContextManager *manager;
    
    beforeEach(^{
        manager = [[CDMCoreDataContextManager alloc] initWithInMemoryDatabaseName:@"CoreDataContextManagerExample"];
    });
    
    it(@"nothing to do with empty objects", ^{
        NSManagedObjectContext *context = manager.managedObjectContext;
        
        NSFetchRequest* request = [ExampleData fetchRequest];
        request.includesSubentities = NO;
        NSUInteger count = [context countForFetchRequest:request error:nil];
        expect(count).to.equal(0);
        
        NSError *error = nil;
        BOOL rv = [context cdm_deleteWithEntityName:@"ExampleData" error:&error];
        expect(rv).to.equal(YES);
        expect(error).to.beNil();
        
        count = [context countForFetchRequest:request error:nil];
        expect(count).to.equal(0);
    });
     
    it(@"delete objects", ^{
        NSManagedObjectContext *context = manager.managedObjectContext;
        
        for (int i = 0; i < 10; ++i) {
            ExampleData *data = [NSEntityDescription insertNewObjectForEntityForName:@"ExampleData" inManagedObjectContext:context];
            data.title = @"title";
            data.section = @"section";
            data.number = i;
            data.updatedAt = [NSDate date];
        }
        expect([context cdm_saveChanges:nil]).to.equal(YES);
        
        NSFetchRequest* request = [ExampleData fetchRequest];
        request.includesSubentities = NO;
        NSUInteger count = [context countForFetchRequest:request error:nil];
        expect(count).to.equal(10);
        
        NSError *error = nil;
        BOOL rv = [context cdm_deleteWithEntityName:@"ExampleData" error:&error];
        expect(rv).to.equal(YES);
        expect(error).to.beNil();
        
        count = [context countForFetchRequest:request error:nil];
        expect(count).to.equal(0);
    });
    
});

SpecEnd
