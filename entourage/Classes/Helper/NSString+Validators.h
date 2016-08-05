

@interface NSString (Validators)

- (BOOL)isValidEmail;
- (BOOL)isValidPhoneNumber;
- (BOOL)isValidCode;
- (BOOL)isNotEmpty;
- (BOOL)isNumeric;
- (NSDecimalNumber *)numberFromString;

@end
