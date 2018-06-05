//
//  OTUserMembership.h
//  entourage
//
//  Created by Smart Care on 25/05/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kUserMembershipType;
extern NSString *const kUserMembershipList;
extern NSString *const kUserMembershipListItemId;
extern NSString *const kUserMembershipListItemTitle;
extern NSString *const kUserMembershipListItemPeople;

@interface OTUserMembershipListItem: NSObject
@property (nonatomic) NSNumber *id;
@property (nonatomic) NSString *title;
@property (nonatomic) NSNumber *noOfPeople;

@property (nonatomic) BOOL isSelected;
@end

@interface OTUserMembership : NSObject
@property (nonatomic) NSString *type;
@property (nonatomic, readonly) NSMutableArray <OTUserMembershipListItem*> *list;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end

