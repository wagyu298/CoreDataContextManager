// This is free and unencumbered software released into the public domain.
// For more information, please refer to <http://unlicense.org/>

#import "CDMViewController.h"
#import "CDMAppDelegate.h"
#import "ExampleData+CoreDataClass.h"

@interface CDMViewController () <UITableViewDelegate, UITableViewDataSource, CDMFetchedResultsControllerDelegateDataSource>

@property (weak, nonatomic, nullable) IBOutlet UITableView *tableView;

@property (weak, nonatomic, nullable) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic, nonnull) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic, nonnull) CDMFetchedResultsControllerDelegate *fetchedResultsControllerDelegate;
@property (nonatomic) int32_t number;

@end

@implementation CDMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    CDMAppDelegate *appDelegate = [CDMAppDelegate appDelegate];
    self.managedObjectContext = appDelegate.coreDataContextManager.managedObjectContext;
    
    self.number = 0;
    for (int i = 0; i < 20; ++i) {
        [ExampleData createWithTitle:@"created" section:@"created" number:++self.number];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CoreData and Table View Delegate

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }
    
    if (!self.fetchedResultsControllerDelegate) {
        self.fetchedResultsControllerDelegate = [[CDMFetchedResultsControllerDelegate alloc] initWithTableView:self.tableView];
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"ExampleData" inManagedObjectContext:self.managedObjectContext]];
    request.sortDescriptors = @[
                                [[NSSortDescriptor alloc] initWithKey:@"section" ascending:NO],
                                [[NSSortDescriptor alloc] initWithKey:@"updatedAt" ascending:NO],
                                ];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"section" cacheName:nil];
    _fetchedResultsController.delegate = self.fetchedResultsControllerDelegate;
    
    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
        NSLog(@"%@", error);
    }
    
    return _fetchedResultsController;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return sectionInfo.name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"IDENTIFIER";
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ExampleData *data = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %d", data.title, data.number];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger sections = [self numberOfSectionsInTableView:tableView];
    if (indexPath.section >= 0 && indexPath.section < sections) {
        NSInteger rows = [self tableView:tableView numberOfRowsInSection:indexPath.section];
        if (indexPath.row >= 0 && indexPath.row < rows) {
            ExampleData *data = [self.fetchedResultsController objectAtIndexPath:indexPath];
            data.title = @"updated";
            data.section = @"updated";
            NSError *error = nil;
            if (![[CDMAppDelegate appDelegate].coreDataContextManager.managedObjectContext save:&error]) {
                NSLog(@"%@", error);
            }
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - IBAction

- (IBAction)addItem:(id)sender
{
    [ExampleData createWithTitle:@"added" section:@"created" number:++self.number];
}

@end
