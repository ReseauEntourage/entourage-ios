//
//  OTEntourageFactory.h
//  entourage
//
//  Created by sergiu buceac on 6/14/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTFeedItemFactoryDelegate.h"
#import "OTFeedItemFactory.h"
#import "OTEntourage.h"

@interface OTEntourageFactory : OTFeedItemFactory<OTFeedItemFactoryDelegate>

@property (nonatomic, strong) OTEntourage *entourage;

- (id)initWithEntourage:(OTEntourage *)entourage;

@end
