//
//  OTAboutItem.h
//  entourage
//
//  Created by Mihai Ionescu on 01/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    Rate,
    Facebook,
    GeneralConditions,
    FAQ,
    Website
} AboutItems;

@interface OTAboutItem : NSObject

/**************************************************************************************************/
#pragma mark - Getters and Setters

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, assign) AboutItems type;

/**************************************************************************************************/
#pragma mark - Birth and Death

- (instancetype)initWithTitle:(NSString *)title url:(NSString *)url;
- (instancetype)initWithTitle:(NSString *)title identifier:(NSString *)identifier;

@end
