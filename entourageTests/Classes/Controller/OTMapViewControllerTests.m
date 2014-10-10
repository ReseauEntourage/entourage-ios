//
//  OTMapViewControllerTests.m
//  entourage
//
//  Created by Cedric Pointel on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "UIViewController+menu.h"
#import "OTMapViewController.h"

@interface OTMapViewControllerTests : XCTestCase

/**************************************************************************************************/
#pragma mark - Getters and Setters

@property (nonatomic, strong) OTMapViewController *viewController;
@property (nonatomic, strong) id mockViewController;

@end

@implementation OTMapViewControllerTests

/**************************************************************************************************/
#pragma mark - Utils

- (void)setUp
{
    [super setUp];
    
    self.viewController = [[OTMapViewController alloc] init];
    self.mockViewController = [OCMockObject partialMockForObject:self.viewController];
}

/**************************************************************************************************/
#pragma mark - - (void)viewDidLoad

- (void)test_viewDidLoad_allExpectedMethodsAreCalled
{
    // Given
    OCMExpect([self.mockViewController createMenuButton]);
    
    // When
    [self.viewController viewDidLoad];
    
    // Then
    OCMVerify(self.mockViewController);
}

@end
