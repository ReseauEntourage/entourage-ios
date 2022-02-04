//
//  OTCollectionSourceBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/9/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTCollectionSourceBehavior.h"

@interface OTCollectionSourceBehavior ()

@property (nonatomic, strong) NSMutableArray* items;

@end

@implementation OTCollectionSourceBehavior

- (void)updateItems:(NSArray *)items {
    self.items = [NSMutableArray arrayWithArray:items];
}

@end
