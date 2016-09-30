// This is free and unencumbered software released into the public domain.
// For more information, please refer to <http://unlicense.org/>

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@protocol FetchedResultsControllerDelegateDataSource <UITableViewDataSource>

@required
- (void)configureCell:(UITableViewCell * _Nonnull)cell atIndexPath:(NSIndexPath * _Nonnull)indexPath;

@end

@interface FetchedResultsControllerDelegate : NSObject <NSFetchedResultsControllerDelegate>

@property (nullable, nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic) UITableViewRowAnimation rowAnimation;

- (id)initWithTableView:(UITableView * _Nonnull)tableView rowAnimation:(UITableViewRowAnimation)rowAnimation;
- (id)initWithTableView:(UITableView * _Nonnull)tableView;

@end
