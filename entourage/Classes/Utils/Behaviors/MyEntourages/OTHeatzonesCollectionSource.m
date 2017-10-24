//
//  OTHeatzonesCollectionSource.m
//  entourage
//
//  Created by Veronica Gliga on 14/09/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTHeatzonesCollectionSource.h"
#import "OTCollectionSourceBehavior.h"
#import "OTEntourage.h"
#import "OTEntourageService.h"


@interface OTHeatzonesCollectionSource () <UICollectionViewDelegate>

@end

@implementation OTHeatzonesCollectionSource

- (void)initialize {
    [super initialize];
    self.dataSource.collectionView.delegate = self;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id entourage = [self getItemAtIndexPath:indexPath];
    if (self.heatzonesDelegate != nil && [self.heatzonesDelegate respondsToSelector:@selector(showFeedInfo:)])
        [self.heatzonesDelegate showFeedInfo:entourage];
    if([entourage isKindOfClass:[OTEntourage class]]
       && [[entourage joinStatus] isEqualToString:@"not_requested"])  {
        NSNumber *rank = @(indexPath.section);
        
        [[OTEntourageService new] retrieveEntourage:(OTEntourage *)entourage
                                           fromRank:rank
                                            success:nil
                                            failure:nil];
    }
}

@end
