//
//  OTAnnouncement.h
//  entourage
//
//  Created by veronica.gliga on 02/11/2017.
//  Copyright © 2017 Entourage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTFeedItem.h"

@interface OTAnnouncement : OTFeedItem

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSString *action;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *icon_url;
@property (nonatomic, strong) NSString *image_url;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary;

@end
