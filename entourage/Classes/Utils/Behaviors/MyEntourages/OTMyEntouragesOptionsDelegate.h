//
//  OTMyEntouragesOptionsDelegate.h
//  entourage
//
//  Created by sergiu buceac on 8/12/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OTMyEntouragesOptionsDelegate <NSObject>

- (void)createDemand;
- (void)createContribution;
- (void)createTour;
- (void)createEncounter;

@end
