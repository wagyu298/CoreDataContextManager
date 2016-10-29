// This is free and unencumbered software released into the public domain.
// For more information, please refer to <http://unlicense.org/>

#import "ExampleData+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface ExampleData (CoreDataProperties)

+ (NSFetchRequest<ExampleData *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *section;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSDate *updatedAt;
@property (nonatomic) int32_t number;

@end

NS_ASSUME_NONNULL_END
