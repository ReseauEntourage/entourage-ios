//
//  OTMemberCountCell.m
//  entourage
//
//  Created by sergiu buceac on 10/12/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMemberCountCell.h"
#import "OTConsts.h"

@implementation OTMemberCountCell

- (IBAction)itemsChanged:(id)sender {
    self.lblCount.text = [NSString stringWithFormat:OTLocalizedString(@"member_count"), self.dataSource.items.count];
}

@end
