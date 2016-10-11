//
//  OTEditEntourageBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/31/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEditEntourageBehavior.h"
#import "OTEntourageEditorViewController.h"
#import "OTFeedItemFactory.h"
#import "OTConsts.h"

@interface OTEditEntourageBehavior () <EntourageEditorDelegate>

@property (nonatomic, strong) OTEntourage *entourage;

@end

@implementation OTEditEntourageBehavior

- (void)doEdit:(OTEntourage *)entourage {
    self.entourage = entourage;
    [self.owner performSegueWithIdentifier:@"EntourageEditorSegue" sender:self];
}

- (BOOL)prepareSegue:(UIStoryboardSegue *)segue {
    if([segue.identifier isEqualToString:@"EntourageEditorSegue"]) {
        UINavigationController *navController = segue.destinationViewController;
        OTEntourageEditorViewController *controller = (OTEntourageEditorViewController *)navController.topViewController;
        controller.entourage = self.entourage;
        controller.entourageEditorDelegate = self;
    }
    else
        return NO;
    return YES;
}

#pragma mark - EntourageEditorDelegate

- (void)didEditEntourage:(OTEntourage *)entourage {
    [[[OTFeedItemFactory createFor:self.entourage] getChangedHandler] updateWith:entourage];
    NSDictionary* notificationInfo = @{ kNotificationEntourageChangedEntourageKey: self.entourage };
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationEntourageChanged object:nil userInfo:notificationInfo];
    [self.owner dismissViewControllerAnimated:YES completion:nil];
}

@end
