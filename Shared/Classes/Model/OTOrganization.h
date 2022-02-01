//
//  OTOrganization.h
//  entourage
//
//  Created by Nicolas Telera on 18/11/2015.
//  Copyright © 2015 Entourage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTOrganization : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *desc;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *logoUrl;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
