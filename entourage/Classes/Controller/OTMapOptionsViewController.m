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

#define BUTTON_SIDE 48.0f
#define PADDING_VERTICAL 8.0f
#define PADDING_HORIZONTAL 16.0f
#define INITIAL_BOTTOM 82.0f

#define ACTION_LABEL_FRAME CGRectMake(0.0f, 0.0f, 230.0f, 21.0f)


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
            self.togglePOILabel.text = NSLocalizedString(@"map_options_hide_poi", @"");
        }
        else {
            self.togglePOILabel.text = NSLocalizedString(@"map_options_show_poi", @"");
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
    [self addOption:OTLocalizedString(@"create_tour") withIcon:@"createMaraude" andAction:@selector(doCreateTour:)];
    [self setupForPublicUser];
}

- (void)setupForPublicUser {
    [self addOption:OTLocalizedString(@"create_demande") withIcon:@"megaphone" andAction:@selector(doCreateDemande:)];
    [self addOption:OTLocalizedString(@"create_contribution") withIcon:@"heart" andAction:@selector(doCreateContribution:)];
    
    NSString *poiTitle = self.isPOIVisible ? @"map_options_hide_poi" : @"map_options_show_poi";
    [self addOption:OTLocalizedString(poiTitle) withIcon:@"solidarity" andAction:@selector(doTogglePOI:)];
}


- (void)addOption:(NSString *)optionName
         withIcon:(NSString *)optionIcon
        andAction:(SEL)selector
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat x = [UIScreen mainScreen].bounds.size.width - PADDING_HORIZONTAL - BUTTON_SIDE;
    CGFloat y = [UIScreen mainScreen].bounds.size.height - (self.buttonIndex++)*(PADDING_VERTICAL + BUTTON_SIDE) - INITIAL_BOTTOM;
    
    button.frame = CGRectMake(x, y, BUTTON_SIDE, BUTTON_SIDE);
    [button setImage:[UIImage imageNamed:optionIcon] forState:UIControlStateNormal];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UILabel *actionLabel = [[UILabel alloc] init];
    actionLabel.frame = ACTION_LABEL_FRAME;
    actionLabel.center = CGPointMake(button.center.x - actionLabel.frame.size.width/2.0f - PADDING_HORIZONTAL/2.0f - button.frame.size.width/2.0f, button.center.y);
    actionLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    actionLabel.textColor = [UIColor appOrangeColor];
    actionLabel.textAlignment = NSTextAlignmentRight;
    actionLabel.text = optionName;
    [self.view addSubview: actionLabel];
     
}


- (IBAction)doDismiss:(id)sender {
    if ([self.mapOptionsDelegate respondsToSelector:@selector(dismissMapOptions)]) {
        [self.mapOptionsDelegate performSelector:@selector(dismissMapOptions) withObject:nil];
    }
}

- (IBAction)doCreateTour:(id)sender {
    if ([self.mapOptionsDelegate respondsToSelector:@selector(createTour)]) {
        [self.mapOptionsDelegate performSelector:@selector(createTour) withObject:nil];
    }
}

- (IBAction)doCreateDemande:(id)sender {
    if ([self.mapOptionsDelegate respondsToSelector:@selector(createDemande)]) {
        [self.mapOptionsDelegate performSelector:@selector(createDemande) withObject:nil];
    }
}

- (IBAction)doCreateContribution:(id)sender {
    if ([self.mapOptionsDelegate respondsToSelector:@selector(createContribution)]) {
        [self.mapOptionsDelegate performSelector:@selector(createContribution) withObject:nil];
    }
}

- (IBAction)doTogglePOI:(id)sender {
    if ([self.mapOptionsDelegate respondsToSelector:@selector(togglePOI)]) {
        [self.mapOptionsDelegate performSelector:@selector(togglePOI) withObject:nil];
    }
}

- (void)setIsPOIVisible:(BOOL)POIVisible {
    _isPOIVisible = POIVisible;
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
