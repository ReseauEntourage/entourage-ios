//
//  OTTourDetailsOptionsViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 08/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTourDetailsOptionsViewController.h"
#import "OTTourService.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"
#import "UIColor+entourage.h"

#define BUTTON_HEIGHT 44.0f
#define BUTTON_DELTAY  8.0f
#define BUTTON_FONT_SIZE 17

@interface OTTourDetailsOptionsViewController ()

@property (nonatomic, weak) IBOutlet UIButton *cancelTourButton;

@end

@implementation OTTourDetailsOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    OTUser *currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
    if ([currentUser.sid intValue] == [self.tour.author.uID intValue]) {
        NSLog(@"status>>> %@", self.tour.status);
        if ([self.tour.status isEqualToString:@"ongoing"])
            [self addButtonWithTitle:@"Arrêter" withSelectorNamed:@"doCloseTour"];
        else
            [self addButtonWithTitle:@"Clôturer" withSelectorNamed:@"doFreezeTour"];
    } else {
        [self addButtonWithTitle:@"Quitter" withSelectorNamed:@"doQuitTour"];
    }

}

- (void)addButtonWithTitle:(NSString *)title withSelectorNamed:(NSString *)selector {
    CGRect frame = self.cancelTourButton.frame;
    frame.origin.y -= (BUTTON_HEIGHT + BUTTON_DELTAY);
    frame.size.height = BUTTON_HEIGHT;
    
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    button.backgroundColor = [UIColor whiteColor];
    [button.titleLabel setFont:[UIFont systemFontOfSize:BUTTON_FONT_SIZE]];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor appOrangeColor] forState:UIControlStateNormal];
    [button addTarget:self action:NSSelectorFromString(selector) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (IBAction)doFreezeTour {
    self.tour.status = TOUR_STATUS_FREEZED;
    [[OTTourService new] closeTour:self.tour
                       withSuccess:^(OTTour *updatedTour) {
                           NSLog(@"freezed tour: %@", updatedTour.uid);
                           [self dismissViewControllerAnimated:YES completion:nil];
                       } failure:^(NSError *error) {
                           NSLog(@"FREEZEerr %@", error.description);
                       }];
}

- (IBAction)doCloseTour {
    
    [[OTTourService new] closeTour:self.tour
                          withSuccess:^(OTTour *updatedTour) {
                              NSLog(@"Closed tour: %@", updatedTour.uid);
                              //[self dismissViewControllerAnimated:YES completion:nil];
                              [self.delegate promptToCloseTour];
                          } failure:^(NSError *error) {
                              NSLog(@"CLOSEerr %@", error.description);
                          }];
}

- (IBAction)doQuitTour {
    [[OTTourService new] quitTour:self.tour
                          success:^() {
                                NSLog(@"Quited tour: %@", self.tour.uid);
                                [self dismissViewControllerAnimated:YES completion:nil];
                        } failure:^(NSError *error) {
                                NSLog(@"QUITerr %@", error.description);
                                }];
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
