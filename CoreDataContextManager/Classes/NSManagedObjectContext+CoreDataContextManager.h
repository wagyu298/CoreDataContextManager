// This software is released under the MIT License.
// http://opensource.org/licenses/mit-license.php

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (CoreDataContextManager)

- (NSManagedObjectContext * _Nonnull)cdm_createChildManagedObjectContext;
- (BOOL)cdm_saveChanges:(NSError * _Nullable * _Nullable)error;

@end
