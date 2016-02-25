//
//  OTTourOptionsViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 25/02/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTourOptionsViewController.h"

@interface OTTourOptionsViewController ()

@end

@implementation OTTourOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doCreateEncounter:(id)sender {
    if ([self.tourOptionsDelegate respondsToSelector:@selector(createEncounter)]) {
        [self.tourOptionsDelegate performSelector:@selector(createEncounter) withObject:nil];
    }
}


- (IBAction)doDismiss:(id)sender {
    if ([self.tourOptionsDelegate respondsToSelector:@selector(dismissTourOptions)]) {
       [self.tourOptionsDelegate performSelector:@selector(dismissTourOptions) withObject:nil];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
