//
//  OTInvitationsCollectionSource.m
//  entourage
//
//  Created by sergiu buceac on 8/25/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTInvitationsCollectionSource.h"
#import "OTCollectionSourceBehavior.h"
#import "OTManageInvitationBehavior.h"

@interface OTInvitationsCollectionSource () <UICollectionViewDelegate>

@end

@implementation OTInvitationsCollectionSource

- (void)initialize {
    [super initialize];
    self.dataSource.collectionView.delegate = self;
}

- (void)removeInvitation:(OTEntourageInvitation *)invitation {
    NSUInteger row = [self.dataSource.items indexOfObject:invitation];
    [self.dataSource.items removeObject:invitation];
    [self.dataSource.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]]];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    OTEntourageInvitation *invitation = (OTEntourageInvitation *)[self getItemAtIndexPath:indexPath];
    [self.manageInvitations showFor:invitation];
}

@end
