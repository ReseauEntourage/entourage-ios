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
#import "SWRevealViewController.h"

// Model
#import "OTMenuItem.h"

// View
#import "OTMenuTableViewCell.h"

@interface OTMenuViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) NSMutableDictionary *controllersDictionary;

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

- (void)test_viewDidLoad_allExpectedMethodsAreCalledWhenFrontViewControllerExists
{
    // Given
    self.viewController.menuItems = nil;
    self.viewController.controllersDictionary = nil;
    
    UIViewController *frontViewController = [UIViewController new];
    
    id mockRevealViewController = [OCMockObject niceMockForClass:SWRevealViewController.class];
    OCMExpect([mockRevealViewController frontViewController]).andReturn(frontViewController);
    OCMStub([self.mockViewController revealViewController]).andReturn(mockRevealViewController);
    
    id mockDictionary = [OCMockObject niceMockForClass:NSMutableDictionary.class];
    OCMExpect([mockDictionary setObject:frontViewController forKey:OTMenuViewControllerSegueMenuMapIdentifier]);
    
    NSArray *items = @[];
    OCMExpect([self.mockViewController createMenuItems]).andReturn(items);
    
    // When
    [self.viewController viewDidLoad];
    
    // Then
    OCMVerify(self.mockViewController);
    OCMVerify(mockDictionary);
    OCMVerify(mockRevealViewController);
    XCTAssertEqual(self.viewController.menuItems, items, @"");
    XCTAssertNotNil(self.viewController.controllersDictionary, @"");
}

