//
//  OTHeatzonesCellProviderBehavior.m
//  entourage
//
//  Created by Veronica Gliga on 14/09/2017.
//  Copyright © 2017 Entourage. All rights reserved.
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
    
    cell.layer.shadowOffset = CGSizeMake(0, 1);
    cell.layer.shadowColor = [[UIColor grayColor] CGColor];
    cell.layer.shadowRadius = 3;
    cell.layer.shadowOpacity = .8f;
    CGRect shadowFrame = cell.layer.bounds;
    CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:shadowFrame].CGPath;
    cell.layer.shadowPath = shadowPath;
    [cell.layer setMasksToBounds:NO];
    
    return cell;
}

@end
