//
//  OTEncounterCell.h
//  entourage
//
//  Created by sergiu buceac on 8/8/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTChatCellBase.h"
#import "OTEditEncounterBehavior.h"
#import "OTFeedItem.h"

@interface OTEncounterCell : OTChatCellBase

@property (nonatomic, weak) IBOutlet UIButton *btnInfo;
@property (nonatomic, weak) IBOutlet OTEditEncounterBehavior *editEncounter;
@property (nonatomic, strong) OTFeedItem *feedItem;

- (IBAction)doEditEncounter;

@end
