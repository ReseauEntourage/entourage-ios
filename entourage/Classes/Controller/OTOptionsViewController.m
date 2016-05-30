//
//  OTOptionsViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 30/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTOptionsViewController.h"

@interface OTOptionsViewController ()

@end

@implementation OTOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)addOption:(NSString *)optionName
          atIndex:(int)index
         withIcon:(NSString *)optionIcon
        andAction:(SEL)selector
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat x = [UIScreen mainScreen].bounds.size.width - PADDING_HORIZONTAL - BUTTON_SIDE;
    CGFloat y = [UIScreen mainScreen].bounds.size.height - (index)*(PADDING_VERTICAL + BUTTON_SIDE) - INITIAL_BOTTOM;
    
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

#pragma mark - Actions

- (IBAction)doCreateTour:(id)sender {
    if ([self.optionsDelegate respondsToSelector:@selector(createTour)]) {
        [self.optionsDelegate performSelector:@selector(createTour) withObject:nil];
    }
}

- (IBAction)doCreateEncounter:(id)sender {
    if ([self.optionsDelegate respondsToSelector:@selector(createEncounter)]) {
        [self.optionsDelegate performSelector:@selector(createEncounter) withObject:nil];
    }
}

- (IBAction)doCreateDemande:(id)sender {
    if ([self.optionsDelegate respondsToSelector:@selector(createDemande)]) {
        [self.optionsDelegate performSelector:@selector(createDemande) withObject:nil];
    }
}

- (IBAction)doCreateContribution:(id)sender {
    if ([self.optionsDelegate respondsToSelector:@selector(createContribution)]) {
        [self.optionsDelegate performSelector:@selector(createContribution) withObject:nil];
    }
}

- (IBAction)doTogglePOI:(id)sender {
    if ([self.optionsDelegate respondsToSelector:@selector(togglePOI)]) {
        [self.optionsDelegate performSelector:@selector(togglePOI) withObject:nil];
    }
}

//- (void)setIsPOIVisible:(BOOL)POIVisible {
//    _isPOIVisible = POIVisible;
//}

- (IBAction)doDismiss:(id)sender {
    if ([self.optionsDelegate respondsToSelector:@selector(dismissOptions)]) {
        [self.optionsDelegate performSelector:@selector(dismissOptions) withObject:nil];
    }
}


@end
