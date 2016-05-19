

#import "NSDictionary+Parsing.h"

@implementation NSDictionary (parsing)

static NSDateFormatter * dateFormatter;

/********************************************************************************/
#pragma mark - Number

- (NSNumber *)numberForKey:(NSString *)key defaultValue:(NSNumber *)defaultNumber options:(NSDictionaryParsingNumberOptions)options
{
	NSNumber *result = defaultNumber;

	id object = [self objectForKey:key];

	if ([object isKindOfClass:NSNumber.class] && (options & NSDictionaryParsingNumberOptionFromNumber))
	{
		result = object;
	}
	else if ([object isKindOfClass:NSString.class] && (options & NSDictionaryParsingNumberOptionFromString))

	{
		result = [[[NSNumberFormatter alloc] init] numberFromString:object];
		if (!result)
		{
			result = defaultNumber;
		}
	}

	return result;
}

- (NSNumber *)numberForKey:(NSString *)key defaultValue:(NSNumber *)defaultNumber
{
	return [self numberForKey:key defaultValue:defaultNumber options:NSDictionaryParsingNumberOptionFromNumber | NSDictionaryParsingNumberOptionFromString];
}

- (NSNumber *)numberForKey:(NSString *)key
{
	return [self numberForKey:key defaultValue:nil];
}

/********************************************************************************/
#pragma mark - NSDecimalNumber

- (NSDecimalNumber *)decimalNumberForKey:(NSString *)key defaultValue:(NSDecimalNumber *)defaultNumber
{
	NSDecimalNumber *result = defaultNumber;
	NSNumber *number = [self numberForKey:key defaultValue:nil];

	if (number)
	{
		result = [NSDecimalNumber decimalNumberWithDecimal:[number decimalValue]];
	}
	return result;
}

- (NSDecimalNumber *)decimalNumberForKey:(NSString *)key
{
	return [self decimalNumberForKey:key defaultValue:nil];
}

/********************************************************************************/
#pragma mark - String

- (NSString *)stringForKey:(NSString *)key defaultValue:(NSString *)defaultString
{
	NSString *result = defaultString;

	id object = [self objectForKey:key];

	if ([object isKindOfClass:NSString.class])
	{
		result = object;
	}

	return result;
}

- (NSString *)stringForKey:(NSString *)key
{
	return [self stringForKey:key defaultValue:@""];
}

/********************************************************************************/
#pragma mark - Bool

- (BOOL)boolForKey:(NSString *)key defaultValue:(BOOL)defaultBool
{
	BOOL result = defaultBool;

	id object = [self objectForKey:key];

	if ([object isKindOfClass:NSNumber.class])
	{
		result = [object boolValue];
	}

	return result;
}

- (BOOL)boolForKey:(NSString *)key
{
	return [self boolForKey:key defaultValue:NO];
}

/********************************************************************************/
#pragma mark - Date

/**
 * Parse
 * @param key => the key in the dictionary
 * @param format => the format for the date (default : "yyyy-MM-dd HH:mm:ss")
 * @param defaultDate => the default date to return
 * @return The NSDate
 */
- (NSDate *)dateForKey:(NSString *)key format:(NSString *)format defaultValue:(NSDate *)defaultDate
{
	NSDate *result = defaultDate;
	NSString *dateFormat = format ? format : @"yyyy-MM-dd HH:mm:ss";

	if (dateFormatter == nil)
	{
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"en_US_POSIX"]];
		[dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
	}
	[dateFormatter setDateFormat:dateFormat];

	id object = [self objectForKey:key];

	if ([object isKindOfClass:NSString.class])
	{
		NSDate *formattedDate = [dateFormatter dateFromString:object];

		if (formattedDate)
		{
			result = formattedDate;
		}
	}
	return result;
}

- (NSDate *)dateForKey:(NSString *)key format:(NSString *)format
{
	return [self dateForKey:key format:format defaultValue:nil];
}

- (NSDate *)dateForKey:(NSString *)key
{
    NSDate *date = [self dateForKey:key format:DATE_FORMAT_JAVA];
    if (date == nil) {
        date = [self dateForKey:key format:DATE_FORMAT_OBJC];
    }
    
    return date;
}

/********************************************************************************/
#pragma mark - Array

- (NSArray *)arrayWithObjectsOfClass:(Class)class forKey:(NSString *)key
{
	NSMutableArray *objects = nil;

	id parsedValue = [self objectForKey:key];

	if ([parsedValue isKindOfClass:NSArray.class])
	{
		objects = [NSMutableArray array];

		for (id parsedObject in parsedValue)
		{
			if ([parsedObject isKindOfClass:class])
			{
				[objects addObject:parsedObject];
			}
		}
	}

	return objects;
}

/********************************************************************************/
#pragma mark - NSURL

- (NSURL *)urlForKey:(NSString *)key defaultValue:(NSURL *)defaultUrl
{
	NSURL *result = defaultUrl;

	id object = [self objectForKey:key];

	if ([object isKindOfClass:NSURL.class])
	{
		result = object;
	}
	else if ([object isKindOfClass:NSString.class])
	{
		if ([NSDictionary validateUrl:object])
		{
			result = [NSURL URLWithString:object];
		}
	}

	return result;
}

- (NSURL *)urlForKey:(NSString *)key
{
	return [self urlForKey:key defaultValue:nil];
}

+ (BOOL)validateUrl:(NSString *)urlString
{
	NSString *urlRegEx =
		@"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
	NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];

	return [urlTest evaluateWithObject:urlString];
}

/********************************************************************************/
#pragma mark - NSURL
- (CLLocation *)locationForKey:(NSString *)key
               withLatitudeKey:(NSString *)latitudeKey
               andLongitudeKey:(NSString *)longitudeKey
{
    NSDictionary *dictionary = [self objectForKey:key];
    CLLocationDegrees lat = [dictionary degreesForKey:latitudeKey];
    CLLocationDegrees lon = [dictionary degreesForKey:longitudeKey];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
    return location;
}

- (CLLocationDegrees)degreesForKey:(NSString *)key {
    return [self numberForKey:key].doubleValue;
}


@end
