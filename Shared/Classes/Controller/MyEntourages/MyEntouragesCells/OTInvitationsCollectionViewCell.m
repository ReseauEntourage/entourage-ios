//
//  OTInvitationsCollectionViewCell.m
//  entourage
//
//  Created by sergiu buceac on 8/9/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTInvitationsCollectionViewCell.h"

@implementation OTInvitationsCollectionViewCell

-(void)configureWith:(OTEntourageInvitation *)invitation {
    self.lblUserName.text = [NSString stringWithFormat:[OTLocalisationService getLocalizedValueForKey:@"invit_entourage_title"],invitation.inviter.displayName];
    
    self.ui_label_entourage_name.text = invitation.title == nil ? [OTLocalisationService getLocalizedValueForKey:@"invit_entourage_description_empty"] : invitation.title ;
}

@end
