//
//  CDMCoreDataContextManagerConfigrationTest.m
//  CoreDataContextManager
//
//  Created by wagyu298 on 2016/10/30.
//  Copyright © 2016年 wagyu298. All rights reserved.
//

#import <CoreDataContextManager/CoreDataContextManager.h>

SpecBegin(CDMCoreDataContextManagerConfigurationSpecs)

describe(@"CDMCoreDataContextManagerConfiguration", ^{
    NSString *databaseName = @"test";
    
    describe(@"constructor", ^{
        
        it(@"init", ^{
            CDMCoreDataContextManagerConfiguration *config = [[CDMCoreDataContextManagerConfiguration alloc] init];
            expect(config).toNot.beNil();
            expect(config.storeType).to.beNil();
            expect(config.autoSave).to.beTruthy();
            expect(config.mappingModelURL).to.beNil();
            expect(config.persistentStoreURL).to.beNil();
            expect(config.storeOptions).to.equal(@{});
        });
        
        it(@"initWithStoreType:", ^{
            CDMCoreDataContextManagerConfiguration *config = [[CDMCoreDataContextManagerConfiguration alloc] initWithStoreType:NSSQLiteStoreType];
            expect(config).toNot.beNil();
            expect(config.storeType).to.equal(NSSQLiteStoreType);
            expect(config.autoSave).to.beTruthy();
            expect(config.mappingModelURL).to.beNil();
            expect(config.persistentStoreURL).to.beNil();
            expect(config.storeOptions).to.equal(@{});
        });
        
        it(@"initWithStoreType:databaseName: (NSSQLiteStoreType)", ^{
            CDMCoreDataContextManagerConfiguration *config = [[CDMCoreDataContextManagerConfiguration alloc] initWithStoreType:NSSQLiteStoreType databaseName:databaseName];
            expect(config).toNot.beNil();
            expect(config.storeType).to.equal(NSSQLiteStoreType);
            expect(config.autoSave).to.beTruthy();
            expect(config.storeOptions).to.equal(@{});
            
            NSURL *modelUrl = [[NSBundle mainBundle] URLForResource:databaseName withExtension:@"momd"];
            expect(config.mappingModelURL).to.equal(modelUrl)
            ;
            
            NSURL *directoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
            NSString *fileName = [NSString stringWithFormat:@"%@.sqlite", databaseName];
            NSURL *storeURL = [directoryURL URLByAppendingPathComponent:fileName];
            expect(config.persistentStoreURL).to.equal(storeURL);
        });
        
        it(@"initWithStoreType:databaseName: (NSBinaryStoreType)", ^{
            CDMCoreDataContextManagerConfiguration *config = [[CDMCoreDataContextManagerConfiguration alloc] initWithStoreType:NSBinaryStoreType databaseName:databaseName];
            expect(config).toNot.beNil();
            expect(config.storeType).to.equal(NSBinaryStoreType);
            expect(config.autoSave).to.beTruthy();
            
            NSURL *modelUrl = [[NSBundle mainBundle] URLForResource:databaseName withExtension:@"momd"];
            expect(config.mappingModelURL).to.equal(modelUrl)
            ;
            
            NSURL *directoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
            NSString *fileName = [NSString stringWithFormat:@"%@.binary", databaseName];
            NSURL *storeURL = [directoryURL URLByAppendingPathComponent:fileName];
            expect(config.persistentStoreURL).to.equal(storeURL);
        });
        
        it(@"initWithStoreType:databaseName: (NSInMemoryStoreType)", ^{
            CDMCoreDataContextManagerConfiguration *config = [[CDMCoreDataContextManagerConfiguration alloc] initWithStoreType:NSInMemoryStoreType databaseName:databaseName];
            expect(config).toNot.beNil();
            expect(config.storeType).to.equal(NSInMemoryStoreType);
            expect(config.autoSave).to.beTruthy();
            
            NSURL *modelUrl = [[NSBundle mainBundle] URLForResource:databaseName withExtension:@"momd"];
            expect(config.mappingModelURL).to.equal(modelUrl)
            ;
            
            expect(config.persistentStoreURL).to.beNil();
        });
        
    });
    
    describe(@"mapping model URL", ^{
        
        it(@"setMappingModelURLWithBundle:databaseName:", ^{
            CDMCoreDataContextManagerConfiguration *config = [[CDMCoreDataContextManagerConfiguration alloc] init];
            [config setMappingModelURLWithBundle:[NSBundle mainBundle] databaseName:databaseName];
            
            NSURL *modelUrl = [[NSBundle mainBundle] URLForResource:databaseName withExtension:@"momd"];
            expect(config.mappingModelURL).to.equal(modelUrl)
            ;
        });
        
        it(@"setMappingModelURLWithDatabaseName:", ^{
            CDMCoreDataContextManagerConfiguration *config = [[CDMCoreDataContextManagerConfiguration alloc] init];
            [config setMappingModelURLWithDatabaseName:databaseName];
            
            NSURL *modelUrl = [[NSBundle mainBundle] URLForResource:databaseName withExtension:@"momd"];
            expect(config.mappingModelURL).to.equal(modelUrl)
            ;
        });
        
    });
    
    describe(@"persistent model URL", ^{
        
        it(@"setPersistentStoreURLWithStoreType:directoryURL:databaseName: (NSSQLiteStoreType)", ^{
            CDMCoreDataContextManagerConfiguration *config = [[CDMCoreDataContextManagerConfiguration alloc] init];
            NSURL *directoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
            [config setPersistentStoreURLWithStoreType:NSSQLiteStoreType directoryURL:directoryURL databaseName:databaseName];
            
            NSString *fileName = [NSString stringWithFormat:@"%@.sqlite", databaseName];
            NSURL *storeURL = [directoryURL URLByAppendingPathComponent:fileName];
            expect(config.persistentStoreURL).to.equal(storeURL);
        });

        it(@"setPersistentStoreURLWithStoreType:directoryURL:databaseName: (NSBinaryStoreType)", ^{
            CDMCoreDataContextManagerConfiguration *config = [[CDMCoreDataContextManagerConfiguration alloc] init];
            NSURL *directoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
            [config setPersistentStoreURLWithStoreType:NSBinaryStoreType directoryURL:directoryURL databaseName:databaseName];
            
            NSString *fileName = [NSString stringWithFormat:@"%@.binary", databaseName];
            NSURL *storeURL = [directoryURL URLByAppendingPathComponent:fileName];
            expect(config.persistentStoreURL).to.equal(storeURL);
        });
        
        describe(@"setPersistentStoreURLWithStoreType:directoryURL:databaseName: (NSInMemoryStoreType)", ^{
            
            it(@"with directoryURL", ^{
                CDMCoreDataContextManagerConfiguration *config = [[CDMCoreDataContextManagerConfiguration alloc] init];
                NSURL *directoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
                [config setPersistentStoreURLWithStoreType:NSInMemoryStoreType directoryURL:directoryURL databaseName:databaseName];
                
                expect(config.persistentStoreURL).to.beNil();
            });
            
            it(@"with out directoryURL", ^{
                CDMCoreDataContextManagerConfiguration *config = [[CDMCoreDataContextManagerConfiguration alloc] init];
                [config setPersistentStoreURLWithStoreType:NSInMemoryStoreType directoryURL:nil databaseName:databaseName];
                
                expect(config.persistentStoreURL).to.beNil();
            });
        });
        
    });
    
});

