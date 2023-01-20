//
//  OTCountryCodePickerViewDataSource.h
//  entourage
//
//  Created by veronica.gliga on 19/06/2017.
//  Copyright © 2017 Entourage. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OTCountryCodePickerViewDataSource : UIControl

+ (OTCountryCodePickerViewDataSource *)sharedInstance;

- (NSInteger)count;

- (NSString *)getTitleForRow:(NSInteger)row;

- (NSString *)getCountryFullNameForRow:(NSInteger)row;
- (NSString *)getCountryShortNameForRow:(NSInteger)row;
- (NSString *)getCountryCodeForRow:(NSInteger)row;

@end
