//
//  DataManager.m
//  Reddit Rocket
//
//  Created by James Klapwyk on 2017-04-19.
//  Copyright © 2017 James Klapwyk. All rights reserved.
//

#import "DataManager.h"

@implementation DataManager

static DataManager *sharedInstance = nil;

// Get the shared instance and create it if necessary.
+ (DataManager *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}



- (id)init
{
    self = [super init];
    
    if (self) {
    }
    
    return self;
}

-(void) updateArticlesInDatabaseWithXML:(NSString *) xmlString
{
    
    [self removeAllArticleExceptPinned];
    
    
    
    NSError *error = nil;
    
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithXMLString:xmlString error:&error];
    
    NSArray *entryElements = [doc.rootElement elementsForName:@"entry"];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    
    for( GDataXMLElement *entryElement in entryElements ){
        
        NSString *title = [self getStringFromEntry:entryElement withName:@"title"];
        NSLog(@"TITLE = %@", title);
        
        Article *article = [[Article alloc] initWithContext:context];
        // If appropriate, configure the new managed object.
        article.timestamp = [NSDate date];
        article.title = title;
        
    }
    
    
    
    
}

-(NSArray *) getListOfArticles
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Article"];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (!results) {
        NSLog(@"Error fetching Article objects: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
    
    return results;
}

-(void) removeAllArticleExceptPinned
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectModel *model = appDelegate.persistentContainer.managedObjectModel;
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    
    
    NSArray *articles = [self getListOfArticles];
    
    for( Article *article in articles ){
        
        if( !article.is_pinned ){
            [context deleteObject:article];
        }
        
    }
    
    NSError *error = nil;
    
    [context save:&error];
    
    
}

-(NSString *) getStringFromEntry:(GDataXMLElement *) entryElement withName:(NSString *)name
{
    NSArray *namedElements = [entryElement elementsForName:name];
    if( [namedElements count] > 0 ){
        GDataXMLElement *nameElement = (GDataXMLElement *) [namedElements objectAtIndex:0];
        return nameElement.stringValue;
    } else {
        return nil;
    }
}






// Your dealloc method will never be called, as the singleton survives for the duration of your app.
// However, I like to include it so I know what memory I'm using (and incase, one day, I convert away from Singleton).

// We don't want to allocate a new instance, so return the current one.
+ (id)allocWithZone:(NSZone*)zone {
    return [self sharedInstance];
}

// Equally, we don't want to generate multiple copies of the singleton.
- (id)copyWithZone:(NSZone *)zone {
    return self;
}



@end
