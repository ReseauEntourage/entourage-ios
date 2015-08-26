

#import "NSString+Validators.h"

@implementation NSString (Validators)

/********************************************************************************/
#pragma mark - Public

- (BOOL)isValidEmail
{
	NSString *stricterFilterString = @"^[_A-Za-z0-9-+]+(\\.[_A-Za-z0-9-+]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z‌​]{2,4})$";

	return [self matchesRegularExpression:stricterFilterString];
}

- (BOOL)isValidPhoneNumber
{
    return [self matchesRegularExpression:@"^((\\+|00)33\\s?|0)[67](\\s?\\d{2}){4}$"];
}

- (BOOL)isNotEmpty
{
	return self.length > 0;
}

- (BOOL)isNumeric
{
	NSNumber *number = [[[NSNumberFormatter alloc] init] numberFromString:self];

	return number != nil;
}

- (NSDecimalNumber *)numberFromString
{
	NSArray *array = [self componentsSeparatedByString:@"€"];
	NSString *text = array[0];
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];

	text = [text stringByReplacingOccurrencesOfString:[formatter groupingSeparator] withString:@""];
	NSDecimal decimal = [[formatter numberFromString:text] decimalValue];
	NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithDecimal:decimal];
	return amount;
}

- (NSString *) phoneNumberServerRepresentation
{
    if ([self matchesRegularExpression:@"^(0)[67](\\s?\\d{2}){4}$"])
    {
        NSRange range = NSMakeRange(0, 1);
        return [self stringByReplacingCharactersInRange:range withString:@"+33"];
    }
    return self;
}

/********************************************************************************/
#pragma mark - Private

- (BOOL)matchesRegularExpression:(NSString *)regexString
{
	NSError *error = NULL;

	NSRegularExpression *regex =
		[NSRegularExpression regularExpressionWithPattern:regexString
												  options:NSRegularExpressionCaseInsensitive
													error:&error];

	NSUInteger numberOfMatches =
		[regex numberOfMatchesInString:self
							   options:0
								 range:NSMakeRange(0, [self length])];

	return numberOfMatches ? YES : NO;
}

@end
