//
//  OTConfirmationViewController.m
//  
//
//  Created by OCTO-NTE on 16/11/2015.
//
//

// Controller
#import "OTConfirmationViewController.h"
#import "OTMapViewController.h"

// Service
#import "OTTourService.h"

// Model
#import "OTTour.h"

/*************************************************************************************************/
#pragma mark - OTConfirmationViewController

@interface OTConfirmationViewController ()

@property (nonatomic, strong) OTTour *tour;

@property (nonatomic, weak) IBOutlet UIButton *resumeTourButton;
@property (nonatomic, weak) IBOutlet UIButton *finishTourButton;

@end

@implementation OTConfirmationViewController

/**************************************************************************************************/
#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

/**************************************************************************************************/
#pragma mark - Public Methods

- (void)configureWithTour:(OTTour *)currentTour {
    self.tour = currentTour;
}

/**************************************************************************************************/
#pragma mark - Private methods

- (void)closeTour {
    [[OTTourService new] closeTour:self.tour withSuccess:^(OTTour *closedTour) {
        if ([self.delegate respondsToSelector:@selector(tourSent)]) {
            [self.delegate tourSent];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(NSError *error) {
    }];
}

/**************************************************************************************************/
#pragma mark - Actions

- (IBAction)resumeTour:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)finishTour:(id)sender {
    self.tour.status = NSLocalizedString(@"tour_status_closed", @"");
    [self closeTour];
}

@end
