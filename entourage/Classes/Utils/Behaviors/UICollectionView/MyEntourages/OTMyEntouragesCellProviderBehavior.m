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
#import "OTMyEntouragesCollectionViewCell.h"
#import "OTEntourageInvitation.h"

@implementation OTMyEntouragesCellProviderBehavior

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    OTEntourageInvitation *invitation = (OTEntourageInvitation *)[self.collectionDataSource getItemAtIndexPath:indexPath];
    
    OTMyEntouragesCollectionViewCell *cell = (OTMyEntouragesCollectionViewCell *)[self.collectionDataSource.dataSource.collectionView dequeueReusableCellWithReuseIdentifier:@"InviteCell" forIndexPath:indexPath];
    [cell configureWith:invitation];
    return cell;
}

@end
