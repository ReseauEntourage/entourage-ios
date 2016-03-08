//
//  OTTourDetailsOptionsViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 08/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTourDetailsOptionsViewController.h"

@interface OTTourDetailsOptionsViewController ()

@end

@implementation OTTourDetailsOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (IBAction)doCloseTour {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doQuitTour {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)dismissOptions {
    [self dismissViewControllerAnimated:YES completion:nil];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
 OTTourJoinRequestViewController *controller = (OTTourJoinRequestViewController *)segue.destinationViewController;
 controller.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.1];
 [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];

}
*/

@end
