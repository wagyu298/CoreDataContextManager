// This software is released under the MIT License.
// http://opensource.org/licenses/mit-license.php

#import <CoreData/CoreData.h>

/**
 CoreData extensions
 */
@interface NSManagedObjectContext (CoreDataContextManager)

/*!
 @brief Create background thread context
 @return A NSManagedObjectContext object
 */
- (NSManagedObjectContext * _Nonnull)cdm_createBackgroundContext;

/*!
 @brief Save if NSManagedObjectContext has changed
 @param error A error pointer
 @return YES if success, otherwise NO
 */
- (BOOL)cdm_saveChanges:(NSError * _Nullable * _Nullable)error;

/*!
 @brief Delete all entity objects
 @param entityName Entity name to delete all objects
 @param error A error pointer
 @return YES if success, otherwise NO
 */
- (BOOL)cdm_deleteWithEntityName:(NSString * _Nonnull)entityName error:(NSError * _Nullable * _Nullable)error;

@end
