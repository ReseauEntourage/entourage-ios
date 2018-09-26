//
//  OTMemberCountCell.h
//  entourage
//
//  Created by sergiu buceac on 10/12/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTMembersDataSource.h"
#import "OTBaseInfoCell.h"
#import "OTPublicInfoDataSource.h"

@interface OTMemberCountCell : OTBaseInfoCell

@property (nonatomic, weak) IBOutlet UILabel *lblCount;
@property (nonatomic, weak) IBOutlet OTMembersDataSource *dataSource;
@property (nonatomic, weak) IBOutlet OTPublicInfoDataSource *publicItemDataSource;

@end
