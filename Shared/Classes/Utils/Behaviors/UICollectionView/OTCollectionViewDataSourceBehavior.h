//
//  OTCollectionViewDataSourceBehavior.h
//  entourage
//
//  Created by sergiu buceac on 8/9/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"
@class OTCollectionSourceBehavior;
@class OTCollectionCellProviderBehavior;

@interface OTCollectionViewDataSourceBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet OTCollectionSourceBehavior *dataSource;
@property (nonatomic, weak) IBOutlet OTCollectionCellProviderBehavior *cellProvider;

- (id)getItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)refresh;

@end
