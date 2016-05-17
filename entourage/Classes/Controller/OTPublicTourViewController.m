//
//  OTPublicTourViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 22/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTPublicTourViewController.h"
#import "OTTourJoinRequestViewController.h"
#import "OTUserViewController.h"
#import "UIViewController+menu.h"
#import "UIButton+entourage.h"
#import "UILabel+entourage.h"

#import "OTTourPoint.h"

#import <MapKit/MapKit.h>

@interface OTPublicTourViewController () <OTTourJoinRequestDelegate>

@property (nonatomic, weak) IBOutlet UILabel *organizationNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *typeNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLocationLabel;
@property (nonatomic, weak) IBOutlet UILabel *noUsersLabel;
@property (nonatomic, weak) IBOutlet UIButton *userProfileImageButton;
@property (nonatomic, weak) IBOutlet UIButton *joinButton;
@property (nonatomic, weak) IBOutlet UILabel *joinLabel;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;


@end

@implementation OTPublicTourViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"MARAUDE";
    [self setupCloseModal];
    [self setupMoreButtons];
    [self setupUI];
}

- (void)setupMoreButtons {
    UIImage *shareImage = [[UIImage imageNamed:@"share.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem *joinButton = [[UIBarButtonItem alloc] init];
    [joinButton setImage:shareImage];
    [joinButton setTarget:self];
    [joinButton setAction:@selector(doJoinTour)];
    
    //    UIImage *saveImage = [[UIImage imageNamed:@"save.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] init];
    //    [saveButton setImage:saveImage];
    //    [saveButton setTarget:self];
    //    [saveButton setAction:@selector(showOptions)];
    
    [self.navigationItem setRightBarButtonItems:@[joinButton]];
}

- (void)setupUI {
    self.organizationNameLabel.text = self.tour.organizationName;
    [self.typeNameLabel setupWithTypeAndAuthorOfTour:self.tour];
//    [self.timeLocationLabel setupWithTimeAndLocationOfTour:self.tour];
//    
    OTTourPoint *startPoint = self.tour.tourPoints.firstObject;
    CLLocation *startPointLocation = [[CLLocation alloc] initWithLatitude:startPoint.latitude longitude:startPoint.longitude];
    [self.timeLocationLabel setupWithTime:self.tour.startTime andLocation:startPointLocation];
    
    [self.userProfileImageButton addTarget:self action:@selector(doShowProfile) forControlEvents:UIControlEventTouchUpInside];
    [self.userProfileImageButton setupAsProfilePictureFromUrl:self.tour.author.avatarUrl];

    self.noUsersLabel.text = [NSString stringWithFormat:@"%d", self.tour.noPeople.intValue];
    
    
    //[self.joinButton setupWithJoinStatusOfTour:self.tour];
    [self.joinButton setupWithStatus:self.tour.status andJoinStatus:self.tour.joinStatus];
    //[self.joinLabel setupWithJoinStatusOfTour:self.tour];
    [self.joinLabel setupWithStatus:self.tour.status andJoinStatus:self.tour.joinStatus];
    
    if ([self.tour.tourPoints count] > 0) {
        OTTourPoint *startPoint = self.tour.tourPoints[0];
        CLLocationCoordinate2D startCoordinate = CLLocationCoordinate2DMake(startPoint.latitude, startPoint.longitude);
        [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(startCoordinate, 1000, 1000)];
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        [annotation setCoordinate:startCoordinate];
        [self.mapView addAnnotation:annotation];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doShowProfile {
    [self performSegueWithIdentifier:@"OTUserProfileSegue" sender:self.tour.author.uID];
}

- (IBAction)doJoinTour {
    [self performSegueWithIdentifier:@"PublicJoinRequestSegue" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"PublicJoinRequestSegue"]) {
        OTTourJoinRequestViewController *controller = (OTTourJoinRequestViewController *)segue.destinationViewController;
        controller.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.1];
        [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        controller.tour = self.tour;
        controller.tourJoinRequestDelegate = self;
    }
    else if ([segue.identifier isEqualToString:@"OTUserProfileSegue"]) {
        UINavigationController *navController = segue.destinationViewController;
        OTUserViewController *controller = (OTUserViewController*)navController.topViewController;
        controller.userId = (NSNumber *)sender;
    }
}

/********************************************************************************/
#pragma mark - OTTourJoinRequestDelegate
- (void)dismissTourJoinRequestController {
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"dismissed tour join screen");
        [self setupUI];
    }];
}

@end
