//
//  OTMenuTableViewCellTests.m
//  entourage
//
//  Created by Cedric Pointel on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

// View
#import "OTMenuTableViewCell.h"

@interface OTMenuTableViewCellTests : XCTestCase

@property (nonatomic, strong) OTMenuTableViewCell *viewCell;
@property (nonatomic, strong) id mockViewCell;

@end

@implementation OTMenuTableViewCellTests

- (void)setUp
{
    [super setUp];
    
    self.viewCell = [[OTMenuTableViewCell alloc] init];
    self.mockViewCell = [OCMockObject partialMockForObject:self.viewCell];
}

/**************************************************************************************************/
#pragma mark - - (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated

- (void)test_setHighlightedAnimated_shouldHighlightItemLabelWhenHighlightedIsYes
{
    // Given
    id mockItemLabel = [OCMockObject niceMockForClass:UILabel.class];
    OCMExpect([mockItemLabel setHighlighted:YES]);
    OCMStub([self.mockViewCell itemLabel]).andReturn(mockItemLabel);
    
    // When
    [self.viewCell setHighlighted:YES animated:NO];
    
    // Then
    [mockItemLabel verify];
}

- (void)test_setHighlightedAnimated_shouldNotHighlightItemLabelWhenHighlightedIsNo
{
    // Given
    id mockItemLabel = [OCMockObject niceMockForClass:UILabel.class];
    OCMExpect([mockItemLabel setHighlighted:NO]);
    OCMStub([self.mockViewCell itemLabel]).andReturn(mockItemLabel);
    
    // When
    [self.viewCell setHighlighted:NO animated:NO];
    
    // Then
    [mockItemLabel verify];
}

@end
