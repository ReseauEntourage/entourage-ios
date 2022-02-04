//
//  OTCollectionCellProviderBehavior.h
//  entourage
//
//  Created by sergiu buceac on 8/9/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTBehavior.h"
@class OTCollectionViewDataSourceBehavior;

@interface OTCollectionCellProviderBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet OTCollectionViewDataSourceBehavior *collectionDataSource;

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

@end
