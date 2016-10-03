//
//  OTBadgeNumberService.m
//  entourage
//
//  Created by sergiu buceac on 10/3/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBadgeNumberService.h"
#import "OTConsts.h"

#define BadgeKey @"BadgeKey"

@interface OTBadgeNumberService ()

@property (nonatomic, strong) NSMutableDictionary *badgeData;

@end

@implementation OTBadgeNumberService

- (instancetype)init {
    self = [super init];
    if(self) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:BadgeKey];
        if(data)
            self.badgeData = [[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
        else
            self.badgeData = [NSMutableDictionary new];
    }
    return self;
}

+ (OTBadgeNumberService*)sharedInstance {
    static OTBadgeNumberService* sharedInstance;
    static dispatch_once_t badgeServiceToken;
    dispatch_once(&badgeServiceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (NSNumber *)badgeCount {
    int nr = 0;
    for(id key in self.badgeData.allKeys)
        nr += [self.badgeData[key] intValue];
    return @(nr);
}

- (void)updateItem:(NSNumber *)itemId {
    NSNumber *nr = [self.badgeData objectForKey:itemId];
    if(!nr)
        nr = @(0);
    nr = @(nr.intValue + 1);
    [self.badgeData setObject:nr forKey:itemId];
    [self updateUserDefaults];
    [[NSNotificationCenter defaultCenter] postNotificationName:@kNotificationPushReceived object:nil];
 }

- (void)readItem:(NSNumber *)itemId {
    [self.badgeData removeObjectForKey:itemId];
    [self updateUserDefaults];
    [[NSNotificationCenter defaultCenter] postNotificationName:@kNotificationPushReceived object:nil];
}

- (void)clearData {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:BadgeKey];
}

#pragma mark - private methods

- (void)updateUserDefaults {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.badgeData];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:BadgeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