- (void)test_viewDidLoad_allExpectedMethodsAreCalledWhenFrontViewControllerDoesntExist
{
    // Given
    self.viewController.menuItems = nil;
    self.viewController.controllersDictionary = nil;
    
    UIViewController *frontViewController = nil;
    
    id mockRevealViewController = [OCMockObject niceMockForClass:SWRevealViewController.class];
    OCMExpect([mockRevealViewController frontViewController]).andReturn(frontViewController);
    OCMStub([self.mockViewController revealViewController]).andReturn(mockRevealViewController);
    
    id mockDictionary = [OCMockObject niceMockForClass:NSMutableDictionary.class];
    [[mockDictionary reject] setObject:frontViewController forKey:OTMenuViewControllerSegueMenuMapIdentifier];
    
    NSArray *items = @[];
    OCMExpect([self.mockViewController createMenuItems]).andReturn(items);
    
    // When
    [self.viewController viewDidLoad];
    
    // Then
    OCMVerify(self.mockViewController);
    OCMVerify(mockDictionary);
    OCMVerify(mockRevealViewController);
    XCTAssertEqual(self.viewController.menuItems, items, @"");
    XCTAssertNotNil(self.viewController.controllersDictionary, @"");
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

- (void)test_openControllerWithSegueIdentifier_allExpectedMethodsAreCalledWhenSegueIdentifierDoesntExist
{
    // Given
    NSString *segueIdentifier = @"segueId";

    UIViewController *nextViewController = nil;
    
    id mockControllersDictionary = [OCMockObject niceMockForClass:NSDictionary.class];
    OCMStub([mockControllersDictionary objectForKey:segueIdentifier]).andReturn(nextViewController);
    
    id mockRevealViewController = [OCMockObject niceMockForClass:SWRevealViewController.class];
    OCMStub([self.mockViewController revealViewController]).andReturn(mockRevealViewController);
    [[mockRevealViewController reject] pushFrontViewController:OCMOCK_ANY animated:YES];
    
    OCMExpect([self.mockViewController performSegueWithIdentifier:segueIdentifier sender:self.viewController]);
    
    // When
    [self.viewController openControllerWithSegueIdentifier:segueIdentifier];
    
    // Then
    [self.mockViewController verify];
}

- (void)test_openControllerWithSegueIdentifier_allExpectedMethodsAreCalledWhenSegueIdentifierExistAndNotCurrentFrontViewController
{
    // Given
    NSString *segueIdentifier = @"segueId";
    
    UIViewController *nextViewController = [UIViewController new];
    
    id mockControllersDictionary = [OCMockObject niceMockForClass:NSDictionary.class];
    OCMStub([mockControllersDictionary objectForKey:segueIdentifier]).andReturn(nextViewController);
    OCMStub([self.mockViewController controllersDictionary]).andReturn(mockControllersDictionary);
    
    id mockRevealViewController = [OCMockObject niceMockForClass:SWRevealViewController.class];
    OCMExpect([mockRevealViewController pushFrontViewController:nextViewController animated:YES]);
    OCMStub([self.mockViewController revealViewController]).andReturn(mockRevealViewController);
    
    [[self.mockViewController reject] performSegueWithIdentifier:segueIdentifier sender:self.viewController];
    
    // When
    [self.viewController openControllerWithSegueIdentifier:segueIdentifier];
    
    // Then
    [self.mockViewController verify];
}

- (void)test_openControllerWithSegueIdentifier_allExpectedMethodsAreCalledWhenSegueIdentifierExistAndCurrentFrontViewController
{
    // Given
    NSString *segueIdentifier = @"segueId";
    
    UIViewController *nextViewController = [UIViewController new];
    
    id mockControllersDictionary = [OCMockObject niceMockForClass:NSDictionary.class];
    OCMStub([mockControllersDictionary objectForKey:segueIdentifier]).andReturn(nextViewController);
    OCMStub([self.mockViewController controllersDictionary]).andReturn(mockControllersDictionary);
    
    id mockRevealViewController = [OCMockObject niceMockForClass:SWRevealViewController.class];
    OCMStub([mockRevealViewController frontViewController]).andReturn(nextViewController);
    OCMExpect([mockRevealViewController revealToggle:self.viewController]);
    OCMStub([self.mockViewController revealViewController]).andReturn(mockRevealViewController);
    
    [[self.mockViewController reject] performSegueWithIdentifier:segueIdentifier sender:self.viewController];
    
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
    NSIndexPath *indexPath = nil;
    
    // When
    OTMenuItem *result = [self.viewController menuItemsAtIndexPath:indexPath];
    
    // Then
    XCTAssertNil(result);
}

- (void)test_menuItemsAtIndexPath_shouldReturnNilWhenIndexPathOutOfIndex
{
    // Given
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    
    id mockMenuItems = [OCMockObject niceMockForClass:NSArray.class];
    OCMExpect([mockMenuItems count]).andReturn(2);
    OCMStub([self.mockViewController menuItems]).andReturn(mockMenuItems);
    
    // When
    OTMenuItem *result = [self.viewController menuItemsAtIndexPath:indexPath];
    
    // Then
    XCTAssertNil(result);
}

- (void)test_menuItemsAtIndexPath_shouldReturnFirstMenuItemWhenExists
{
    // Given
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    id mockMenuItem = [OCMockObject niceMockForClass:OTMenuItem.class];
    
    id mockMenuItems = [OCMockObject niceMockForClass:NSArray.class];
    OCMExpect([mockMenuItems count]).andReturn(3);
    OCMStub([mockMenuItems objectAtIndex:0]).andReturn(mockMenuItem);
    
    OCMStub([self.mockViewController menuItems]).andReturn(mockMenuItems);
    
    // When
    OTMenuItem *result = [self.viewController menuItemsAtIndexPath:indexPath];
    
    // Then
    XCTAssertEqualObjects(result, mockMenuItem, @"");
}

- (void)test_menuItemsAtIndexPath_shouldReturnMenuItemInMiddleWhenExists
{
    // Given
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    
    id mockMenuItem = [OCMockObject niceMockForClass:OTMenuItem.class];
    
    id mockMenuItems = [OCMockObject niceMockForClass:NSArray.class];
    OCMExpect([mockMenuItems count]).andReturn(3);
    OCMStub([mockMenuItems objectAtIndex:1]).andReturn(mockMenuItem);
    
    OCMStub([self.mockViewController menuItems]).andReturn(mockMenuItems);
    
    // When
    OTMenuItem *result = [self.viewController menuItemsAtIndexPath:indexPath];
    
    // Then
    XCTAssertEqualObjects(result, mockMenuItem, @"");
}

- (void)test_menuItemsAtIndexPath_shouldReturnLastMenuItemWhenExists
{
    // Given
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    
    id mockMenuItem = [OCMockObject niceMockForClass:OTMenuItem.class];
    
    id mockMenuItems = [OCMockObject niceMockForClass:NSArray.class];
    OCMExpect([mockMenuItems count]).andReturn(3);
    OCMStub([mockMenuItems objectAtIndex:2]).andReturn(mockMenuItem);
    
    OCMStub([self.mockViewController menuItems]).andReturn(mockMenuItems);
    
    // When
    OTMenuItem *result = [self.viewController menuItemsAtIndexPath:indexPath];
    
    // Then
    XCTAssertEqualObjects(result, mockMenuItem, @"");
}

/**************************************************************************************************/
#pragma mark - - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender

- (void)test_prepareForSegue_allExpectedMethodsAreCalledWhenSegueIdentifierDoesntExistInDictionary
{
    // Given
    NSString *segueIdentifier = @"segueId";
    
    UIViewController *nextViewController = nil;
    UIViewController *destinationController = [UIViewController new];
    
    id mockStoryboardSegue = [OCMockObject niceMockForClass:UIStoryboardSegue.class];
    OCMExpect([mockStoryboardSegue identifier]).andReturn(segueIdentifier);
    OCMExpect([mockStoryboardSegue destinationViewController]).andReturn(destinationController);
    
    id mockControllersDictionary = [OCMockObject niceMockForClass:NSMutableDictionary.class];
    OCMExpect([mockControllersDictionary objectForKey:segueIdentifier]).andReturn(nextViewController);
    OCMExpect([mockControllersDictionary setObject:destinationController forKey:segueIdentifier]);
    OCMStub([self.mockViewController controllersDictionary]).andReturn(mockControllersDictionary);
    
    // When
    [self.viewController prepareForSegue:mockStoryboardSegue sender:OCMOCK_ANY];
    
    // Then
    [self.mockViewController verify];
    [mockStoryboardSegue verify];
}

@end
