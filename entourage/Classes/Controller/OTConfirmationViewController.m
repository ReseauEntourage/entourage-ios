//
//  OTConfirmationViewController.m
//  entourage
//
//  Created by Nicolas Telera on 16/11/2015.
//  Copyright © 2015 OCTO Technology. All rights reserved.
//

// Controller
#import "OTConfirmationViewController.h"
#import "OTMapViewController.h"

// Service
#import "OTTourService.h"

// Model
#import "OTTour.h"

// View
#import "SVProgressHUD.h"

/*************************************************************************************************/
#pragma mark - OTConfirmationViewController

@interface OTConfirmationViewController ()

@property (nonatomic, strong) OTTour *tour;
@property (nonatomic, strong) NSNumber *encountersCount;
@property (nonatomic) NSTimeInterval duration;

@property (nonatomic, weak) IBOutlet UILabel *encountersLabel;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *durationLabel;
@property (nonatomic, weak) IBOutlet UIButton *resumeTourButton;
@property (nonatomic, weak) IBOutlet UIButton *finishTourButton;

@end

@implementation OTConfirmationViewController

/**************************************************************************************************/
#pragma mark - Life cycle

- (void)viewWillAppear:(BOOL)animated {
    self.encountersLabel.text = [NSString stringWithFormat:@"%@ personnes rencontrées", self.encountersCount];
    self.distanceLabel.text = [NSString stringWithFormat:@"%@ km parcourus", [self stringFromFloatDistance:(self.tour.distance)]];
    self.durationLabel.text = [NSString stringWithFormat:@"%@ passées dans la rue", [self stringFromTimeInterval:(self.duration)]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

/**************************************************************************************************/
#pragma mark - Public Methods

- (void)configureWithTour:(OTTour *)currentTour andEncountersCount:(NSNumber *)encountersCount andDuration:(NSTimeInterval)duration {
    self.tour = currentTour;
    self.encountersCount = encountersCount;
    self.duration = duration;
}

/**************************************************************************************************/
#pragma mark - Private methods

- (void)closeTour {
    [[OTTourService new] closeTour:self.tour withSuccess:^(OTTour *closedTour) {
        if ([self.delegate respondsToSelector:@selector(tourSent)]) {
            NSLog(@"inside");
            [self.delegate tourSent];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Erreur de fermeture de la maraude"];
        NSLog(@"%@",[error localizedDescription]);
    }];
}

/**************************************************************************************************/
#pragma mark - Actions

- (IBAction)resumeTour:(id)sender {
    if ([self.delegate respondsToSelector:@selector(resumeTour)]) {
        [self.delegate resumeTour];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)finishTour:(id)sender {
    [SVProgressHUD show];
    self.tour.status = NSLocalizedString(@"tour_status_closed", @"");
    [self closeTour];
}

/**************************************************************************************************/
#pragma mark - Utils

- (NSString *)stringFromFloatDistance:(float)distance {
    float displayDistance = distance / 1000;
    displayDistance = floorf(displayDistance * 100) / 100;
    NSString *stringDistance = [[NSNumber numberWithFloat:displayDistance] stringValue];
    NSArray *parts = [stringDistance componentsSeparatedByString:@"."];
    if ([parts count] > 1) {
        return [NSString stringWithFormat:@"%@,%@", [parts objectAtIndex:0], [parts objectAtIndex:1]];
    } else {
        return [NSString stringWithFormat:@"0,0"];
    }
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    double hours = floor(interval / 60 / 60);
    double minutes = floor((interval - (hours * 60 * 60)) / 60);
    double seconds = floor(interval - (hours * 60 * 60) - (minutes * 60));
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
}

@end
