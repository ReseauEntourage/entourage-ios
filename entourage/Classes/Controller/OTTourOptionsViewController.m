//
//  OTTourOptionsViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 25/02/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTourOptionsViewController.h"
#import "OTConsts.h"
#import "UIColor+entourage.h"


#define BUTTON_SIDE 48.0f
#define PADDING_VERTICAL 8.0f
#define PADDING_HORIZONTAL 16.0f
#define INITIAL_BOTTOM 82.0f

#define ACTION_LABEL_FRAME CGRectMake(0.0f, 0.0f, 230.0f, 21.0f)

@interface OTTourOptionsViewController ()

@property (nonatomic, weak) IBOutlet UILabel *createLabel;
@property (nonatomic, weak) IBOutlet UIButton *createButton;
@property (nonatomic, weak) IBOutlet UILabel *poiLabel;
@property (nonatomic, weak) IBOutlet UIButton *poiButton;
@property (nonatomic) int buttonIndex;

@property (nonatomic) BOOL isPOIVisible;

@end

@implementation OTTourOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.buttonIndex = 1;
    // Do any additional setup after loading the view.
    if (!CGPointEqualToPoint(self.c2aPoint, CGPointZero)) {
        self.createLabel.hidden = YES;
        self.createButton.hidden = YES;
        self.poiLabel.hidden = YES;
        self.poiButton.hidden = YES;
        
        [self addOptionWithIcon:@"report" andAction:@selector(doCreateEncounter:)];
    } else {
        if (self.isPOIVisible) {
            self.poiLabel.text = OTLocalizedString(@"map_options_hide_poi");
        }
        else {
            self.poiLabel.text = OTLocalizedString(@"map_options_show_poi");
        }
    }
    
    [self addOption:OTLocalizedString(@"create_encounter")
            atIndex:self.buttonIndex++
           withIcon:@"report"
          andAction:@selector(doCreateEncounter:)];
    
    [self addOption:OTLocalizedString(@"create_demande")
            atIndex:self.buttonIndex++
           withIcon:@"megaphone"
          andAction:@selector(doCreateDemande:)];
    
    [self addOption:OTLocalizedString(@"create_contribution")
            atIndex:self.buttonIndex++
           withIcon:@"heart"
          andAction:@selector(doCreateContribution:)];
    
    NSString *poiTitle = self.isPOIVisible ? @"map_options_hide_poi" : @"map_options_show_poi";
    [self addOption:OTLocalizedString(poiTitle)
            atIndex:self.buttonIndex++
           withIcon:@"solidarity"
          andAction:@selector(doTogglePOI:)];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setIsPOIVisible:(BOOL)isPOIVisible {
    _isPOIVisible = isPOIVisible;
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
    
    button.frame = CGRectMake(self.c2aPoint.x - image.size.width/2, self.c2aPoint.y+10, image.size.width, image.size.height);
    [button setImage:[UIImage imageNamed:optionIcon] forState:UIControlStateNormal];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

@end
