//
//  OTCollectionSourceBehavior.h
//  entourage
//
//  Created by sergiu buceac on 8/9/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTBehavior.h"

@interface OTCollectionSourceBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong, readonly) NSMutableArray* items;

- (void)updateItems:(NSArray *)items;

@end
