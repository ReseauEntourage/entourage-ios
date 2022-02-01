//
//  OTAssociationsSourceBehavior.h
//  entourage
//
//  Created by sergiu buceac on 1/17/17.
//  Copyright © 2017 Entourage. All rights reserved.
//

#import "OTFilteredDataSourceBehavior.h"

@interface OTAssociationsSourceBehavior : OTFilteredDataSourceBehavior

- (void)updateAssociation:(void (^)(void))success;

@end
