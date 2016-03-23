//
//  OTQuitTourViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 23/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTQuitTourViewController.h"
#import "OTTourService.h"

@implementation OTQuitTourViewController

- (IBAction)doQuitTour {
    [[OTTourService new] quitTour:self.tour
                          success:^(OTTour *updatedTour) {
                              NSLog(@"Quited tour: %@", updatedTour.sid);
                              [self dismissViewControllerAnimated:YES completion:nil];
                          } failure:^(NSError *error) {
                              NSLog(@"QUITerr %@", error.description);
                          }];
}

- (IBAction)dismissViewController {
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"dismissed quit tour view controller");
    }];
}

@end
