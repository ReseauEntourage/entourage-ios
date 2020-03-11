//
//  OTChatCellBase.m
//  entourage
//
//  Created by sergiu buceac on 8/7/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTChatCellBase.h"

@implementation OTChatCellBase

- (void)configureWithTimelinePoint:(OTFeedItemTimelinePoint *)timelinePoint {
}

-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([OTDeepLinkService isUniversalLink:URL]) {
        [[OTDeepLinkService new] handleUniversalLink:URL];
        return NO;
    }
    return YES;
}

@end
