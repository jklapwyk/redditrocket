//
//  MasterViewController.h
//  Reddit Rocket
//
//  Created by James Klapwyk on 2017-04-19.
//  Copyright © 2017 James Klapwyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Reddit_Rocket+CoreDataModel.h"
#import "NetworkManager.h"
#import "DataManager.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController<Article *> *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (assign) BOOL is_filtered_by_pin;
@property (assign) BOOL fetchNewResults;

@property (strong, nonatomic) UIBarButtonItem *filterByPinnedButton;

-(void) getRedditData;
-(void) doneGettingRedditData:(NSString *)xmlString;


@end

