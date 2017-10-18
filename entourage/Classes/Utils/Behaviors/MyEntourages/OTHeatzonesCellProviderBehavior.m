//
//  OTHeatzonesCellProviderBehavior.m
//  entourage
//
//  Created by Veronica Gliga on 14/09/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTHeatzonesCellProviderBehavior.h"
#import "OTEntourage.h"
#import "OTHeatZoneCollectionViewCell.h"
#import "OTCollectionViewDataSourceBehavior.h"
#import "OTCollectionSourceBehavior.h"


@implementation OTHeatzonesCellProviderBehavior

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    OTEntourage *entourage = (OTEntourage *)[self.collectionDataSource getItemAtIndexPath:indexPath];
    
    OTHeatZoneCollectionViewCell *cell;
    cell = (OTHeatZoneCollectionViewCell *)[self.collectionDataSource.dataSource.collectionView dequeueReusableCellWithReuseIdentifier:@"HeatzoneCell" forIndexPath:indexPath];
    [cell configureWith:entourage];
    return cell;
}

@end
