//
//  OTCollectionCellProviderBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/9/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTCollectionCellProviderBehavior.h"

@implementation OTCollectionCellProviderBehavior

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    @throw @"Don't use base cell provider directly";
}

@end
