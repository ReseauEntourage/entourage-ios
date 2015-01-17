//
//  OTAppDelegateTests.m
//  entourage
//
//  Created by Cedric Pointel on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "OTAppDelegate.h"

@interface OTAppDelegate ()

- (void)configureUIAppearance;

@end

@interface OTAppDelegateTests : XCTestCase

@property (nonatomic, strong) id <UIApplicationDelegate> appDelegate;
@property (nonatomic, strong) id <UIApplicationDelegate> mockAppDelegate;

@end

@implementation OTAppDelegateTests

/**************************************************************************************************/
#pragma mark - Utils

- (void)setUp
{
    [super setUp];
    
    self.appDelegate = (OTAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.mockAppDelegate = [OCMockObject partialMockForObject:(id) self.appDelegate];
}

/**************************************************************************************************/
#pragma mark - - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions

- (void)test_applicationDidFinishLaunchingWithOptions_allExpectedMethodsAreCalled
{
    // Given
    OCMExpect([self.mockAppDelegate configureUIAppearance]);
    
    // When
    [self.appDelegate application:nil didFinishLaunchingWithOptions:nil];
    
    // Then
    OCMVerify(self.mockAppDelegate);
}

@end
