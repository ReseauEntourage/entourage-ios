//
//  OTCollectionViewDataSourceBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/9/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTCollectionViewDataSourceBehavior.h"
#import "OTCollectionSourceBehavior.h"
#import "OTCollectionCellProviderBehavior.h"

@interface OTCollectionViewDataSourceBehavior () <UICollectionViewDataSource>

@end

@implementation OTCollectionViewDataSourceBehavior

- (void)initialize {
    [self.dataSource initialize];
    self.dataSource.collectionView.dataSource = self;
}

- (id)getItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSource.items objectAtIndex:indexPath.row];
}

- (void)refresh {
    [self.dataSource.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.cellProvider collectionView:collectionView cellForItemAtIndexPath:indexPath];
}

@end
