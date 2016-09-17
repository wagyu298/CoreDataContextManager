// This is free and unencumbered software released into the public domain.
// For more information, please refer to <http://unlicense.org/>

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@protocol FetchedResultsControllerDelegateDataSource <UITableViewDataSource>

@required
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@interface FetchedResultsControllerDelegate : NSObject <NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) UITableViewRowAnimation rowAnimation;

- (id)initWithTableView:(UITableView *)tableView rowAnimation:(UITableViewRowAnimation)rowAnimation;
- (id)initWithTableView:(UITableView *)tableView;

@end
