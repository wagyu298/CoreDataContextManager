// This software is released under the MIT License.
// http://opensource.org/licenses/mit-license.php

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

/*!
 @protocol CDMFetchedResultsControllerDelegateDataSource
 @discussion Delegate for CDMFetchedResultsControllerDelegate.
 tableView.dataSource should implement this protocol.
 */
@protocol CDMFetchedResultsControllerDelegateDataSource <UITableViewDataSource>


/*!
 @brief configure UITableViewCell
 @param cell A cell for configuring
 @param indexPath indexPath of cell
 */
@required
- (void)configureCell:(UITableViewCell * _Nonnull)cell atIndexPath:(NSIndexPath * _Nullable)indexPath;

@end

/*!
 @class CDMFetchedResultsControllerDelegate
 @brief Example implementation of NSFetchedResultsControllerDelegate
 */
@interface CDMFetchedResultsControllerDelegate : NSObject <NSFetchedResultsControllerDelegate>

/*!
 @brief Change default animation for row update
 @param rowAnimation row update animation
 */
+ (void)setDefaultRowAnimation:(UITableViewRowAnimation)rowAnimation;

/// @brief UITableView for managing by NSFetchedResultsController
@property (nullable, nonatomic, weak) IBOutlet UITableView *tableView;

/// @brief row update animation
@property (nonatomic) UITableViewRowAnimation rowAnimation;

/*!
 @brief Initialize CDMFetchedResultsControllerDelegate with table view and row animation
 @param tableView table view for managing by NSFetchedResultsController
 @param rowAnimation row update animation
 */
- (instancetype _Nonnull)initWithTableView:(UITableView * _Nonnull)tableView rowAnimation:(UITableViewRowAnimation)rowAnimation;

/*!
 @brief Initialize CDMFetchedResultsControllerDelegate with table view and row animation
 @param tableView table view for managing by NSFetchedResultsController
 */
- (instancetype _Nonnull)initWithTableView:(UITableView * _Nonnull)tableView;

@end
