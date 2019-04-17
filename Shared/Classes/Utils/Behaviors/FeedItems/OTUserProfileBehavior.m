//
//  OTUserProfileBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/12/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTUserProfileBehavior.h"
#import "OTUserViewController.h"
#import "NSUserDefaults+OT.h"
#import "OTUser.h"

@interface OTUserProfileBehavior ()

@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, strong) OTUser *currentUser;

@end

@implementation OTUserProfileBehavior

- (void)awakeFromNib {
    [super awakeFromNib];
    self.currentUser = [NSUserDefaults standardUserDefaults].currentUser;
}

- (void)showProfile:(NSNumber *)userId {
    self.userId = userId;
    [self.owner performSegueWithIdentifier:@"UserProfileSegue" sender:self];
}

- (BOOL)prepareSegueForUserProfile:(UIStoryboardSegue *)segue {
    if([segue.identifier isEqualToString:@"UserProfileSegue"]) {
        UINavigationController *controller = (UINavigationController *)segue.destinationViewController;
        OTUserViewController * userController = (OTUserViewController *)controller.topViewController;
        if(!self.currentUser.isAnonymous && [self.userId isEqualToNumber:self.currentUser.sid])
            userController.user = self.currentUser;
        else
            userController.userId = self.userId;
    }
    else
        return NO;
    return YES;
}

@end
