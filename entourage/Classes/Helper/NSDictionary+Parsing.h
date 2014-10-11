

typedef NS_ENUM (NSInteger, NSDictionaryParsingNumberOptions)
{
	NSDictionaryParsingNumberOptionFromString = 0x01,
	NSDictionaryParsingNumberOptionFromNumber = 0x02
};

@interface NSDictionary (Parsing)

/********************************************************************************/
#pragma mark - Number

- (NSNumber *)numberForKey:(NSString *)key defaultValue:(NSNumber *)defaultNumber options:(NSDictionaryParsingNumberOptions)options;
- (NSNumber *)numberForKey:(NSString *)key defaultValue:(NSNumber *)defaultNumber;
- (NSNumber *)numberForKey:(NSString *)key;

/********************************************************************************/
#pragma mark - NSDecimalNumber

- (NSDecimalNumber *)decimalNumberForKey:(NSString *)key defaultValue:(NSDecimalNumber *)defaultNumber;
- (NSDecimalNumber *)decimalNumberForKey:(NSString *)key;


/********************************************************************************/
#pragma mark - String

- (NSString *)stringForKey:(NSString *)key defaultValue:(NSString *)defaultString;
- (NSString *)stringForKey:(NSString *)key;

/********************************************************************************/
#pragma mark - Bool

- (BOOL)boolForKey:(NSString *)key defaultValue:(BOOL)defaultBool;
- (BOOL)boolForKey:(NSString *)key;

/********************************************************************************/
#pragma mark - Date

- (NSDate *)dateForKey:(NSString *)key format:(NSString *)format defaultValue:(NSDate *)defaultDate;
- (NSDate *)dateForKey:(NSString *)key format:(NSString *)format;

/********************************************************************************/
#pragma mark - Array

- (NSArray *)arrayWithObjectsOfClass:(Class)class forKey:(NSString *)key;

/********************************************************************************/
#pragma mark - NSURL

- (NSURL *)urlForKey:(NSString *)key defaultValue:(NSURL *)defaultUrl;
- (NSURL *)urlForKey:(NSString *)key;
+ (BOOL)validateUrl:(NSString *)urlString;

@end
