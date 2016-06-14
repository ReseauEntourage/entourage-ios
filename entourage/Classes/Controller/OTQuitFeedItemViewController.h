//
//  OTQuitTourViewController.h
//  entourage
//
//  Created by Ciprian Habuc on 23/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTFeedItem.h"

@protocol OTFeedItemQuitDelegate <NSObject>

@required
- (void)didQuitFeedItem;

@end

@interface OTQuitFeedItemViewController : UIViewController

@property (nonatomic, strong) OTFeedItem *feedItem;
@property (nonatomic, weak) id<OTFeedItemQuitDelegate> feedItemQuitDelegate;

@end
