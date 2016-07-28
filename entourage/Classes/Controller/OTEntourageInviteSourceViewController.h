//
//  OTEntourageInviteSourceViewController.h
//  entourage
//
//  Created by sergiu buceac on 7/28/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InviteSourceDelegate <NSObject>

- (void)inviteContacts;
- (void)inviteByPhone;

@end

@interface OTEntourageInviteSourceViewController : UIViewController

@property(nonatomic, weak) id<InviteSourceDelegate> delegate;

@end
