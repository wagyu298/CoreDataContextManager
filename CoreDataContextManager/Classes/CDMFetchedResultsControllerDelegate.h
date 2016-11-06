// This software is released under the MIT License.
// http://opensource.org/licenses/mit-license.php

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@protocol CDMFetchedResultsControllerDelegateDataSource <UITableViewDataSource>

@required
- (void)configureCell:(UITableViewCell * _Nonnull)cell atIndexPath:(NSIndexPath * _Nullable)indexPath;

@end

@interface CDMFetchedResultsControllerDelegate : NSObject <NSFetchedResultsControllerDelegate>

+ (void)setDefaultRowAnimation:(UITableViewRowAnimation)rowAnimation;

@property (nullable, nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic) UITableViewRowAnimation rowAnimation;

- (instancetype _Nonnull)initWithTableView:(UITableView * _Nonnull)tableView rowAnimation:(UITableViewRowAnimation)rowAnimation;
- (instancetype _Nonnull)initWithTableView:(UITableView * _Nonnull)tableView;

@end
