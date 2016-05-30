//
//  OTMapOptionsViewController.m
//  entourage
//
//  Created by Mihai Ionescu on 04/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMapOptionsViewController.h"
#import "OTConsts.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"
#import "UIColor+entourage.h"




@interface OTMapOptionsViewController ()

@property (nonatomic, weak) IBOutlet UIButton *createTourButton;
@property (nonatomic, weak) IBOutlet UILabel *createTourLabel;
@property (nonatomic, weak) IBOutlet UIButton *togglePOIButton;
@property (nonatomic, weak) IBOutlet UILabel *togglePOILabel;
@property (nonatomic) int buttonIndex;


@property (nonatomic) BOOL isPOIVisible;

@end

@implementation OTMapOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.buttonIndex = 1;
    if (!CGPointEqualToPoint(self.fingerPoint, CGPointZero)) {
        self.togglePOILabel.hidden = YES;
        self.togglePOIButton.hidden = YES;
        self.createTourLabel.hidden = YES;
        
        self.createTourButton.hidden = YES;
        //[self addOptionWithIcon:@"createMaraude" andAction:@selector(doCreateTour:)];
        
    } else {
        if (self.isPOIVisible) {
            self.togglePOILabel.text = OTLocalizedString(@"map_options_hide_poi");
        }
        else {
            self.togglePOILabel.text = OTLocalizedString(@"map_options_show_poi");
        }
    }
    
    OTUser *currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
    if ([currentUser.type isEqualToString:USER_TYPE_PRO]) {
        [self setupForProUser];
    } else {
        [self setupForPublicUser];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupForProUser {
    [self addOption:OTLocalizedString(@"create_tour") atIndex:self.buttonIndex++ withIcon:@"createMaraude" andAction:@selector(doCreateTour:)];
    [self setupForPublicUser];
}

- (void)setupForPublicUser {
    [self addOption:OTLocalizedString(@"create_demande") atIndex:self.buttonIndex++ withIcon:@"megaphone" andAction:@selector(doCreateDemande:)];
    [self addOption:OTLocalizedString(@"create_contribution") atIndex:self.buttonIndex++ withIcon:@"heart" andAction:@selector(doCreateContribution:)];
    
    NSString *poiTitle = self.isPOIVisible ? @"map_options_hide_poi" : @"map_options_show_poi";
    [self addOption:OTLocalizedString(poiTitle) atIndex:self.buttonIndex++ withIcon:@"solidarity" andAction:@selector(doTogglePOI:)];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
 */

- (void)addOptionWithIcon:(NSString *)optionIcon
                andAction:(SEL)selector
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:optionIcon];
    
    button.frame = CGRectMake(self.fingerPoint.x - image.size.width/2, self.fingerPoint.y+10, image.size.width, image.size.height);
    [button setImage:[UIImage imageNamed:optionIcon] forState:UIControlStateNormal];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

@end
