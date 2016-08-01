// This is free and unencumbered software released into the public domain.
// For more information, please refer to <http://unlicense.org/>

/*
This file based upon Apple's NSFetchedResultsControllerDelegate example and
I changed to fix some crashing situation.
https://developer.apple.com/library/ios/documentation/CoreData/Reference/NSFetchedResultsControllerDelegate_Protocol/
*/

#import "FetchedResultsControllerDelegate.h"

@implementation FetchedResultsControllerDelegate

- (id)initWithTableView:(UITableView *)tableView
{
    self = [super init];
    if (self) {
        self.tableView = tableView;
    }
    return self;
}

/*
Assume self has a property 'tableView' -- as is the case for an instance of a UITableViewController
subclass -- and a method configureCell:atIndexPath: which updates the contents of a given cell
with information from a managed object at the given index path in the fetched results controller.
*/

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            break;
        case NSFetchedResultsChangeMove:
            break;
    }
}

- (BOOL)canUpdateWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    NSObject <UITableViewDataSource> *dataSource = tableView.dataSource;
    
    if (dataSource == nil || ![dataSource conformsToProtocol:@protocol(FetchedResultsControllerDelegateDataSource)]) {
        return NO;
        
    } else {
        NSInteger sections = 1;
        if ([dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
            sections = [dataSource numberOfSectionsInTableView:tableView];
        }
        if (indexPath.section >= sections) {
            return NO;
        }
        NSInteger rows = 0;
        if ([dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
            rows = [dataSource tableView:tableView numberOfRowsInSection:indexPath.section];
        }
        return (indexPath.row < rows);
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            if ([self canUpdateWithTableView:tableView indexPath:indexPath]) {
                NSObject <FetchedResultsControllerDelegateDataSource> *dataSource = (NSObject <FetchedResultsControllerDelegateDataSource> *)tableView.dataSource;
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                if (cell != nil) {
                    [dataSource configureCell:cell atIndexPath:indexPath];
                }
            }
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

@end
