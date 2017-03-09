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
#import "SVProgressHUD.h"

@interface OTOptionsViewController ()

@property (strong, nonatomic) IBOutlet OTAlertViewBehavior *demandeAlert;
@property (strong, nonatomic) IBOutlet OTAlertViewBehavior *contributionAlert;

@end

@implementation OTOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (!CGPointEqualToPoint(self.fingerPoint, CGPointZero)) {
        [self setupOptionsAtFingerPoint];
    } else {
        [self setupOptionsAsList];
    }
    __weak typeof(self) weakSelf = self;
    self.demandeAlert.title = OTLocalizedString(@"tour_ongoing");
    self.demandeAlert.content = [NSString stringWithFormat:OTLocalizedString(@"confirm_entourage_create"), OTLocalizedString(@"demande")];
    [self.demandeAlert addAction:OTLocalizedString(@"continue") delegate: ^(){
        if ([weakSelf.optionsDelegate respondsToSelector:@selector(createDemande)])
            [weakSelf.optionsDelegate performSelector:@selector(createDemande) withObject:nil];

    }];
    [self.demandeAlert addAction:OTLocalizedString(@"encounter") delegate: ^(){
        if ([weakSelf.optionsDelegate respondsToSelector:@selector(createEncounter)])
            [weakSelf.optionsDelegate performSelector:@selector(createEncounter) withObject:nil];
    }];
    self.contributionAlert.title = OTLocalizedString(@"tour_ongoing");
    self.contributionAlert.content = [NSString stringWithFormat:OTLocalizedString(@"confirm_entourage_create"), OTLocalizedString(@"contribution")];
    [self.contributionAlert addAction:OTLocalizedString(@"continue") delegate: ^(){
        if ([weakSelf.optionsDelegate respondsToSelector:@selector(createContribution)])
            [weakSelf.optionsDelegate performSelector:@selector(createContribution) withObject:nil];
    }];
    [self.contributionAlert addAction:OTLocalizedString(@"encounter") delegate: ^(){
        if ([weakSelf.optionsDelegate respondsToSelector:@selector(createEncounter)])
            [weakSelf.optionsDelegate performSelector:@selector(createEncounter) withObject:nil];
    }];
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
    
    if (self.isPOIVisible) {
        self.togglePOILabel.text = OTLocalizedString(@"map_options_hide_poi");
    } else {
        self.togglePOILabel.text = OTLocalizedString(@"map_options_show_poi");
    }
    self.buttonIndex = 1;
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
    [OTLogger logEvent:@"TourCreateClick"];
    if ([self.optionsDelegate respondsToSelector:@selector(createTour)]) {
        [self.optionsDelegate performSelector:@selector(createTour) withObject:nil];
    }
}

- (IBAction)doCreateEncounter:(id)sender {
    [OTLogger logEvent:@"CreateEncounterClick"];
    if ([self.optionsDelegate respondsToSelector:@selector(createEncounter)])
        [self.optionsDelegate performSelector:@selector(createEncounter) withObject:nil];
}

- (IBAction)doCreateDemande:(id)sender {
    [OTLogger logEvent:@"AskCreateClick"];
    if ([OTOngoingTourService sharedInstance].isOngoing)
        [self.demandeAlert show];
    else
        if ([self.optionsDelegate respondsToSelector:@selector(createDemande)])
            [self.optionsDelegate performSelector:@selector(createDemande) withObject:nil];
}

- (IBAction)doCreateContribution:(id)sender {
    [OTLogger logEvent:@"OfferCreateClick"];
    if ([OTOngoingTourService sharedInstance].isOngoing)
        [self.contributionAlert show];
    else
        if ([self.optionsDelegate respondsToSelector:@selector(createContribution)])
            [self.optionsDelegate performSelector:@selector(createContribution) withObject:nil];
}

- (IBAction)doTogglePOI:(id)sender {
    if ([self.optionsDelegate respondsToSelector:@selector(togglePOI)]) {
        [self.optionsDelegate performSelector:@selector(togglePOI) withObject:nil];
    }
}

- (void)addOptionWithIcon:(NSString *)optionIcon
                andAction:(SEL)selector
          withTranslation:(CGPoint)translationPoint

{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:optionIcon];
    
    button.frame = CGRectMake(self.fingerPoint.x - image.size.width/2 + translationPoint.x, self.fingerPoint.y+10 + translationPoint.y, image.size.width, image.size.height);
    [button setImage:[UIImage imageNamed:optionIcon] forState:UIControlStateNormal];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}
- (IBAction)doDismiss:(id)sender {
    if ([self.optionsDelegate respondsToSelector:@selector(dismissOptions)]) {
        [self.optionsDelegate performSelector:@selector(dismissOptions) withObject:nil];
    }
}


@end
