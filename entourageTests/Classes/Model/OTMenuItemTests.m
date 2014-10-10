//
//  OTMenuItemTests.m
//  entourage
//
//  Created by Cedric Pointel on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

// Model
#import "OTMenuItem.h"

@interface OTMenuItemTests : XCTestCase

@end

@implementation OTMenuItemTests

/**************************************************************************************************/
#pragma mark - - (instancetype)initWithTitle:(NSString *)title segueIdentifier:(NSString *)segueIdentifier

- (void)test_initWithTitleSegueIdentifier_shouldSetTitleAndSegueIdentifier
{
    // Given
    NSString *title = @"menuTitle";
    NSString *segueIdentifier = @"segueIdentifier";
    
    // When
    OTMenuItem *result = [[OTMenuItem alloc] initWithTitle:title segueIdentifier:segueIdentifier];
    
    // Then
    XCTAssertEqualObjects(result.title, title, @"");
    XCTAssertEqualObjects(result.segueIdentifier, segueIdentifier, @"");
}

@end
