//
//  OTAnnouncementCell.m
//  entourage
//
//  Created by veronica.gliga on 02/11/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTAnnouncementCell.h"
#import "OTFeedItemFactory.h"
#import "UIButton+entourage.h"
#import "OTSummaryProviderBehavior.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/SDImageCache.h>
#import "entourage-Swift.h"

NSString* const OTAnnouncementTableViewCellIdentifier = @"OTAnnouncementTableViewCellIdentifier";

@interface OTAnnouncementCell ()

@property (nonatomic, strong) OTFeedItem *feedItem;

@end

@implementation OTAnnouncementCell

- (void)configureWith:(OTFeedItem *) item completion:(void(^)(void))completion {
    if (self.feedItem == item) return;

    self.feedItem = item;
    OTSummaryProviderBehavior *summaryBehavior = [OTSummaryProviderBehavior new];
    summaryBehavior.imgCategory = self.iconImage;
    [summaryBehavior configureWith:item];
    
    id<OTUIDelegate> uiDelegate = [[OTFeedItemFactory createFor:item] getUI];
    self.titleLabel.text = [uiDelegate summary];
    self.descriptionLabel.text = [uiDelegate feedItemDescription];
    
    if (uiDelegate.contentImageUrl) {
        NSURL *url = [NSURL URLWithString:uiDelegate.contentImageUrl];
        self.contentImageHeightConstraint.constant = 160;
        [self.contentImageView sd_setImageWithURL:url
                                 placeholderImage:[UIImage imageNamed:@"announcementCardPlaceholder"]
                                          options: SDWebImageAvoidAutoSetImage
                                        completed:
            ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (cacheType == SDImageCacheTypeNone) {
                    [UIView transitionWithView:self.contentImageView
                                      duration:0.2
                                       options:UIViewAnimationOptionTransitionCrossDissolve
                                    animations:^{
                                        self.contentImageView.image = image;
                                    }
                                    completion:nil];
                }
                else {
                    self.contentImageView.image = image;
                }
                if (completion) {
                    completion();
                }
            }
         ];
    } else {
        self.contentImageHeightConstraint.constant = 0;
        if (completion) {
            completion();
        }
    }
    
    NSString *statusTitle = [NSString stringWithFormat:@"%@", [uiDelegate feedItemActionButton]];
    [self.statusTextButton setTitle:statusTitle forState:UIControlStateNormal];
    
    self.containerView.backgroundColor = [OTAppAppearance announcementFeedContainerColor];
}

- (IBAction)callToAction {
    if (self.tableViewDelegate != nil && [self.tableViewDelegate respondsToSelector:@selector(showAnnouncementDetails:)])
        [self.tableViewDelegate showAnnouncementDetails:(OTAnnouncement *)self.feedItem];
}

@end
