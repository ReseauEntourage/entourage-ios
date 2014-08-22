//
//  OTTestHelper.m
//  entourage
//
//  Created by Louis Davin on 22/08/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTTestHelper.h"

@interface OTTestHelper ()

@end

@implementation OTTestHelper

/**************************************************************************************************/
#pragma mark - Public methods

+ (NSDictionary *)parseJSONFromFileNamed:(NSString *)fileName
{
    NSBundle *testBundle =[NSBundle bundleForClass:[self class]];
    NSData *data = [NSData dataWithContentsOfFile:[testBundle pathForResource:fileName ofType:@"json"]];

    NSError *error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];

    return dictionary;
}

@end
