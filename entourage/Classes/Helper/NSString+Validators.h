/**
 * @author Guillaume Lagorce <glagorce@octo.com>
 * @author Olivier Martin <omartin@octo.com>
 *
 * @section Licence
 * Copyright (c) 2014-present BNP Paribas
 *
 * @section Description
 */

@interface NSString (Validators)

- (BOOL)isValidEmail;
- (BOOL)isValidPhoneNumber;
- (BOOL)isNotEmpty;
- (BOOL)isNumeric;
- (NSDecimalNumber *)numberFromString;

@end
