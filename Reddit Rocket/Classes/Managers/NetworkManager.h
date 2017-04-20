//
//  NetworkManager.h
//  Reddit Rocket
//
//  Created by James Klapwyk on 2017-04-19.
//  Copyright © 2017 James Klapwyk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkManager : NSObject <NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionDownloadDelegate, NSURLSessionTaskDelegate>

@property (nonatomic) NSURLSession *urlSession;
@property (nonatomic) NSMutableDictionary *tasks;
@property (strong) NSMutableData *data;
@property (strong) void (^latestCompletionHandler)(NSDictionary *response, NSError *error);

+(id)sharedInstance;

+(void) getRedditDataWithCompletionHandler:(void (^)(NSDictionary *response, NSError *error))completionHandler;


@end
