

@interface NSString (Validators)

- (BOOL)isValidEmail;
- (BOOL)isValidPhoneNumber;
- (BOOL)isNotEmpty;
- (BOOL)isNumeric;
- (NSDecimalNumber *)numberFromString;

@end
