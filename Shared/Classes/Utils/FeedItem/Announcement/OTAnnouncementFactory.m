//
//  OTAnnouncementFactory.m
//  entourage
//
//  Created by veronica.gliga on 03/11/2017.
//  Copyright © 2017 Entourage. All rights reserved.
//

#import "OTAnnouncementFactory.h"
#import "OTAnnouncementUI.h"

@implementation OTAnnouncementFactory

- (id)initWithAnnouncement:(OTAnnouncement *)announcement {
    self = [super init];
    if (self)
    {
        self.announcement = announcement;
    }
    return self;
}

- (id<OTUIDelegate>)getUI {
    return [[OTAnnouncementUI alloc] initWithAnnouncement:self.announcement];
}

@end
