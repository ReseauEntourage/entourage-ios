//
//  OTUserPermissions.m
//  entourage
//
//  Created by Jerome on 14/12/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

#import "OTUserPermissions.h"

NSString *const kKeyUserPermissionsOuting = @"outing";
NSString *const kKeyUserPermissionsOutingCreation = @"creation";

@implementation OTUserPermissions
- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
      NSDictionary *outing = [dictionary objectForKey:kKeyUserPermissionsOuting];
       NSNumber *creation = [outing objectForKey:kKeyUserPermissionsOutingCreation];
        
        self.isEventCreationActive = creation.boolValue;
    }
    
    return  self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeBool:self.isEventCreationActive forKey:kKeyUserPermissionsOutingCreation];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        self.isEventCreationActive = [decoder decodeBoolForKey:kKeyUserPermissionsOutingCreation];
    }
    return self;
}
@end

