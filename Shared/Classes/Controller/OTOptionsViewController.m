//
//  OTOptionsViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 30/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTOptionsViewController.h"
#import "OTOngoingTourService.h"
#import "OTAlertViewBehavior.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "entourage-Swift.h"

@interface OTOptionsViewController ()

@property (strong, nonatomic) IBOutlet OTAlertViewBehavior *actionAlert;

@end

@implementation OTOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addCloseButton];
    
    // Do any additional setup after loading the view.
    if (!CGPointEqualToPoint(self.fingerPoint, CGPointZero)) {
        [self setupOptionsAtFingerPoint];
    }
    else {
        [self setupOptionsAsList];
    }
    __weak typeof(self) weakSelf = self;
    [OTAlertViewBehavior setupOngoingCreateEntourageWithAction:self.actionAlert];
    [self.actionAlert addAction:OTLocalizedString(@"action") handler:^(UIAlertAction *action){
        if ([weakSelf.optionsDelegate respondsToSelector:@selector(createAction)])
            [weakSelf.optionsDelegate performSelector:@selector(createAction) withObject:nil];
    }];
    [self.actionAlert addAction:OTLocalizedString(@"encounter") handler:^(UIAlertAction *action){
        if ([weakSelf.optionsDelegate respondsToSelector:@selector(createEncounter)])
            [weakSelf.optionsDelegate performSelector:@selector(createEncounter) withObject:nil];
    }];
    
    self.togglePOILabel.textColor = [ApplicationTheme shared].backgroundThemeColor;
    
    [OTAppState hideTabBar:YES];
}

- (void)addCloseButton {
    CGFloat buttonSize = 62.0f;
    CGFloat buttomOffset = 102.0f;
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat x = [UIScreen mainScreen].bounds.size.width - PADDING_HORIZONTAL / 2 - buttonSize;
    CGFloat y = [UIScreen mainScreen].bounds.size.height - (PADDING_VERTICAL + buttonSize) - buttomOffset + buttonSize;
    
    closeButton.frame = CGRectMake(x, y, buttonSize, buttonSize);
    [closeButton setImage:[UIImage imageNamed:@"closeShadow"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(doDismiss:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
}

/*******************************************************************************/

#pragma mark - Show options at fingerPoint

- (void)setupOptionsAtFingerPoint {
    
    self.togglePOILabel.hidden = YES;
    self.togglePOIButton.hidden = YES;
    
    [self addOptionWithIcon:@"heatZoneFinger" andAction:nil withTranslation:CGPointZero];
}


/*******************************************************************************/

#pragma mark - Show options as a list

- (void)setupOptionsAsList {
    self.buttonIndex = 1;
}

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
    actionLabel.textColor = [ApplicationTheme shared].backgroundThemeColor;
    actionLabel.textAlignment = NSTextAlignmentRight;
    actionLabel.text = optionName;
    [self.view addSubview: actionLabel];
}

#pragma mark - Actions

- (IBAction)doCreateTour:(id)sender {
    [OTLogger logEvent:@"TourCreateClick"];
    [OTAppState hideTabBar:NO];
    if ([self.optionsDelegate respondsToSelector:@selector(createTour)]) {
        [self.optionsDelegate performSelector:@selector(createTour) withObject:nil];
    }
}

- (IBAction)doCreateEncounter:(id)sender {
    [OTAppState hideTabBar:NO];
    [OTLogger logEvent:@"CreateEncounterClick"];
    if ([self.optionsDelegate respondsToSelector:@selector(createEncounter)])
        [self.optionsDelegate performSelector:@selector(createEncounter) withObject:nil];
}

- (IBAction)doCreateAction:(id)sender {
    [OTAppState hideTabBar:NO];
    [OTLogger logEvent:@"CreateActionClick"];
    if ([OTOngoingTourService sharedInstance].isOngoing)
        [self.actionAlert presentOnViewController:self];
    else
        if ([self.optionsDelegate respondsToSelector:@selector(createAction)])
            [self.optionsDelegate performSelector:@selector(createAction) withObject:nil];
}

- (IBAction)doTogglePOI:(id)sender {
    [OTAppState hideTabBar:NO];
    if ([self.optionsDelegate respondsToSelector:@selector(togglePOI)]) {
        [self.optionsDelegate performSelector:@selector(togglePOI) withObject:nil];
    }
}

- (IBAction)proposeStructure:(id)sender {
    [OTAppState hideTabBar:NO];
    if ([self.optionsDelegate respondsToSelector:@selector(proposeStructure)]) {
        [self.optionsDelegate performSelector:@selector(proposeStructure) withObject:nil];
    }
}

- (void)addOptionWithIcon:(NSString *)optionIcon
                andAction:(SEL)selector
          withTranslation:(CGPoint)translationPoint

{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:optionIcon];
    
    button.frame = CGRectMake(self.fingerPoint.x - image.size.width/2 + translationPoint.x,
                              self.fingerPoint.y+10 + translationPoint.y,
                              image.size.width,
                              image.size.height);
    [button setImage:[UIImage imageNamed:optionIcon] forState:UIControlStateNormal];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}
- (IBAction)doDismiss:(id)sender {
    [OTAppState hideTabBar:NO];
    if ([self.optionsDelegate respondsToSelector:@selector(dismissOptions)]) {
        [self.optionsDelegate performSelector:@selector(dismissOptions) withObject:nil];
    }
}


@end
