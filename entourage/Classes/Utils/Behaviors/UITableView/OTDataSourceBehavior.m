//
//  OTDataSourceBehavior.m
//  entourage
//
//  Created by sergiu buceac on 7/29/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTDataSourceBehavior.h"

@interface OTDataSourceBehavior ()

@property (nonatomic, strong) NSMutableArray* items;

@end

@implementation OTDataSourceBehavior

- (void)updateItems:(NSArray *)items {
    self.items = [NSMutableArray arrayWithArray:items];
}

- (void)loadData {
}

@end
