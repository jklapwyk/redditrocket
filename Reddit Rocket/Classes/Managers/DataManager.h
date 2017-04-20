//
//  DataManager.h
//  Reddit Rocket
//
//  Created by James Klapwyk on 2017-04-19.
//  Copyright © 2017 James Klapwyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"
#import "Reddit_Rocket+CoreDataModel.h"
#import "AppDelegate.h"

@interface DataManager : NSObject

+(id)sharedInstance;

-(void) updateArticlesInDatabaseWithXML:(NSString *) xmlString;
-(void) removeAllArticleExceptPinned;
-(NSArray *) getListOfArticles;

-(NSString *) getStringFromEntry:(GDataXMLElement *) entryElement withName:(NSString *)name;
-(NSString *) getStringFromEntryAttribute:(GDataXMLElement *) entryElement withName:(NSString *)name withAttribute:(NSString *)attribute;

@end
