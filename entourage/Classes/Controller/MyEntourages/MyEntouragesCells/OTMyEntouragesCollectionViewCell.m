//
//  OTMyEntouragesCollectionViewCell.m
//  entourage
//
//  Created by sergiu buceac on 8/9/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMyEntouragesCollectionViewCell.h"

@implementation OTMyEntouragesCollectionViewCell

-(void)configureWith:(OTEntourageInvitation *)invitation {
    self.lblUserName.text = invitation.inviter.displayName;
}

@end
