//
//  OTHeatzonesCollectionSource.h
//  entourage
//
//  Created by Veronica Gliga on 14/09/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTCollectionViewDataSourceBehavior.h"

@class OTFeedItem;

@protocol OTHeatzonesCollectionViewDelegate <NSObject>

- (void)showFeedInfo:(OTFeedItem*)feedItem;

@end


@interface OTHeatzonesCollectionSource : OTCollectionViewDataSourceBehavior

@property (nonatomic, weak) id<OTHeatzonesCollectionViewDelegate> heatzonesDelegate;


@end
