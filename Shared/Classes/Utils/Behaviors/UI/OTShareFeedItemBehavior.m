//
//  OTShareFeedItemBehavior.m
//  entourage
//
//  Created by sergiu.buceac on 06/04/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTShareFeedItemBehavior.h"
#import "OTConsts.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"
#import "OTActivityProvider.h"
#import "OTGroupSharingFormatter.h"
#import "entourage-Swift.h"
#import "OTPublicFeedItemViewController.h"
#import "OTChangeStateViewController.h"

@interface OTShareFeedItemBehavior ()

@property (nonatomic, strong) OTFeedItem *feedItem;
@property (nonatomic, strong) OTUser *currentUser;

@end

@implementation OTShareFeedItemBehavior

- (void)awakeFromNib {
    [super awakeFromNib];
    self.currentUser = [NSUserDefaults standardUserDefaults].currentUser;
}

- (void)configureWith:(OTFeedItem *)feedItem {
    self.feedItem = feedItem;
}

- (void)sharePublic:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard activeFeedsStoryboard];
    OTInviteSourceViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"OTShareNew"];
    
    if ([self.owner isKindOfClass:[OTPublicFeedItemViewController class]]) {
        vc.delegate = ((OTPublicFeedItemViewController*) self.owner).inviteBehavior;
    }
    else if([self.owner isKindOfClass:[OTChangeStateViewController class]]) {
        vc.delegate = ((OTChangeStateViewController*)self.owner);
    }
    
    vc.feedItem = self.feedItem;
    [self.owner presentViewController:vc animated:YES completion:nil];
}

- (void)shareMember:(id)sender {
    NSString *content = [OTGroupSharingFormatter groupShareText:(OTEntourage *)self.feedItem];
    [self share:content excludedActivities:nil];
}

#pragma mark - private methods

- (void)share:(NSString *)content excludedActivities:(NSArray*)excludedActivities {
    NSURL *url = [NSURL URLWithString:self.feedItem.shareUrl];
    OTActivityProvider *activity = [[OTActivityProvider alloc] initWithPlaceholderItem:@{@"body":content, @"url": url}];
    activity.emailBody = content;
    activity.emailSubject = @"";
    activity.url = url;
    NSArray *objectsToShare = @[activity];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    activityVC.excludedActivityTypes = excludedActivities;
    [OTAppConfiguration configureActivityControllerAppearance:activityVC
                                                        color:[[ApplicationTheme shared] primaryNavigationBarTintColor]];
    __weak id weakActivityVC = activityVC;
    activityVC.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        [OTAppConfiguration configureActivityControllerAppearance:weakActivityVC
                                                            color:[[ApplicationTheme shared] secondaryNavigationBarTintColor]];
    };
    activityVC.navigationController.navigationBar.tintColor = [[ApplicationTheme shared] primaryNavigationBarTintColor];
    [self.owner presentViewController:activityVC animated:YES completion:nil];
}

@end
