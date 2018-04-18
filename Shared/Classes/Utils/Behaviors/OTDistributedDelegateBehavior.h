//
//  OTDistributedDelegateBehavior.h
//  entourage
//
//  Created by sergiu buceac on 10/2/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"

@interface OTDistributedDelegateBehavior : OTBehavior

@property (nonatomic, strong) IBOutletCollection(NSObject) NSArray *delegates;

@end
