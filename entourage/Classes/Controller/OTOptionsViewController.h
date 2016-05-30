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


- (void)addOption:(NSString *)optionName
          atIndex:(int)index
         withIcon:(NSString *)optionIcon
        andAction:(SEL)selector;


- (IBAction)doCreateTour:(id)sender;
- (IBAction)doCreateEncounter:(id)sender;
- (IBAction)doCreateDemande:(id)sender;
- (IBAction)doCreateContribution:(id)sender;
- (IBAction)doTogglePOI:(id)sender;

@end
