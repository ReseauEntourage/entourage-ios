//
//  OTFilteredDataSourceBehavior.m
//  entourage
//
//  Created by sergiu buceac on 7/29/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTFilteredDataSourceBehavior.h"

@interface OTFilteredDataSourceBehavior () <UISearchBarDelegate>

@end

@implementation OTFilteredDataSourceBehavior

- (void)initialize {
    self.searchBar.delegate = self;
}

- (void)updateItems:(NSArray *)items {
    if(!self.allItems)
        self.allItems = items;
    [super updateItems: items];
}

- (void)filterItemsByString:(NSString *)searchString {
}

#pragma mark - search bar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self filterItemsByString:searchText];
}

@end
