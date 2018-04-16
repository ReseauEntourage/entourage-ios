//
//  OTLostCodeViewController.h
//  entourage
//
//  Created by Nicolas Telera on 05/01/2016.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

@class JVFloatLabeledTextField;

@protocol LostCodeDelegate <NSObject>

- (void)loginWithNewCode:(NSString*)code;
- (void)loginWithCountryCode:(long)code andPhoneNumber: (NSString *)phone;

@end

@interface OTLostCodeViewController : UIViewController

@property (nonatomic, weak) id<LostCodeDelegate> codeDelegate;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *countryCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *countryPicker;
@property (weak, nonatomic) NSString *codeCountry;
@property (assign, nonatomic) long rowCode;

@end
