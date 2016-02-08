//
//  OTTourViewController.m
//  entourage
//
//  Created by Nicolas Telera on 20/11/2015.
//  Copyright © 2015 OCTO Technology. All rights reserved.
//

#import "OTTourViewController.h"
#import "OTTour.h"
#import "OTTourPoint.h"
#import "OTOrganization.h"

@interface OTTourViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *tourTypeImage;

@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *startTime;
@property (nonatomic, weak) IBOutlet UILabel *endTime;
@property (nonatomic, weak) IBOutlet UILabel *organizationNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *transportTypeLabel;
@property (nonatomic, weak) IBOutlet UILabel *tourTypeLabel;
@property (nonatomic, weak) IBOutlet UILabel *tourStatusLabel;

@property (nonatomic, weak) IBOutlet UIButton *backButton;

@end

@implementation OTTourViewController

/**************************************************************************************************/
#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    
    NSString *date = [self formatDateForDisplay:self.tour.startTime];
    NSString *startTime = [self formatHourForDisplay:self.tour.startTime];
    NSString *endTime = [self formatHourForDisplay:self.tour.endTime];
    NSString *image;
    NSString *vehicle;
    NSString *type;
    NSString *status;
    
    if ([self.tour.vehicleType isEqualToString:@"feet"]) {
        vehicle = @"A pieds";
    }
    else if ([self.tour.vehicleType isEqualToString:@"car"]) {
        vehicle = @"En voiture";
    }
    
    if ([self.tour.tourType isEqualToString:@"barehands"]) {
        image = @"ic_bare_hands.png";
        type = @"A mains nues";
    }
    else if ([self.tour.tourType isEqualToString:@"medical"]) {
        image = @"ic_medical.png";
        type = @"Médicale";
    }
    else if ([self.tour.tourType isEqualToString:@"alimentary"]) {
        image = @"ic_alimentary.png";
        type = @"Alimentaire";
    }
    
    if ([self.tour.status isEqualToString:@"ongoing"]) {
        status = @"En cours";
    }
    else if ([self.tour.status isEqualToString:@"closed"]) {
        status = @"Terminée";
    }
    
    //self.tourTypeImage.image = [UIImage imageNamed:image];
    self.dateLabel.text = date;
    self.startTime.text = startTime;
    self.endTime.text = endTime;
    self.organizationNameLabel.text = self.tour.organizationName;
    self.transportTypeLabel.text = vehicle;
    self.tourTypeLabel.text = type;
    self.tourStatusLabel.text = status;
}

/**************************************************************************************************/
#pragma mark - Public Methods

- (void)configureWithTour:(OTTour *)tour {
    self.tour = tour;
}

- (NSString *)formatDateForDisplay:(NSDate *)date {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    return [formatter stringFromDate:date];
}

- (NSString *)formatHourForDisplay:(NSDate *)date {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"HH'h'mm"];
    return [formatter stringFromDate:date];
}

/**************************************************************************************************/
#pragma mark - Actions

- (IBAction)closeModal:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
