//
//  OTMyEntouragesCellProviderBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/9/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMyEntouragesCellProviderBehavior.h"
#import "OTCollectionViewDataSourceBehavior.h"
#import "OTCollectionSourceBehavior.h"

@implementation OTMyEntouragesCellProviderBehavior

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [self.collectionDataSource.dataSource.collectionView dequeueReusableCellWithReuseIdentifier:@"InviteCell" forIndexPath:indexPath];
    return cell;
}

@end
