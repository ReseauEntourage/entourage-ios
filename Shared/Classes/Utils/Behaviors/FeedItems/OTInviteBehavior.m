//
//  OTInviteBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/6/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

@import AddressBook;
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
    [self.owner performSegueWithIdentifier:@"SegueInviteSource" sender:nil];
}

- (BOOL)prepareSegueForInvite:(UIStoryboardSegue *)segue {
    if ([segue.identifier isEqualToString:@"SegueInviteSource"]) {
        OTInviteSourceViewController *controller = (OTInviteSourceViewController *)segue.destinationViewController;
        controller.delegate = self;
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

- (void)inviteContacts {
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied || ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted) {
        [[[UIAlertView alloc] initWithTitle:OTLocalizedString(@"error") message:OTLocalizedString(@"addressBookDenied") delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        [self.owner performSegueWithIdentifier:@"SegueInviteFromAddressBook" sender:nil];
    } else {
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted)
                    return;
                [self.owner performSegueWithIdentifier:@"SegueInviteFromAddressBook" sender:nil];
            });
        });
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
