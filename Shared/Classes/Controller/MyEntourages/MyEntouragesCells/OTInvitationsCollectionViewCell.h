//
//  OTInvitationsCollectionViewCell.h
//  entourage
//
//  Created by sergiu buceac on 8/9/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTEntourageInvitation.h"

@interface OTInvitationsCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblUserName;

- (void)configureWith:(OTEntourageInvitation *)invitation;

@end
