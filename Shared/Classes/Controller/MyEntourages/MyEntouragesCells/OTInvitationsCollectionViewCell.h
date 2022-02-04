//
//  OTInvitationsCollectionViewCell.h
//  entourage
//
//  Created by sergiu buceac on 8/9/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTEntourageInvitation.h"

@interface OTInvitationsCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UILabel *ui_label_entourage_name;

- (void)configureWith:(OTEntourageInvitation *)invitation;

@end
