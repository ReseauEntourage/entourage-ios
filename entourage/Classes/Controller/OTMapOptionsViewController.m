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
#define INITI


@interface OTMapOptionsViewController ()

@property (nonatomic, weak) IBOutlet UIButton *createTourButton;
@property (nonatomic, weak) IBOutlet UILabel *createTourLabel;
@property (nonatomic, weak) IBOutlet UIButton *togglePOIButton;
@property (nonatomic, weak) IBOutlet UILabel *togglePOILabel;

@property (nonatomic) BOOL isPOIVisible;

@end

@implementation OTMapOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.isPOIVisible) {
        self.togglePOILabel.text = NSLocalizedString(@"map_options_hide_poi", @"");
    }
    else {
        self.togglePOILabel.text = NSLocalizedString(@"map_options_show_poi", @"");
    }
    
    OTUser *currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
    if ([currentUser.type isEqualToString:USER_TYPE_PRO]) {
        
    } else {
        [self setupForPublicUser];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupForPublicUser {
    //[self addOption:OTLocalizedString(@"create_tour") withIcon:@"createMaraude" andAction:nil];
    [self addOption:OTLocalizedString(@"create_demande") withIcon:@"megaphone" andAction:@selector(doDismiss:)];
    
}

- (void)addOption:(NSString *)optionName
         withIcon:(NSString *)optionIcon
        andAction:(SEL)selector
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat x = [UIScreen mainScreen].bounds.size.width - PADDING_HORIZONTAL - BUTTON_SIDE;
    CGFloat y = [UIScreen mainScreen].bounds.size.height - PADDING_VERTICAL - BUTTON_SIDE;
    
    button.frame = CGRectMake(x, y, BUTTON_SIDE, BUTTON_SIDE);
    [button setImage:[UIImage imageNamed:optionIcon] forState:UIControlStateNormal];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
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

@end
