//
//  OTInviteBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/6/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

@import Contacts;
#import "OTInviteBehavior.h"
#import "OTConsts.h"
#import "OTInviteContactsViewController.h"
#import "OTInviteByPhoneViewController.h"

@interface OTInviteBehavior ()

@property (nonatomic, strong) OTFeedItem *feedItem;

@end

@implementation OTInviteBehavior

- (void)configureWith:(OTFeedItem *)feedItem {
    self.feedItem = feedItem;
}

- (void)startInvite {
    [OTLogger logEvent:@"InviteFriendsClick"];
    
    [OTAppState launchInviteActionForFeedItem:self.feedItem
                               fromController:self.owner
                                     delegate:self];
}

- (BOOL)prepareSegueForInvite:(UIStoryboardSegue *)segue {
    if ([segue.identifier isEqualToString:@"SegueInviteSource"]) {
        OTInviteSourceViewController *controller = (OTInviteSourceViewController *)segue.destinationViewController;
        controller.delegate = self;
        controller.feedItem = self.feedItem;
    }
    else if ([segue.identifier isEqualToString:@"SegueInviteFromAddressBook"]) {
        OTInviteContactsViewController *controller = (OTInviteContactsViewController *)segue.destinationViewController;
        controller.feedItem = self.feedItem;
        controller.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"SegueInvitePhoneNumber"]) {
        OTInviteByPhoneViewController *controller = (OTInviteByPhoneViewController *)segue.destinationViewController;
        controller.feedItem = self.feedItem;
        controller.delegate = self;
    } else
        return NO;
    return YES;
}

#pragma mark - InviteSourceDelegate implementation

- (void)inviteContactsFromViewController:(UIViewController *)viewController {
    CNAuthorizationStatus authorizationStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (authorizationStatus == CNAuthorizationStatusDenied || authorizationStatus == CNAuthorizationStatusRestricted) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:OTLocalizedString(@"error")
                                                                                 message:OTLocalizedString(@"addressBookDenied")
                                                                          preferredStyle:UIAlertControllerStyleAlert];

        [alertController addAction:[UIAlertAction actionWithTitle:OTLocalizedString(@"OK") style:UIAlertActionStyleDefault handler:nil]];
        [viewController presentViewController:alertController animated:YES completion:nil];
    } else if (authorizationStatus == CNAuthorizationStatusAuthorized) {
        [self.owner performSegueWithIdentifier:@"SegueInviteFromAddressBook" sender:nil];
    } else {
        CNContactStore *store = [[CNContactStore alloc] init];
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError *__nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted)
                    return;
                [self.owner performSegueWithIdentifier:@"SegueInviteFromAddressBook" sender:nil];
            });
        }];
    }
}

- (void)inviteByPhone {
    [self.owner performSegueWithIdentifier:@"SegueInvitePhoneNumber" sender:nil];
}

- (void)share {
    [self.shareBehavior configureWith:self.feedItem];
    [self.shareBehavior shareMember:nil];
}

#pragma mark - InviteSuccessDelegate implementation

- (void)didInviteWithSuccess {
    [self.owner performSegueWithIdentifier:@"SegueInviteSuccess" sender:nil];
}

@end
