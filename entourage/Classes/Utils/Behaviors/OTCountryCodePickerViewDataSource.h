//
//  OTCountryCodePickerViewDataSource.h
//  entourage
//
//  Created by veronica.gliga on 19/06/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"

@interface OTCountryCodePickerViewDataSource : OTBehavior

+ (OTCountryCodePickerViewDataSource *)sharedInstance;

- (NSInteger)count;
- (NSString *)getCountryFullNameAtRow:(NSInteger)row;
- (NSString *)getCountryShortNameAtRow:(NSInteger)row;
- (NSString *)getCountryCodeAtRow:(NSInteger)row;

@end
