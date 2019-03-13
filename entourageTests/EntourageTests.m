//
//  EntourageTests.m
//  EntourageTests
//
//  Created by Grégoire Clermont on 28/01/2019.
//  Copyright © 2019 OCTO Technology. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface EntourageTests : XCTestCase

@end

@implementation EntourageTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    XCTAssert(2 == 2, @"2 == 2");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
