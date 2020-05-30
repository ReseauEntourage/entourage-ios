//
//  OTMembersCell.m
//  entourage
//
//  Created by sergiu buceac on 8/25/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEventInfoCell.h"
#import "UIButton+entourage.h"
#import "OTTableDataSourceBehavior.h"
#import "UIImageView+entourage.h"
#import "OTFeedItemFactory.h"
#import "OTTapViewBehavior.h"
#import "entourage-Swift.h"

@implementation OTEventInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];

  self.lblLocation.enabledTextCheckingTypes = NSTextCheckingTypeAddress;
  self.lblLocation.delegate = self;
  self.lblLocation.textColor = [ApplicationTheme shared].titleLabelColor;
  self.lblLocation.linkAttributes = @{
     NSFontAttributeName:            [UIFont fontWithName:@"SFUIText-Bold" size:15.0],
     NSForegroundColorAttributeName: [ApplicationTheme shared].addActionButtonColor,
     NSUnderlineColorAttributeName:  [ApplicationTheme shared].addActionButtonColor,
     NSUnderlineStyleAttributeName:  [NSNumber numberWithInt:NSUnderlineStyleSingle]
  };
}

- (void)configureWith:(OTFeedItem *)item {
    self.lblAuthorPrefix.text = @"Organisé par ";
    self.lblAuthorInfo.text = [[[OTFeedItemFactory createFor:item] getUI] userName];
    if (item.startsAt) {
        self.lblInfo.text = [[[OTFeedItemFactory createFor:item] getUI] eventInfoDescription];
        self.lblLocation.text = [[[OTFeedItemFactory createFor:item] getUI] eventInfoLocation];
        if ([self.lblLocation.text isEqualToString:@"Visioconférence en ligne"]) {
            NSRange range = NSMakeRange(0, [self.lblLocation.text length]);
            [self.lblLocation addLinkToURL:[[[OTFeedItemFactory createFor:item] getUI] eventOnlineURL] withRange:range];
        }
    }
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithAddress:(NSDictionary *)addressComponents {
  NSString *string = [NSString stringWithFormat:@"http://maps.apple.com/?address=1,%@ %@ %@",
                      addressComponents[NSTextCheckingStreetKey],
                      addressComponents[NSTextCheckingZIPKey],
                      addressComponents[NSTextCheckingCityKey]];
  NSURL *url = [NSURL URLWithString:[string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];

  [[UIApplication sharedApplication] openURL:url];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
  [[UIApplication sharedApplication] openURL:url];
}

@end
