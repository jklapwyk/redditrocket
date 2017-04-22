//
//  Reddit_RocketTests.m
//  Reddit RocketTests
//
//  Created by James Klapwyk on 2017-04-19.
//  Copyright © 2017 James Klapwyk. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NetworkManager.h"

@interface Reddit_RocketTests : XCTestCase

@end

@implementation Reddit_RocketTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testNetworkConnection {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    [NetworkManager getRedditDataWithCompletionHandler:^(NSDictionary *response, NSError *error) {
        
        XCTAssertNil(error);
        
    }];
    
}





@end
