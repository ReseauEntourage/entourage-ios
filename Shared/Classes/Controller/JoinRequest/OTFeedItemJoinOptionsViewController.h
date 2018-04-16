//
//  OTFeedItemJoinOptionsViewController.h
//  entourage
//
//  Created by sergiu buceac on 9/12/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTFeedItem.h"
#import "OTTextView.h"

@interface OTFeedItemJoinOptionsViewController : UIViewController

@property (nonatomic, strong) OTFeedItem *feedItem;
@property (nonatomic, weak) IBOutlet UILabel *greetingLabel;
@property (nonatomic, weak) IBOutlet OTTextView *greetingMessage;

@end
