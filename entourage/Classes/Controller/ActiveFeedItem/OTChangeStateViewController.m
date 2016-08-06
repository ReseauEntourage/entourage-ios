//
//  OTChangeStateViewController.m
//  entourage
//
//  Created by sergiu buceac on 8/6/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTChangeStateViewController.h"

@interface OTChangeStateViewController ()

@property (strong, nonatomic) IBOutlet OTNextStatusButtonBehavior *nextStatusBehavior;

@end

@implementation OTChangeStateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.nextStatusBehavior configureWith:self.feedItem andProtocol:self.delegate];
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
