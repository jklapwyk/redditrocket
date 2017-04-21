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
    NSLog(@"FILTER BY PINNED");
    
    self.is_filtered_by_pin = !self.is_filtered_by_pin;
    
    if( self.is_filtered_by_pin ){
        self.filterByPinnedButton.title = @"Show All";
    } else {
        self.filterByPinnedButton.title = @"Show Pinned";
    }
    
    
    //self.fetchedResultsController
    [NSFetchedResultsController deleteCacheWithName:nil];
    
    self.fetchNewResults = YES;
    
    [self.tableView reloadData];
    
    //NSError *error = nil;
    //[self.tableView beginUpdates];
    //[self.fetchedResultsController performFetch:&error];
    //[self.tableView reloadData];
    //[self getRedditData];
    
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
    //NSLog(@"REDDIT DATA HAS BEEN COMPLETED = %@", xmlString );
    
    [[DataManager sharedInstance] updateArticlesInDatabaseWithXML:xmlString];
    
    [self.refreshControl endRefreshing];
}

- (IBAction) pinTapped: (UIButton *) sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath)
    {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        
        Article *article = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        article.is_pinned = !article.is_pinned;
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, error.userInfo);
            abort();
        }
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
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


- (void)insertNewObject:(id)sender {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    Article *newEvent = [[Article alloc] initWithContext:context];
        
    // If appropriate, configure the new managed object.
    newEvent.timestamp = [NSDate date];
        
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Article *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    Article *article = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self configureCell:cell withArticle:article];
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
            
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, error.userInfo);
            abort();
        }
    }
}


- (void)configureCell:(UITableViewCell *)cell withArticle:(Article *)article {
    //cell.textLabel.text = article.title;
    
    UILabel *titleLabel = [cell.contentView viewWithTag:1];
    UILabel *subtitleLabel = [cell.contentView viewWithTag:2];
    UILabel *dateLabel = [cell.contentView viewWithTag:3];
    
    UIImageView *imageView = [cell.contentView viewWithTag:4];
    
    UIButton *pinButton = [cell.contentView viewWithTag:5];
    
    titleLabel.text = article.title;
    subtitleLabel.text = article.category;
    
    NSDate *updatedDate = article.updated_date;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM d, yyyy, h:mm a"];
    NSString *updatedDateString = [dateFormat stringFromDate:updatedDate];
    
    
    dateLabel.text = updatedDateString;
    
    
    if( article.thumbnail_url != nil ){
        [imageView sd_setImageWithURL:[NSURL URLWithString:article.thumbnail_url] placeholderImage:[UIImage imageNamed:@"logo_180"]];
    } else {
        [imageView setImage:[UIImage imageNamed:@"logo_180"]];
    }
    
    if( article.is_pinned ){
        [pinButton.imageView setImage:[UIImage imageNamed:@"pin_on"]];
    } else {
        [pinButton.imageView setImage:[UIImage imageNamed:@"pin_off"]];
    }
    
    
    
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController<Article *> *)fetchedResultsController
{
    
    NSLog(@"FETCHED RESULTS = %@", (self.is_filtered_by_pin ? @"YES" : @"NO" ));
    
    if (_fetchedResultsController != nil && !self.fetchNewResults) {
        return _fetchedResultsController;
    }
    
    self.fetchNewResults = NO;
    
    NSFetchRequest<Article *> *fetchRequest = Article.fetchRequest;
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    
    
    if( self.is_filtered_by_pin ){
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"is_pinned==YES"];
    }
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updated_date" ascending:NO];

    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController<Article *> *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
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
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] withArticle:anObject];
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

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

@end
