//
//  OTCalloutViewController.m
//  entourage
//
//  Created by Guillaume Lagorce on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTCalloutViewController.h"

// Model
#import "OTPoi.h"

@interface OTCalloutViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *mailLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *webLabel;


@end

@implementation OTCalloutViewController

- (void)configureWithPoi:(OTPoi *)poi
{
	self.titleLabel.text = poi.name;
	self.mailLabel.text = poi.email;
}

@end
