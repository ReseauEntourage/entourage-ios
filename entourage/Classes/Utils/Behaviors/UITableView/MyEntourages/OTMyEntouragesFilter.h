//
//  OTMyEntouragesFilter.h
//  entourage
//
//  Created by sergiu buceac on 8/10/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTMyEntouragesFilter : NSObject

@property (nonatomic) BOOL isActive;
@property (nonatomic) BOOL isInvited;
@property (nonatomic) BOOL isOrganiser;
@property (nonatomic) BOOL isClosed;
@property (nonatomic) BOOL showDemand;
@property (nonatomic) BOOL showContribution;
@property (nonatomic) BOOL showTours;
@property (nonatomic) BOOL showOnlyMyEntourages;
@property (nonatomic) int timeframeInHours;

- (NSMutableDictionary *)toDictionaryWithPageNumber:(int)pageNumber andSize:(int)pageSize;

@end
