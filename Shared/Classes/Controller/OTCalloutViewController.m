//
//  OTCalloutViewController.m
//  entourage
//
//  Created by Guillaume Lagorce on 10/10/2014.
//  Copyright (c) 2014 Entourage. All rights reserved.
//

#import "OTCalloutViewController.h"

// Model
#import "OTPoi.h"

@interface OTCalloutViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation OTCalloutViewController

/********************************************************************************/
#pragma mark - Public Methods

- (void)configureWithPoi:(OTPoi *)poi
{
	NSMutableString *text = [NSMutableString string];

	[self appendNotNilString:poi.name toString:text];
	[self appendNotNilString:poi.audience toString:text];
	[self appendNotNilString:poi.details toString:text];
	[self appendNotNilString:poi.address toString:text];
	[self appendNotNilString:poi.phone toString:text];
	[self appendNotNilString:poi.email toString:text];
	[self appendNotNilString:poi.website toString:text];

	self.textView.text = text;
}

/********************************************************************************/
#pragma mark - Private Methods

- (void)appendNotNilString:(NSString *)otherText toString:(NSMutableString *)text
{
	if (otherText)
	{
		[text appendFormat:@"\n%@", otherText];
	}
}

/********************************************************************************/
#pragma mark - IBActions

- (IBAction)closeMe:(id)sender
{
}

@end
