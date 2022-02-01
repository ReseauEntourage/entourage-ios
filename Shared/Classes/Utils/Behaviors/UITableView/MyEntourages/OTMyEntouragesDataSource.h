//
//  OTMyEntouragesDataSource.h
//  entourage
//
//  Created by sergiu buceac on 8/10/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTDataSourceBehavior.h"
#import "OTFeedItemsFilterDelegate.h"

@interface OTMyEntouragesDataSource : OTDataSourceBehavior <OTFeedItemsFilterDelegate>
@property (strong, nonatomic) IBOutlet UIView *noDataView;
@property (strong, nonatomic) IBOutlet UIImageView *noDataRoundedBackground;
@property (strong, nonatomic) IBOutlet UILabel *noDataTitle;
@property (strong, nonatomic) IBOutlet UILabel *noDataSubtitle;

- (void)loadNextPage;

@end