describe(@"CDMCoreDataContextManagerSQLLiteConfiguration", ^{
    NSString *databaseName = @"test";
    
    it(@"constructor", ^{
        CDMCoreDataContextManagerConfiguration *config = [[CDMCoreDataContextManagerSQLLiteConfiguration alloc] initWithDatabaseName:databaseName];
        expect(config).toNot.beNil();
        expect(config.storeType).to.equal(NSSQLiteStoreType);
        expect(config.autoSave).to.beTruthy();
        
        NSURL *modelUrl = [[NSBundle mainBundle] URLForResource:databaseName withExtension:@"momd"];
        expect(config.mappingModelURL).to.equal(modelUrl)
        ;
        
        NSURL *directoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSString *fileName = [NSString stringWithFormat:@"%@.sqlite", databaseName];
        NSURL *storeURL = [directoryURL URLByAppendingPathComponent:fileName];
        expect(config.persistentStoreURL).to.equal(storeURL);
    });
    
});

describe(@"CDMCoreDataContextManagerBinaryConfiguration", ^{
    NSString *databaseName = @"test";
    
    it(@"constructor", ^{
        CDMCoreDataContextManagerConfiguration *config = [[CDMCoreDataContextManagerBinaryConfiguration alloc] initWithDatabaseName:databaseName];
        expect(config).toNot.beNil();
        expect(config.storeType).to.equal(NSBinaryStoreType);
        expect(config.autoSave).to.beTruthy();
        
        NSURL *modelUrl = [[NSBundle mainBundle] URLForResource:databaseName withExtension:@"momd"];
        expect(config.mappingModelURL).to.equal(modelUrl)
        ;
        
        NSURL *directoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSString *fileName = [NSString stringWithFormat:@"%@.binary", databaseName];
        NSURL *storeURL = [directoryURL URLByAppendingPathComponent:fileName];
        expect(config.persistentStoreURL).to.equal(storeURL);
    });
    
});

describe(@"CDMCoreDataContextManagerInMemoryConfiguration", ^{
    NSString *databaseName = @"test";
    
    it(@"constructor", ^{
        CDMCoreDataContextManagerConfiguration *config = [[CDMCoreDataContextManagerInMemoryConfiguration alloc] initWithDatabaseName:databaseName];
        expect(config).toNot.beNil();
        expect(config.storeType).to.equal(NSInMemoryStoreType);
        expect(config.autoSave).to.beTruthy();
        
        NSURL *modelUrl = [[NSBundle mainBundle] URLForResource:databaseName withExtension:@"momd"];
        expect(config.mappingModelURL).to.equal(modelUrl)
        ;
        
        expect(config.persistentStoreURL).to.beNil();
    });
    
});

SpecEnd
