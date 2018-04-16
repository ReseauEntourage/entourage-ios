//
//  OTTourFactory.h
//  entourage
//
//  Created by sergiu buceac on 6/14/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTFeedItemFactoryDelegate.h"
#import "OTFeedItemFactory.h"
#import "OTTour.h"

@interface OTTourFactory : OTFeedItemFactory<OTFeedItemFactoryDelegate>

@property (nonatomic, strong) OTTour *tour;

- (id)initWithTour:(OTTour *)tour;

@end
