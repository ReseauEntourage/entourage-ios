//
//  OTMessageViewController.m
//  entourage
//
//  Created by Nicolas Telera on 16/12/2015.
//  Copyright © 2015 OCTO Technology. All rights reserved.
//

#import "OTMessageViewController.h"

/*************************************************************************************************/
#pragma mark - OTMessageViewController

@interface OTMessageViewController ()

@property (weak, nonatomic) IBOutlet UILabel *organizationLabel;
@property (weak, nonatomic) IBOutlet UILabel *objectLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@end

@implementation OTMessageViewController

/**************************************************************************************************/
#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

/**************************************************************************************************/
#pragma mark - Public Methods

- (void)configureWithSender:(NSString *)sender andObject:(NSString *)object andMessage:(NSString *)message {
    [self.organizationLabel setText:sender];
    [self.objectLabel setText:object];
    [self.messageLabel setText:message];
}

/**************************************************************************************************/
#pragma mark - Actions

- (IBAction)closeMessage:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
