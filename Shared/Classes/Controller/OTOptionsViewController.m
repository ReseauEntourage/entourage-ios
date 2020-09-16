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
#import "OTHTTPRequestManager.h"

@interface OTOptionsViewController ()

@property (strong, nonatomic) IBOutlet OTAlertViewBehavior *actionAlert;

@end

@implementation OTOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.isNewOptions) {
        [self addCloseButton];
    }
    
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
    [OTAppConfiguration configureNavigationControllerAppearance:self.navigationController];
}

- (void)addCloseButton {
    CGFloat buttonSize = 62.0f;
    CGFloat buttomOffset = 112.0f;
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat x = [UIScreen mainScreen].bounds.size.width - PADDING_HORIZONTAL / 2 - buttonSize - 2;
    CGFloat y = [UIScreen mainScreen].bounds.size.height - (PADDING_VERTICAL + buttonSize) - buttomOffset + buttonSize;
    
    closeButton.frame = CGRectMake(x, y, buttonSize, buttonSize);
    [closeButton setImage:[[UIImage imageNamed:@"closeOptionWithShadow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    closeButton.tintColor = [ApplicationTheme shared].backgroundThemeColor;
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
   applyTintColor:(BOOL)applyTintColor
        andAction:(SEL)selector
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat x = [UIScreen mainScreen].bounds.size.width - PADDING_HORIZONTAL - BUTTON_SIDE;
    CGFloat y = [UIScreen mainScreen].bounds.size.height - (index)*(PADDING_VERTICAL + BUTTON_SIDE) - INITIAL_BOTTOM;
    
    button.frame = CGRectMake(x, y, BUTTON_SIDE, BUTTON_SIDE);
    [button setImage:[UIImage imageNamed:optionIcon] forState:UIControlStateNormal];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    button.clipsToBounds = YES;
    
    if (applyTintColor) {
        UIImage *tintImage = [[UIImage imageNamed:optionIcon] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [button setImage:tintImage forState:UIControlStateNormal];
        button.tintColor = [ApplicationTheme shared].backgroundThemeColor;
    }
    
    UILabel *actionLabel = [[UILabel alloc] init];
    actionLabel.frame = ACTION_LABEL_FRAME;
    actionLabel.center = CGPointMake(button.center.x - actionLabel.frame.size.width/2.0f - PADDING_HORIZONTAL/2.0f - button.frame.size.width/2.0f, button.center.y);
    actionLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    actionLabel.textColor = [ApplicationTheme shared].backgroundThemeColor;
    actionLabel.textAlignment = NSTextAlignmentRight;
    actionLabel.text = optionName;
    [self.view addSubview: actionLabel];
}

- (void)addOption:(NSString *)optionName
          atIndex:(int)index
         withIcon:(NSString *)optionIcon
        andAction:(SEL)selector
{
    return [self addOption:optionName atIndex:index withIcon:optionIcon applyTintColor:NO andAction:selector];
}

//Custom button orange color + round
- (void)addOption:(NSString *)optionName
          atIndex:(int)index
         withIconWithoutBG:(NSString *)optionIcon
        andAction:(SEL)selector
          andSubtitle:(NSString *) optionSubtitle
{
    //Fix bottom margin for iPhone 5/5s/SE and iPhone 6/7/8
    float initial_bottom = INITIAL_BOTTOM;
    
    if ([[UIScreen mainScreen] bounds].size.height == 568) {
        initial_bottom = INITIAL_BOTTOM_SMALL;
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 667) {
        initial_bottom = INITIAL_BOTTOM_MEDIUM;
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat x = [UIScreen mainScreen].bounds.size.width - PADDING_HORIZONTAL - BIG_BUTTON_SIDE;
    CGFloat y = [UIScreen mainScreen].bounds.size.height - (index)*(PADDING_VERTICAL + BIG_BUTTON_SIDE) - initial_bottom;
    
    button.frame = CGRectMake(x, y, BIG_BUTTON_SIDE, BIG_BUTTON_SIDE);
    button.layer.cornerRadius = button.frame.size.width / 2;
    button.backgroundColor = [UIColor colorWithDisplayP3Red:245 / 255.0 green:95 / 255.0 blue:36 / 255.0 alpha:1.0];
    [button setImage:[UIImage imageNamed:optionIcon] forState:UIControlStateNormal];
    [self.view addSubview:button];
    button.clipsToBounds = YES;
    
    //Add button screen width size to action
    UIButton *buttonBig = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonBig.frame = CGRectMake(PADDING_HORIZONTAL, y, [UIScreen mainScreen].bounds.size.width - (PADDING_HORIZONTAL * 2), BIG_BUTTON_SIDE);
    buttonBig.backgroundColor = [UIColor colorWithDisplayP3Red:100 / 255.0 green:100 / 255.0 blue:100 / 255.0 alpha:0.0];
    [buttonBig addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonBig];

    float diffForSub = optionSubtitle.length > 0 ? ACTION_LABEL_HEIGHT / 2 : 0;
    UILabel *actionLabel = [[UILabel alloc] init];
    actionLabel.frame = ACTION_LABEL_FRAME;
    actionLabel.center = CGPointMake(button.center.x - actionLabel.frame.size.width/2.0f - PADDING_HORIZONTAL/2.0f - button.frame.size.width/2.0f, button.center.y - diffForSub);
    actionLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBold];
    actionLabel.textColor = [ApplicationTheme shared].backgroundThemeColor;
    actionLabel.textAlignment = NSTextAlignmentRight;
    actionLabel.text = optionName;
    
    [self.view addSubview: actionLabel];
    
    if (diffForSub > 0) {
        UILabel *actionLabelSub = [[UILabel alloc] init];
        actionLabelSub.frame = ACTION_LABEL_SUB_FRAME;
        actionLabelSub.center = CGPointMake(button.center.x - actionLabelSub.frame.size.width/2.0f - PADDING_HORIZONTAL/2.0f - button.frame.size.width/2.0f, actionLabel.center.y + actionLabelSub.frame.size.height);
        actionLabelSub.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
        actionLabelSub.textColor = [UIColor appGreyishBrownColor];
        actionLabelSub.textAlignment = NSTextAlignmentRight;
        actionLabelSub.text = optionSubtitle;
        
        [self.view addSubview: actionLabelSub];
    }
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

- (IBAction)doCreateActionHelp:(id)sender {
    [OTAppState hideTabBar:NO];
    [OTLogger logEvent:@"CreateActionClick"];
    if ([OTOngoingTourService sharedInstance].isOngoing)
        [self.actionAlert presentOnViewController:self];
    else
        if ([self.optionsDelegate respondsToSelector:@selector(createActionHelp)])
            [self.optionsDelegate performSelector:@selector(createActionHelp) withObject:nil];
}

- (IBAction)doCreateActionGift:(id)sender {
    [OTAppState hideTabBar:NO];
    [OTLogger logEvent:@"CreateActionClick"];
    if ([OTOngoingTourService sharedInstance].isOngoing)
        [self.actionAlert presentOnViewController:self];
    else
        if ([self.optionsDelegate respondsToSelector:@selector(createActionGift)])
            [self.optionsDelegate performSelector:@selector(createActionGift) withObject:nil];
}
    
- (IBAction)doCreateEvent:(id)sender {
    [OTAppState hideTabBar:NO];
    [OTLogger logEvent:@"CreateEventClick"];
    [self.optionsDelegate performSelector:@selector(createEvent) withObject:nil];
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
    return [self addOptionWithIcon:optionIcon applyTintColor:NO
                         andAction:selector withTranslation:translationPoint];
}
    
- (void)addOptionWithIcon:(NSString *)optionIcon
           applyTintColor:(BOOL)applyTintColor
                andAction:(SEL)selector
          withTranslation:(CGPoint)translationPoint

{
    return [self addOptionWithIcon:optionIcon
                         tintColor:[ApplicationTheme shared].backgroundThemeColor
                         andAction:selector
                   withTranslation:translationPoint];
}
    
- (void)addOptionWithIcon:(NSString *)optionIcon
           tintColor:(UIColor*)tintColor
                andAction:(SEL)selector
          withTranslation:(CGPoint)translationPoint

{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:optionIcon];
    button.clipsToBounds = YES;
    
    if (tintColor) {
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        button.tintColor = tintColor;
    }
    
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
