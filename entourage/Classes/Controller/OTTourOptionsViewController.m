//
//  OTTourOptionsViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 25/02/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTourOptionsViewController.h"

@interface OTTourOptionsViewController ()

@property (nonatomic, weak) IBOutlet UILabel *createLabel;
@property (nonatomic, weak) IBOutlet UIButton *createButton;
@property (nonatomic, weak) IBOutlet UILabel *poiLabel;
@property (nonatomic, weak) IBOutlet UIButton *poiButton;

@property (nonatomic) BOOL isPOIVisible;

@end

@implementation OTTourOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (!CGPointEqualToPoint(self.c2aPoint, CGPointZero)) {
        self.createLabel.hidden = YES;
        self.createButton.hidden = YES;
        self.poiLabel.hidden = YES;
        self.poiButton.hidden = YES;
        
        [self addOptionWithIcon:@"report" andAction:@selector(doCreateEncounter:)];
    } else {
        if (self.isPOIVisible) {
            self.poiLabel.text = NSLocalizedString(@"map_options_hide_poi", @"");
        }
        else {
            self.poiLabel.text = NSLocalizedString(@"map_options_show_poi", @"");
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doCreateEncounter:(id)sender {
    if ([self.tourOptionsDelegate respondsToSelector:@selector(createEncounter)]) {
        [self.tourOptionsDelegate performSelector:@selector(createEncounter) withObject:nil];
    }
}

- (IBAction)doShowPOI:(id)sender {
    if ([self.tourOptionsDelegate respondsToSelector:@selector(togglePOI)]) {
        [self.tourOptionsDelegate performSelector:@selector(togglePOI) withObject:nil];
    }
}


- (IBAction)doDismiss:(id)sender {
    if ([self.tourOptionsDelegate respondsToSelector:@selector(dismissTourOptions)]) {
       [self.tourOptionsDelegate performSelector:@selector(dismissTourOptions) withObject:nil];
    }
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
