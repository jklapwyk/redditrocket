//
//  NetworkManager.m
//  Reddit Rocket
//
//  Created by James Klapwyk on 2017-04-19.
//  Copyright © 2017 James Klapwyk. All rights reserved.
//

#import "NetworkManager.h"

@implementation NetworkManager

static NetworkManager *sharedInstance = nil;

// Get the shared instance and create it if necessary.
+ (NetworkManager *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

// We can still have a regular init method, that will get called the first time the Singleton is used.
- (id)init
{
    self = [super init];
    
    if (self) {
        self.urlSession = nil;
        [self startURLSession];
    }
    
    return self;
}

-(void) startURLSession
{
    //Start URL session
    [self startURLSessionWithIdentifier:@"com.jklapwyk.redditrocket"];
}

-(void) startURLSessionWithIdentifier:(NSString *)identifier
{
    if( self.urlSession == nil){
        
        NSURLSessionConfiguration *sessionConfiguration;
        
        sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        self.urlSession = [NSURLSession sessionWithConfiguration:sessionConfiguration  delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
    }
    
}


+(void) getRedditDataWithCompletionHandler:(void (^)(NSDictionary *response, NSError *error))completionHandler
{
    [[NetworkManager sharedInstance] callUrl:@"https://www.reddit.com/hot/.rss" withCompletionHandler:completionHandler];
}

-(void) callUrl:(NSString *)url withCompletionHandler:(void (^)(NSDictionary *response, NSError *error))completionHandler
{
    self.latestCompletionHandler = completionHandler;
    
    self.data = nil;
    
    //Call url using NSURLSession
    
    NSURL* callUrl = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:callUrl];
    
    NSURLSessionTask *dataTask = [self.urlSession dataTaskWithRequest:request];
    [dataTask resume];
    
}



/*
 * Messages related to the URL session as a whole
 */
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    NSLog(@"DID BECOME INVALID WITH ERROR");
    self.urlSession = nil;
    
}

/* Sent as the last message related to a specific task.  Error may be
 * nil, which implies that no error occurred and this task is complete.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if( error == nil){
        
        //Once the Url session has been completed call the completion handler provided
        NSString *dataToString = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
        NSDictionary *data = [[NSMutableDictionary alloc] init];
        
        [data setValue:dataToString forKey:@"data"];

        [self callCompletionHandler:self.latestCompletionHandler withResponse:data withError:nil];
        
        
    }
    
    
    if( error != nil){
        
        if( error.code == NSURLErrorNotConnectedToInternet || error.code == NSURLErrorNetworkConnectionLost ){
            
            //ignore not being connected to the internet.
            
        }
    }
    
    
    
    
}


-(void) callCompletionHandler:(void (^)(NSDictionary *response, NSError *error))completionHandler withResponse:(NSDictionary *)response withError:(NSError *)error
{
    if( completionHandler != nil ){
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler( response, error );
        });
    }
    
}





/* If implemented, when a connection level authentication challenge
 * has occurred, this delegate will be given the opportunity to
 * provide authentication credentials to the underlying
 * connection. Some types of authentication will apply to more than
 * one request on a given connection to a server (SSL Server Trust
 * challenges).  If this delegate message is not implemented, the
 * behavior will be to use the default handling, which may involve user
 * interaction.
 */
/*
 - (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
 {
 NSLog(@"didReceiveChallenge = %@", challenge);
 
 completionHandler( NSURLSessionAuthChallengePerformDefaultHandling, nil);
 }
 */

/* If an application has received an
 * -application:handleEventsForBackgroundURLSession:completionHandler:
 * message, the session delegate will receive this message to indicate
 * that all messages previously enqueued for this session have been
 * delivered.  At this time it is safe to invoke the previously stored
 * completion handler, or to begin any internal updates that will
 * result in invoking the completion handler.
 */
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    
}



/* The task has received a response and no further messages will be
 * received until the completion block is called. The disposition
 * allows you to cancel a request or to turn a data task into a
 * download task. This delegate message is optional - if you do not
 * implement it, you can get the response as a property of the task.
 *
 * This method will not be called for background upload tasks (which cannot be converted to download tasks).
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    completionHandler( NSURLSessionResponseAllow );
}

/* Notification that a data task has become a download task.  No
 * future messages will be sent to the data task.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask
{
    
}

/* Sent when data is available for the delegate to consume.  It is
 * assumed that the delegate will retain and not copy the data.  As
 * the data may be discontiguous, you should use
 * [NSData enumerateByteRangesUsingBlock:] to access it.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    if( self.data == nil ){
        self.data = [[NSMutableData alloc] init];
    }
    
    [self.data appendData:data];
}

/* Invoke the completion routine with a valid NSCachedURLResponse to
 * allow the resulting data to be cached, or pass nil to prevent
 * caching. Note that there is no guarantee that caching will be
 * attempted for a given resource, and you should not rely on this
 * message to receive the resource data.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler
{
    completionHandler(nil);
}




- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"didFinishDownloadingToURL");
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
