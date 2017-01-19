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
#import "OTLocationManager.h"

@interface OTToolbar()

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation OTToolbar

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    return self;
}

- (void)setupWithFilters {
    UIBarButtonItem *filtersBBI = [self filtersBarButtonItem];
    UIBarButtonItem *locationBBI = [self locationBarButtonItem];
    UIBarButtonItem *titleBBI = [self titleBarButtonItem];
    
    UIBarButtonItem *flexibleBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                 target:nil action:nil];
    
    [self setItems:@[filtersBBI, locationBBI, flexibleBBI, titleBBI, flexibleBBI]];
}

- (void)setupDefault {
    UIBarButtonItem *locationBBI = [self locationBarButtonItem];
    UIBarButtonItem *titleBBI = [self titleBarButtonItem];
    
    UIBarButtonItem *flexibleBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                 target:nil action:nil];
    
    [self setItems:@[locationBBI, flexibleBBI, titleBBI, flexibleBBI]];
}

- (UIBarButtonItem*)filtersBarButtonItem {
    UIBarButtonItem *filtersBBI = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"filters"] style:UIBarButtonItemStylePlain target:self action:@selector(showFilters)];
    return filtersBBI;
}

- (UIBarButtonItem*)locationBarButtonItem {
    UIButton *locButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *locImage = [UIImage imageNamed:@"geoloc"];
    [locButton setImage:locImage forState:UIControlStateNormal];
    locButton.frame = CGRectMake(0.0f, 0.0f, locImage.size.width, locImage.size.height);
    [locButton addTarget:self action:@selector(showCurrentLocation) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *geolocBBI = [[UIBarButtonItem alloc] initWithCustomView:locButton];
    return geolocBBI;
}

- (UIBarButtonItem*)titleBarButtonItem {
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 20)];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.text = self.title;
    _titleLabel.textColor = [UIColor appGreyishBrownColor];
    _titleLabel.font = [UIFont systemFontOfSize:12.0f weight:UIFontWeightRegular];
    UIBarButtonItem *titleBBI = [[UIBarButtonItem alloc] initWithCustomView:_titleLabel];
    return titleBBI;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;

    [self setNeedsDisplay];
}

- (void)showFilters {
    [Flurry logEvent:@"FeedFiltersPress"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@kNotificationShowFilters object:nil];
}

- (void)showCurrentLocation {
    [Flurry logEvent:@"RecenterMapClick"];
    if(![OTLocationManager sharedInstance].isAuthorized)
       [[OTLocationManager sharedInstance] showGeoLocationNotAllowedMessage:OTLocalizedString(@"ask_permission_location_recenter_map")];
    else if(![OTLocationManager sharedInstance].currentLocation)
        [[OTLocationManager sharedInstance] showLocationNotFoundMessage:OTLocalizedString(@"no_location_recenter_map")];
    else
        [[NSNotificationCenter defaultCenter] postNotificationName:@kNotificationShowCurrentLocation object:nil];
}

@end
