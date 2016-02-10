

@interface NSString (Validators)
@property(nonatomic, readonly) NSString *phoneNumberServerRepresentation;

- (BOOL)isValidEmail;
- (BOOL)isValidPhoneNumber;
- (BOOL)isValidCode;
- (BOOL)isNotEmpty;
- (BOOL)isNumeric;
- (NSDecimalNumber *)numberFromString;

@end
