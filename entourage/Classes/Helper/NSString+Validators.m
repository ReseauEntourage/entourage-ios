

#import "NSString+Validators.h"

@implementation NSString (Validators)

/********************************************************************************/
#pragma mark - Public

- (BOOL)isValidEmail
{

    NSString *stricterFilterString = @"^[_A-Za-z0-9-+]+(\\.[_A-Za-z0-9-+]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z‌​]{2,10})$";
    
    return [self matchesRegularExpression:stricterFilterString];
}

- (BOOL)isValidPhoneNumber
{
    
#if DEBUG
    return YES;
#else
    NSString *regexCA = @"^((\\+|00)1\\s?|)\\(?(\\d{3})\\)?\\s?(\\d{3})\\s?(\\d{4})$";
    NSString *regexFR = @"^((\\+|00)33\\s?|0)[67](\\s?\\d{2}){4}$";
    //NSString *regexInternational = @"^\\+(?:[0-9]?){6,14}[0-9]$";

    return [self matchesRegularExpression:regexFR] || [self matchesRegularExpression:regexCA];
#endif
}

- (BOOL)isValidCode {
    return [self matchesRegularExpression:@"^\\d*$"];
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
    NSString *serverNumber = self;
    serverNumber = [serverNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    serverNumber = [serverNumber stringByReplacingOccurrencesOfString:@"." withString:@""];
    serverNumber = [serverNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    serverNumber = [serverNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    serverNumber = [serverNumber stringByReplacingOccurrencesOfString:@")" withString:@""];

    //if number if starting with a 0, it means it is a French number so replace 0 by +33
    if ([self matchesRegularExpression:@"^(0)[67](\\s?\\d{2}){4}$"])
    {
        //    07 40 88 42 67
        // +40 7 40 88 42 67
        NSRange range = NSMakeRange(0, 1);
        serverNumber = [serverNumber stringByReplacingCharactersInRange:range withString:@"+33"];
    }
    if ([serverNumber hasPrefix:@"00"])
    {
        serverNumber = [serverNumber stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@"+"];
    }
    //if number is not starting by a + we add one + so we assume it is a international number (maybe use NSTextCheckingTypePhoneNumber here
    if (![serverNumber hasPrefix:@"+"])
    {
        serverNumber = [NSString stringWithFormat:@"+%@", serverNumber];
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
