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
@property (nonatomic, assign) BOOL hasPreLoginUser;

@end

@implementation OTOnboardingNavigationBehavior

- (void)awakeFromNib {
    [super awakeFromNib];
    self.currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    self.preLoginUser = nil;
    self.hasPreLoginUser = NO;
}

- (void)nextFromEmail {
    [OTAppState continueFromUserEmailScreen:self.owner];
}

- (void)nextFromName {
    [OTAppState continueFromUserNameScreen:self.owner];
}

- (void)setPreLoginUser:(OTUser *)preLoginUser {
    self.hasPreLoginUser = YES;
    _preLoginUser = preLoginUser;
}

@end
