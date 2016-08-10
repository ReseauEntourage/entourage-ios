//
//  OTMyEntouragesDataSource.h
//  entourage
//
//  Created by sergiu buceac on 8/10/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTDataSourceBehavior.h"
#import "OTMyEntouragesFilterDelegate.h"

@interface OTMyEntouragesDataSource : OTDataSourceBehavior <OTMyEntouragesFilterDelegate>

- (void)loadNextPage;

@end
