//
//  OTOptionsViewController.h
//  entourage
//
//  Created by Ciprian Habuc on 30/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTConsts.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"
#import "UIColor+entourage.h"

#define BUTTON_SIDE 48.0f
#define PADDING_VERTICAL 8.0f
#define PADDING_HORIZONTAL 16.0f
#define INITIAL_BOTTOM 82.0f

#define ACTION_LABEL_FRAME CGRectMake(0.0f, 0.0f, 230.0f, 21.0f)

#define NORTH_WEST CGPointMake(-50.f, -30.f)
#define NORTH      CGPointMake(  0.f, -65.f)
#define NORTH_EAST CGPointMake(+50.f, -30.f)

@protocol OTOptionsDelegate <NSObject>

- (void)createTour;
- (void)createEncounter;
- (void)createDemande;
- (void)createContribution;

- (void)togglePOI;
- (void)dismissOptions;

@end


@interface OTOptionsViewController : UIViewController

@property (nonatomic, weak) id<OTOptionsDelegate> optionsDelegate;
@property (nonatomic, assign) CGPoint fingerPoint;


@property (nonatomic, weak) IBOutlet UIButton *togglePOIButton;
@property (nonatomic, weak) IBOutlet UILabel *togglePOILabel;
@property (nonatomic) int buttonIndex;

@property (nonatomic) BOOL isPOIVisible;

//- (void)setIsPOIVisible:(BOOL)isPOIVisible;

- (void)setupOptionsAtFingerPoint;
- (void)setupOptionsAsList;

- (void)addOption:(NSString *)optionName
          atIndex:(int)index
         withIcon:(NSString *)optionIcon
        andAction:(SEL)selector;

- (void)addOptionWithIcon:(NSString *)optionIcon
                andAction:(SEL)selector
          withTranslation:(CGPoint)point;

- (IBAction)doCreateTour:(id)sender;
- (IBAction)doCreateEncounter:(id)sender;
- (IBAction)doCreateDemande:(id)sender;
- (IBAction)doCreateContribution:(id)sender;
- (IBAction)doTogglePOI:(id)sender;

@end
