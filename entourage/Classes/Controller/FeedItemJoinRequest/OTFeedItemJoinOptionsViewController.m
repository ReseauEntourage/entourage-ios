//
//  OTFeedItemJoinOptionsViewController.m
//  entourage
//
//  Created by sergiu buceac on 9/12/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTFeedItemJoinOptionsViewController.h"
#import "UIView+entourage.h"

@interface OTFeedItemJoinOptionsViewController ()

@property (weak, nonatomic) IBOutlet UIButton *btnAddMessage;

@end

@implementation OTFeedItemJoinOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.btnAddMessage setupHalfRoundedCorners];
}

- (IBAction)addMessage:(id)sender {
    [self.joinDelegate addMessage];
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
