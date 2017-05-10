//
//  OTEncounterCell.h
//  entourage
//
//  Created by sergiu buceac on 8/8/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTChatCellBase.h"
#import "OTEditEncounterBehavior.h"

@interface OTEncounterCell : OTChatCellBase

@property (nonatomic, weak) IBOutlet UIButton *btnInfo;
@property (nonatomic, weak) IBOutlet OTEditEncounterBehavior *editEncounter;

- (IBAction)doEditEncounter;

@end
