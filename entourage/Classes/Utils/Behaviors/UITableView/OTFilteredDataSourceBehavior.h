//
//  OTFilteredDataSourceBehavior.h
//  entourage
//
//  Created by sergiu buceac on 7/29/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTDataSourceBehavior.h"

@interface OTFilteredDataSourceBehavior : OTDataSourceBehavior

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *allItems;

- (void)filterItemsByString:(NSString *)searchString;

@end
