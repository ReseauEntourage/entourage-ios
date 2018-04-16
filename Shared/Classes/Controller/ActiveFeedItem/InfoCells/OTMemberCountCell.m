//
//  OTMemberCountCell.m
//  entourage
//
//  Created by sergiu buceac on 10/12/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMemberCountCell.h"
#import "OTConsts.h"
#import "OTFeedItemJoiner.h"

@implementation OTMemberCountCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self updateLabel];
    [self.dataSource addTarget:self action:@selector(sourceChanged) forControlEvents:UIControlEventValueChanged];
}

- (void)dealloc {
    [self.dataSource removeTarget:self action:@selector(sourceChanged) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - private methods

- (void)sourceChanged {
    [self updateLabel];
}

- (void)updateLabel {
    NSArray *members = [self.dataSource.items filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^(id item, NSDictionary *bindings)  {
        return [item isKindOfClass:[OTFeedItemJoiner class]];
    }]];
    self.lblCount.text = [NSString stringWithFormat:OTLocalizedString(@"member_count"), members.count];
}

@end
