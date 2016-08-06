//
//  OTMapViewController.m
//  entourage
//
//  Created by sergiu buceac on 8/7/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMapViewController.h"
#import "UIColor+entourage.h"
#import "OTFeedItemFactory.h"
#import "OTMapAnnotationProviderBehavior.h"
#import "OTStatusChangedBehavior.h"

@interface OTMapViewController ()

@property (strong, nonatomic) IBOutlet OTMapAnnotationProviderBehavior *annotationProvider;
@property (strong, nonatomic) IBOutlet OTStatusChangedBehavior *statusChangedBehavior;

@end

@implementation OTMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.annotationProvider configureWith:self.feedItem];
    [self.annotationProvider addStartPoint];
    [self.annotationProvider drawData];
    [self.statusChangedBehavior configureWith:self.feedItem];

    self.title = [[[OTFeedItemFactory createFor:self.feedItem] getUI] navigationTitle].uppercaseString;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.tintColor = [UIColor appOrangeColor];
}

#pragma mark - navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([self.statusChangedBehavior prepareSegueForNextStatus:segue])
        return;
}

@end
