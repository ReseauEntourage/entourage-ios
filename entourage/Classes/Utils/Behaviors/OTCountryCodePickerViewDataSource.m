//
//  OTCountryCodePickerViewDataSource.m
//  entourage
//
//  Created by veronica.gliga on 19/06/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTCountryCodePickerViewDataSource.h"

@implementation OTCountryCodePickerViewDataSource

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.list.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

@end
