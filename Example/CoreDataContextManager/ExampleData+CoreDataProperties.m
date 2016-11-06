// This software is released under the MIT License.
// http://opensource.org/licenses/mit-license.php

#import "ExampleData+CoreDataProperties.h"

@implementation ExampleData (CoreDataProperties)

+ (NSFetchRequest<ExampleData *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"ExampleData"];
}

@dynamic section;
@dynamic title;
@dynamic updatedAt;
@dynamic number;

@end
