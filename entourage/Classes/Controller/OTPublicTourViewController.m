//
//  OTPublicTourViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 22/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTPublicTourViewController.h"
#import "UIViewController+menu.h"
#import "UIButton+entourage.h"
#import "UILabel+entourage.h"

@interface OTPublicTourViewController ()

@property (nonatomic, weak) IBOutlet UILabel *organizationNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *typeNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLocationLabel;
@property (nonatomic, weak) IBOutlet UILabel *noUsersLabel;
@property (nonatomic, weak) IBOutlet UIButton *userProfileImageButton;
@property (nonatomic, weak) IBOutlet UIButton *joinButton;
@property (nonatomic, weak) IBOutlet UILabel *joinLabel;



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
    [self.timeLocationLabel setupWithTimeAndLocationOfTour:self.tour];
    
    [self.userProfileImageButton addTarget:self action:@selector(doShowProfile) forControlEvents:UIControlEventTouchUpInside];
    [self.userProfileImageButton setupAsProfilePictureFromUrl:self.tour.author.avatarUrl];

    self.noUsersLabel.text = [NSString stringWithFormat:@"%d", self.tour.noPeople.intValue];
    
    
    [self.joinButton setupWithJoinStatusOfTour:self.tour];
    [self.joinLabel setupWithJoinStatusOfTour:self.tour];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doShowProfile {
    
}

- (IBAction)doJoinTour {
    
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
