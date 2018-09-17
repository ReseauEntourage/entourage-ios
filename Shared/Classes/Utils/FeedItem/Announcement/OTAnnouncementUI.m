//
//  OTAnnouncementUI.m
//  entourage
//
//  Created by veronica.gliga on 03/11/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTAnnouncementUI.h"

@implementation OTAnnouncementUI

- (NSAttributedString *)descriptionWithSize:(CGFloat)size {
    NSAttributedString *typeAttrString = [[NSAttributedString alloc] initWithString:self.announcement.body attributes:@{NSFontAttributeName : [UIFont fontWithName:FONT_NORMAL_DESCRIPTION size:size]}];
    return typeAttrString;
}

- (NSString *)summary {
    return self.announcement.title;
}

- (NSString *)categoryIconSource {
    return self.announcement.icon_url;
}

- (NSString *)feedItemDescription {
    return self.announcement.body;
}

- (NSString *)feedItemActionButton {
    return self.announcement.action;
}

- (NSString *)contentImageUrl {
    return self.announcement.image_url;
}

@end
