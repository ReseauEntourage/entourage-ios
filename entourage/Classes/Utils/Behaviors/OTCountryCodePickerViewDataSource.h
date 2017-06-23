//
//  OTCountryCodePickerViewDataSource.h
//  entourage
//
//  Created by veronica.gliga on 19/06/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"

@interface OTCountryCodePickerViewDataSource : OTBehavior <UIPickerViewDataSource>

@property (nonatomic, weak) NSArray *list;

@end
