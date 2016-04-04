//
//  OTEntouragesViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 26/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntouragesViewController.h"
#import "UIViewController+menu.h"
#import "OTTourService.h"
#import "NSUserDefaults+OT.h"

#define STATUS_OPEN @"open"
#define STATUS_FREEZED @"freezed"
#define STATUS_CLOSED @"closed"


typedef NS_ENUM(NSInteger){
    EntourageStatusOpen,
    EntourageStatusFreezed,
    EntourageStatusClosed
} EntourageStatus;

@interface OTEntouragesViewController()

@property (nonatomic, weak) IBOutlet UISegmentedControl *statusSC;

@end


@implementation OTEntouragesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"MES ENTOURAGES";
    [self setupCloseModal];
    
//    [self.statusSC setSelectedSegmentIndex:EntourageStatusOpen];
}

- (void)viewDidAppear:(BOOL)animated {
     [self.statusSC setSelectedSegmentIndex:EntourageStatusClosed];
}

/**************************************************************************************************/
#pragma mark - Private

- (void)getEntouragesWithStatus:(NSInteger) entourageStatus {
    NSString *statusString = STATUS_OPEN;
    
    switch (entourageStatus) {
        case EntourageStatusOpen:
            statusString = STATUS_OPEN;
            break;
        case EntourageStatusFreezed:
            statusString = STATUS_FREEZED;
            break;
        case EntourageStatusClosed:
            statusString = STATUS_CLOSED;
            break;
            
        default:
            break;
    }
    
    NSLog(@"getting entourages with status %@ ...", statusString);
    [[OTTourService new] entouragesWithStatus:statusString
                                      success:^(NSArray *encounters) {
            
                                      } failure:^(NSError *error) {
            
                                      }
     ];
}

- (IBAction)changedSegmentedControlSelection:(UISegmentedControl *)segControl {
    [self getEntouragesWithStatus:segControl.selectedSegmentIndex];
}

@end
