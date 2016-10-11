//
//  OTMyEntouragesTableDataSource.h
//  entourage
//
//  Created by sergiu buceac on 8/10/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTableDataSourceBehavior.h"
#import "OTFeedItemDetailsBehavior.h"

@interface OTMyEntouragesTableDataSource : OTTableDataSourceBehavior

@property (nonatomic, weak) IBOutlet OTFeedItemDetailsBehavior* detailsBehavior;

@end
