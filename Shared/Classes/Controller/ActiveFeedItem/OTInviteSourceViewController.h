//
//  OTInviteSourceViewController.h
//  entourage
//
//  Created by sergiu buceac on 7/28/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InviteSourceDelegate <NSObject>

- (void)inviteContactsFromViewController:(UIViewController*)viewController;
- (void)inviteByPhone;
- (void)share;
- (void)shareEntourage;

@end

@protocol InviteSuccessDelegate <NSObject>

- (void)didInviteWithSuccess;

@end

@interface OTInviteSourceViewController : UIViewController

@property(nonatomic, weak) IBOutlet UIView *popupContainerView;
@property(nonatomic, weak) IBOutlet UILabel *inviteSubtitleLabel;
@property(nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@property(nonatomic) IBOutletCollection(UIImageView) NSArray *icons;
@property(nonatomic, weak) id<InviteSourceDelegate> delegate;
@property(nonatomic) OTFeedItem *feedItem;

@end
