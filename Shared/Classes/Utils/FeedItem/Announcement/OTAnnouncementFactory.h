//
//  OTAnnouncementFactory.h
//  entourage
//
//  Created by veronica.gliga on 03/11/2017.
//  Copyright © 2017 Entourage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTFeedItemFactoryDelegate.h"
#import "OTFeedItemFactory.h"
#import "OTAnnouncement.h"

@interface OTAnnouncementFactory : OTFeedItemFactory<OTFeedItemFactoryDelegate>

@property (nonatomic, strong) OTAnnouncement *announcement;

- (id)initWithAnnouncement:(OTAnnouncement *)announcement;

@end
