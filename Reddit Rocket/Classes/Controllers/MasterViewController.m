//
//  MasterViewController.m
//  Reddit Rocket
//
//  Created by James Klapwyk on 2017-04-19.
//  Copyright © 2017 James Klapwyk. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface MasterViewController ()

@end

@implementation MasterViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    self.is_filtered_by_pin = NO;
    
    self.fetchNewResults = YES;

    self.filterByPinnedButton = [[UIBarButtonItem alloc] initWithTitle:@"Show Pinned" style:UIBarButtonItemStylePlain target:self action:@selector(filterByPinned)];
                                  
    self.navigationItem.rightBarButtonItem = self.filterByPinnedButton;
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    
    [self getRedditData];
    
}

-(void) filterByPinned
{
    
    self.is_filtered_by_pin = !self.is_filtered_by_pin;
    
    if( self.is_filtered_by_pin ){
        self.filterByPinnedButton.title = @"Show All";
    } else {
        self.filterByPinnedButton.title = @"Show Pinned";
    }
    
    self.fetchNewResults = YES;
    [self.tableView reloadData];
}

-(void) refreshTable
{
    [self getRedditData];
}

-(void) getRedditData
{
    [NetworkManager getRedditDataWithCompletionHandler:^(NSDictionary *response, NSError *error) {
        if( error == nil ){
            [self doneGettingRedditData:[response objectForKey:@"data"]];
        }
    }];
}


-(void) doneGettingRedditData:(NSString *)xmlString
{
    [[DataManager sharedInstance] updateArticlesInDatabaseWithXML:xmlString];
    
    [self.refreshControl endRefreshing];
}

- (IBAction) pinTapped: (UIButton *) sender
{
    //On Pin Tap
    //Get index path from touch position
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    if (indexPath)
    {
        //If index path exists update Article is_pinned value and save it.
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        Article *article = [self.fetchedResultsController objectAtIndexPath:indexPath];
        article.is_pinned = !article.is_pinned;
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, error.userInfo);
            abort();
        }
        
        //Reload Table cells based on pin state.
        if( self.is_filtered_by_pin ){
            [self.tableView reloadData];
        } else {
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        
    }
    
}


- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    //On Table Cell tap send the Article object to the Detail Controller
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Article *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setArticleItem:object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //configure table cell based on index path
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    Article *article = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self configureCell:cell withArticle:article];
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}




- (void)configureCell:(UITableViewCell *)cell withArticle:(Article *)article {
    
    //Configure cell based on Article object
    
    UILabel *titleLabel = [cell.contentView viewWithTag:1];
    UILabel *subtitleLabel = [cell.contentView viewWithTag:2];
    UILabel *dateLabel = [cell.contentView viewWithTag:3];
    
    UIImageView *imageView = [cell.contentView viewWithTag:4];
    
    
    
    titleLabel.text = article.title;
    subtitleLabel.text = article.category;
    
    NSDate *updatedDate = article.updated_date;
    
    //Format Updated date and assign value to the Date Label
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM d, yyyy, h:mm a"];
    NSString *updatedDateString = [dateFormat stringFromDate:updatedDate];
    dateLabel.text = updatedDateString;
    
    
    //Check to see if the thumbnail image exists and set the Image View accordingly otherwise use the default image
    if( article.thumbnail_url != nil ){
        [imageView sd_setImageWithURL:[NSURL URLWithString:article.thumbnail_url] placeholderImage:[UIImage imageNamed:@"logo_180"]];
    } else {
        [imageView setImage:[UIImage imageNamed:@"logo_180"]];
    }
    
    //Modify the look of the pin on the Table Cell based on the is_pinned value
    
    [self renderPinAtCell:cell IsPinned:article.is_pinned];
    
    
}

-(void) renderPinAtCell:(UITableViewCell *)cell IsPinned:(BOOL)is_pinned
{
    UIButton *pinButton = [cell.contentView viewWithTag:5];
    if( is_pinned ){
        [pinButton.imageView setImage:[UIImage imageNamed:@"pin_on"]];
    } else {
        [pinButton.imageView setImage:[UIImage imageNamed:@"pin_off"]];
    }
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController<Article *> *)fetchedResultsController
{
    //Use the fetched Results Controller to grab the saved Articles
    
    if (_fetchedResultsController != nil && !self.fetchNewResults) {
        return _fetchedResultsController;
    }
    
    self.fetchNewResults = NO;
    
    NSFetchRequest<Article *> *fetchRequest = Article.fetchRequest;
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    
    //Filter list of Articles based on the is_filtered_by_pin variable if true
    if( self.is_filtered_by_pin ){
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"is_pinned==YES"];
    }
    
    //Sort the list by updated_date descending
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updated_date" ascending:NO];

    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController<Article *> *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
    
    _fetchedResultsController = aFetchedResultsController;
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    //If data has been changed adjust the UITableCells accordingly
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            if( [tableView cellForRowAtIndexPath:indexPath] != nil){
                [self configureCell:[tableView cellForRowAtIndexPath:indexPath] withArticle:anObject];
            }
            
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}



@end
