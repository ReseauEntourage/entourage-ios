//
//  OTMenuViewControllerTests.m
//  entourage
//
//  Created by Cedric Pointel on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

// Controller
#import "OTMenuViewController.h"

@interface OTMenuTableViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *itemLabel;

@end

@interface OTMenuItem ()

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *segueIdentifier;

@end

@interface OTMenuViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *menuItems;

- (void)openControllerWithSegueIdentifier:(NSString *)segueIdentifier;
+ (NSArray *)createMenuItems;
- (OTMenuItem *)menuItemsAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface OTMenuViewControllerTests : XCTestCase

@property (nonatomic, strong) OTMenuViewController *viewController;
@property (nonatomic, strong) id mockViewController;

@end

@implementation OTMenuViewControllerTests

/**************************************************************************************************/
#pragma mark - Init

- (void)setUp
{
    [super setUp];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                        bundle:nil];
    
    self.viewController = [storyboard instantiateViewControllerWithIdentifier:@"OTMenuViewControllerIdentifier"];
    [self.viewController view];
    
    self.mockViewController = [OCMockObject partialMockForObject:self.viewController];
}

/**************************************************************************************************/
#pragma mark - - (void)viewDidLoad

- (void)test_viewDidLoad_allExpectedMethodsAreCalled
{
    // Given
    NSArray *items = @[];
    OCMExpect([self.mockViewController createMenuItems]).andReturn(items);
    
    // When
    [self.viewController viewDidLoad];
    
    // Then
    OCMVerify(self.mockViewController);
    XCTAssertEqual(self.viewController.menuItems, items, @"");
}

/**************************************************************************************************/
#pragma mark - - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

- (void)test_tableViewNumberOfRowsInSection_allExpectedMethodsAreCalled
{
    // Given
    id mockMenuItems = [OCMockObject niceMockForClass:NSArray.class];
    OCMExpect([mockMenuItems count]).andReturn(3);
    OCMStub([self.mockViewController menuItems]).andReturn(mockMenuItems);
    
    // When
    NSInteger result = [self.viewController tableView:OCMOCK_ANY numberOfRowsInSection:0];
    
    // Then
    [mockMenuItems verify];
    XCTAssertTrue(result == 3, @"");
}

/**************************************************************************************************/
#pragma mark - - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

- (void)test_tableViewCellForRowAtIndexPath_allExpectedMethodsAreCalled
{
    // Given
    NSString *menuItemTitle = @"ItemTitleString";
    
    id mockItemTitle = [OCMockObject niceMockForClass:NSString.class];
    OCMExpect([mockItemTitle uppercaseStringWithLocale:[NSLocale currentLocale]]).andReturn(menuItemTitle);
    
    id mockMenuItem = [OCMockObject niceMockForClass:OTMenuItem.class];
    OCMStub([mockMenuItem title]).andReturn(mockItemTitle);
    
    id mockItemLabel = [OCMockObject niceMockForClass:UILabel.class];
    OCMExpect([mockItemLabel setText:menuItemTitle]);
    
    id mockTableViewCell = [OCMockObject niceMockForClass:OTMenuTableViewCell.class];
    OCMStub([mockTableViewCell itemLabel]).andReturn(mockItemLabel);
    
    id mockIndexPath = [OCMockObject niceMockForClass:NSIndexPath.class];
    
    id mockTableView = [OCMockObject niceMockForClass:UITableView.class];
    OCMExpect([mockTableView dequeueReusableCellWithIdentifier:@"OTMenuTableViewCellIdentifier"]).andReturn(mockTableViewCell);
    
    OCMExpect([self.mockViewController menuItemsAtIndexPath:mockIndexPath]).andReturn(mockMenuItem);
    
    // When
    [self.viewController tableView:mockTableView cellForRowAtIndexPath:mockIndexPath];
    
    // Then
    [mockItemTitle verify];
    [mockTableView verify];
    [mockItemLabel verify];
    [self.mockViewController verify];
}

/**************************************************************************************************/
#pragma mark - - (void)openControllerWithSegueIdentifier:(NSString *)segueIdentifier

- (void)test_openControllerWithSegueIdentifier_allExpectedMethodsAreCalled
{
    // Given
    NSString *segueIdentifier = @"segueId";
    OCMExpect([self.mockViewController performSegueWithIdentifier:segueIdentifier sender:self.viewController]);
    
    // When
    [self.viewController openControllerWithSegueIdentifier:segueIdentifier];
    
    // Then
    [self.mockViewController verify];
}

/**************************************************************************************************/
#pragma mark - - (OTMenuItem *)menuItemsAtIndexPath:(NSIndexPath *)indexPath

- (void)test_menuItemsAtIndexPath_shouldReturnNilWhenNoIndexPath
{
    // Given
    id mockIndexPath = nil;
    
    // When
    OTMenuItem *result = [self.viewController menuItemsAtIndexPath:mockIndexPath];
    
    // Then
    XCTAssertNil(result);
}

- (void)test_menuItemsAtIndexPath_shouldReturnNilWhenIndexPathOutOfIndex
{
    // Given
    id mockIndexPath = [OCMockObject niceMockForClass:NSIndexPath.class];
    OCMExpect([mockIndexPath row]).andReturn(3);
    
    id mockMenuItems = [OCMockObject niceMockForClass:NSArray.class];
    OCMExpect([mockMenuItems count]).andReturn(2);
    OCMStub([self.mockViewController menuItems]).andReturn(mockMenuItems);
    
    // When
    OTMenuItem *result = [self.viewController menuItemsAtIndexPath:mockIndexPath];
    
    // Then
    XCTAssertNil(result);
}

- (void)test_menuItemsAtIndexPath_shouldReturnFirstMenuItemWhenExists
{
    // Given
    id mockIndexPath = [OCMockObject niceMockForClass:NSIndexPath.class];
    OCMExpect([mockIndexPath row]).andReturn(0);
    
    id mockMenuItem = [OCMockObject niceMockForClass:OTMenuItem.class];
    
    id mockMenuItems = [OCMockObject niceMockForClass:NSArray.class];
    OCMExpect([mockMenuItems count]).andReturn(3);
    OCMStub([mockMenuItems objectAtIndex:0]).andReturn(mockMenuItem);
    
    OCMStub([self.mockViewController menuItems]).andReturn(mockMenuItems);
    
    // When
    OTMenuItem *result = [self.viewController menuItemsAtIndexPath:mockIndexPath];
    
    // Then
    XCTAssertEqualObjects(result, mockMenuItem, @"");
}

- (void)test_menuItemsAtIndexPath_shouldReturnLastMenuItemWhenExists
{
    /*// Given
    id mockIndexPath = [OCMockObject niceMockForClass:NSIndexPath.class];
    OCMExpect([mockIndexPath row]).andReturn(2);
    
    OTMenuItem *menuItem = [OTMenuItem new];
    
    id mockMenuItems = [OCMockObject niceMockForClass:NSArray.class];
    OCMExpect([mockMenuItems count]).andReturn(3);
    OCMStub([mockMenuItems objectAtIndex:2]).andReturn(menuItem);
    
    OCMStub([self.mockViewController menuItems]).andReturn(mockMenuItems);
    
    // When
    OTMenuItem *result = [self.viewController menuItemsAtIndexPath:mockIndexPath];
    
    // Then
    XCTAssertEqualObjects(result, menuItem, @"");*/
}

@end
