//
//  OTAddressBookService.h
//  entourage
//
//  Created by sergiu buceac on 7/28/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTAddressBookService : NSObject

- (void)readWithResultBlock:(void (^)(NSArray *))result;

@end
