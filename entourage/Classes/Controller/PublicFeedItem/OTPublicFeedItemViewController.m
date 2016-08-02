//
//  OTPublicFeedItemViewController.m
//  entourage
//
//  Created by sergiu buceac on 8/2/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTPublicFeedItemViewController.h"
#import "OTSummaryProviderBehavior.h"

@interface OTPublicFeedItemViewController ()

@property (strong, nonatomic) IBOutlet OTSummaryProviderBehavior *summaryProvider;

@end

@implementation OTPublicFeedItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.summaryProvider configureWith:self.feedItem];
}

@end
