//
//  OTToolbar.m
//  entourage
//
//  Created by Ciprian Habuc on 19/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTToolbar.h"
#import "UIColor+entourage.h"
#import "OTConsts.h"

@implementation OTToolbar

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    
    UIBarButtonItem *filtersBBI = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"filters"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(showFilters)];
    
    UIBarButtonItem *geolocBBI = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"geoloc"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(showCurrentLocation)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"Entourages";
    titleLabel.textColor = [UIColor appGreyishBrownColor];
    titleLabel.font = [UIFont systemFontOfSize:12.0f weight:UIFontWeightRegular];
    UIBarButtonItem *titleBBI = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
    UIBarButtonItem *flexibleBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                  target:nil action:nil];
    
    [self setItems:@[filtersBBI, geolocBBI, flexibleBBI, titleBBI, flexibleBBI]];
}

- (void)showFilters {
    [[NSNotificationCenter defaultCenter] postNotificationName:@kNotificationShowFilters object:nil];
}

- (void)showCurrentLocation {
    [[NSNotificationCenter defaultCenter] postNotificationName:@kNotificationShowCurrentLocation object:nil];
}

@end
