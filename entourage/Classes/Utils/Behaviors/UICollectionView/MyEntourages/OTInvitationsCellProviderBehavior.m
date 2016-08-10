//
//  OTInvitationsCellProviderBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/9/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTInvitationsCellProviderBehavior.h"
#import "OTCollectionViewDataSourceBehavior.h"
#import "OTCollectionSourceBehavior.h"
#import "OTInvitationsCollectionViewCell.h"
#import "OTEntourageInvitation.h"

@implementation OTInvitationsCellProviderBehavior

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    OTEntourageInvitation *invitation = (OTEntourageInvitation *)[self.collectionDataSource getItemAtIndexPath:indexPath];
    
    OTInvitationsCollectionViewCell *cell = (OTInvitationsCollectionViewCell *)[self.collectionDataSource.dataSource.collectionView dequeueReusableCellWithReuseIdentifier:@"InviteCell" forIndexPath:indexPath];
    [cell configureWith:invitation];
    return cell;
}

@end
