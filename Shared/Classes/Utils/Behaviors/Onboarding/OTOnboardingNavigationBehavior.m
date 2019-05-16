//
//  OTOnboardingNavigationBehavior.m
//  entourage
//
//  Created by sergiu buceac on 9/2/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTOnboardingNavigationBehavior.h"
#import "NSUserDefaults+OT.h"
#import "OTUser.h"
#import "OTAppState.h"

@interface OTOnboardingNavigationBehavior ()

@property (nonatomic, strong) OTUser *currentUser;

@end

@implementation OTOnboardingNavigationBehavior

- (void)awakeFromNib {
    [super awakeFromNib];
    self.currentUser = [NSUserDefaults standardUserDefaults].currentUser;
}

- (void)nextFromEmail {
    [OTAppState continueFromUserEmailScreen:self.owner];
}

- (void)nextFromName {
    [OTAppState continueFromUserNameScreen:self.owner];
}

@end
