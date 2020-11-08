//
//  OTMessageSentCell.h
//  entourage
//
//  Created by sergiu buceac on 8/7/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTChatCellBase.h"

@interface OTMessageSentCell : OTChatCellBase

@property (nonatomic, weak) IBOutlet UITextView *txtMessage;
@property (nonatomic, weak) IBOutlet UILabel *time;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ui_constraint_width_img_link;
@property(nonatomic) BOOL isPOI;
@property(nonatomic) NSNumber *poiId;
@property(nonatomic) CGFloat constraintWidth;
@end
