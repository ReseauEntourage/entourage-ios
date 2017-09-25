//
//  OTCategoryDataSource.m
//  entourage
//
//  Created by veronica.gliga on 25/09/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTCategoryDataSource.h"
#import "OTCategoryFromJsonService.h"

@interface OTCategoryDataSource()

@property (nonatomic, strong) NSArray* items;

@end


@implementation OTCategoryDataSource

@synthesize items;

- (void)loadData {
    self.items = [OTCategoryFromJsonService getData];
}

@end
