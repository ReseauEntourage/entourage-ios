//
//  OTAddEditEntourageDataSource.h
//  entourage
//
//  Created by Smart Care on 12/07/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OTAddEditEntourageDelegate <NSObject>
- (void)editEntourageCategory;
- (void)editEntourageLocation;
- (void)editEntourageTitle;
- (void)editEntourageDescription;
- (void)editEntourageAddress;
- (void)editEntourageDate;
@end

@interface OTAddEditEntourageDataSource : NSObject
+ (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
                               entourage:(OTEntourage*)entourage;
+ (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
+ (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
+ (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                     entourage:(OTEntourage*)entourage
                  locationText:(NSString*)locationText;
+ (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
     withDelegate:(id<OTAddEditEntourageDelegate>)delegate
        entourage:(OTEntourage*)entourage;
+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath;
@end
