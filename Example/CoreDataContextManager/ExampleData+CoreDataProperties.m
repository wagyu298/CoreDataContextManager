// This is free and unencumbered software released into the public domain.
// For more information, please refer to <http://unlicense.org/>

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
