//
//  OTConfirmationViewController.m
//  entourage
//
//  Created by Nicolas Telera on 16/11/2015.
//  Copyright © 2015 OCTO Technology. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>

// Controller
#import "OTConfirmationViewController.h"
#import "OTConsts.h"
#import "NSUserDefaults+OT.h"

// Service
#import "OTTourService.h"

// Model
#import "OTTour.h"

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
    [super viewWillAppear:animated];
    self.encountersLabel.text = [NSString stringWithFormat:@"%@", self.encountersCount];
    self.distanceLabel.text = [self stringFromFloatDistance:(self.tour.distance.floatValue)];
    self.durationLabel.text = [self stringFromTimeInterval:(self.duration)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

/**************************************************************************************************/
#pragma mark - Public Methods

- (void)configureWithTour:(OTTour *)currentTour andEncountersCount:(NSNumber *)encountersCount {
    self.tour = currentTour;
    self.encountersCount = encountersCount;
    self.duration = [[NSDate date] timeIntervalSinceDate:self.tour.creationDate];
}

/**************************************************************************************************/
#pragma mark - Private methods

- (void)closeTour {
    self.tour.status = FEEDITEM_STATUS_CLOSED;
    self.tour.endTime = [NSDate date];
    
    [[OTTourService new]
        closeTour:self.tour
        withSuccess:^(OTTour *closedTour) {
            [SVProgressHUD dismiss];
            if ([self.delegate respondsToSelector:@selector(tourSent:)])
                [self.delegate tourSent:self.tour];
            [[NSUserDefaults standardUserDefaults] setCurrentOngoingTour:nil];
            [[NSUserDefaults standardUserDefaults] setTourPoints:nil];

            [self dismissAction];
        } failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus: OTLocalizedString(@"tour_close_error")];
            if ([self.delegate respondsToSelector:@selector(tourCloseError)])
                [self.delegate tourCloseError];

            [self dismissAction];
            NSLog(@"%@",[error localizedDescription]);
        }];
}

/**************************************************************************************************/
#pragma mark - Actions

- (void)dismissAction {
    [OTAppState hideTabBar:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)resumeTour:(id)sender {
    [OTLogger logEvent:@"TourRestart"];
    if ([self.delegate respondsToSelector:@selector(resumeTour)]) {
        [self.delegate resumeTour];
    }
    [self dismissAction];
}

- (IBAction)finishTour:(id)sender {
    [OTLogger logEvent:@"TourStop"];
    [SVProgressHUD show];
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
