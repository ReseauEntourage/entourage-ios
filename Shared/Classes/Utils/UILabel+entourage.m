//
//  UILabel+entourage.m
//  entourage
//
//  Created by Ciprian Habuc on 22/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "UILabel+entourage.h"
#import "OTFeedItemAuthor.h"
#import "OTTourPoint.h"
#import "UIColor+entourage.h"
#import "OTConsts.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"
#import "OTFeedItem.h"
#import "OTFeedItemFactory.h"


@implementation UILabel (entourage)

- (void)underline {
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    self.attributedText = [[NSAttributedString alloc] initWithString:self.text attributes:underlineAttribute];
}

@end
