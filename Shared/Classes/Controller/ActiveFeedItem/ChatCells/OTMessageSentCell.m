//
//  OTMessageSentCell.m
//  entourage
//
//  Created by sergiu buceac on 8/7/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMessageSentCell.h"
#import "OTFeedItemMessage.h"
#import "NSDate+OTFormatter.h"

@implementation OTMessageSentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.txtMessage.linkTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
}

- (void)configureWithTimelinePoint:(OTFeedItemTimelinePoint *)timelinePoint {
    OTFeedItemMessage *msgData = (OTFeedItemMessage *)timelinePoint;
    self.txtMessage.text = msgData.text;
    self.time.text = [timelinePoint.date toTimeString];
    
    if ([((OTFeedItemMessage*)timelinePoint).itemType isEqualToString:@"poi"]) {
        self.isPOI = YES;
        NSString * poiIdString = ((OTFeedItemMessage*)timelinePoint).itemUuid;
        
        NSNumber *poiId = [NSNumber numberWithInt:[poiIdString intValue]];
        
        self.poiId = poiId;
    }
}

- (IBAction)action_show_link:(id)sender {
    if (self.isPOI) {
        [[OTDeepLinkService new] showDetailPoiViewControllerWithId:self.poiId];
    }
}

-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    
    if (self.isPOI) {
        [[OTDeepLinkService new] showDetailPoiViewControllerWithId:self.poiId];
        
        return false;
    }
    
    return [super textView:textView shouldInteractWithURL:URL inRange:characterRange];
}

@end
