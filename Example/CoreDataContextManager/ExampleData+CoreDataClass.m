// This software is released under the MIT License.
// http://opensource.org/licenses/mit-license.php

#import "ExampleData+CoreDataClass.h"
#import "CDMAppDelegate.h"

@implementation ExampleData

+ (ExampleData *)createWithTitle:(NSString *)title section:(NSString *)section number:(int32_t)number
{
    NSManagedObjectContext *context = [CDMAppDelegate appDelegate].coreDataContextManager.managedObjectContext;
    ExampleData *data = [NSEntityDescription insertNewObjectForEntityForName:@"ExampleData" inManagedObjectContext:context];
    data.title = title;
    data.section = section;
    data.number = number;
    data.updatedAt = [NSDate date];
    
    NSError *error = nil;
    if ([context save:&error]) {
        NSLog(@"%@", error);
    }
    return data;
}

@end
