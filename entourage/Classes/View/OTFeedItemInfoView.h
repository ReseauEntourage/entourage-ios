//
//  OTFeedItemInfoView.h
//  entourage
//
//  Created by Ciprian Habuc on 21/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTFeedItem.h"
#import <MapKit/MapKit.h>

@protocol OTFeedItemInfoDelegate <NSObject>

- (void)doJoinTour;

@end

@interface OTFeedItemInfoView : UIView <MKMapViewDelegate>

@property (nonatomic, weak) id<OTFeedItemInfoDelegate> delegate;

- (void)setupWithFeedItem:(OTFeedItem *)feedItem;

@end
