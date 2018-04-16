//
//  OTTextWithCount.h
//  entourage
//
//  Created by sergiu buceac on 10/14/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TextWithCountDelegate <NSObject>

- (void)maxLengthReached:(BOOL)reached;

@end

@interface OTTextWithCount : UIView

@property (nullable, weak, nonatomic) id<TextWithCountDelegate> delegate;

@property (nonatomic, strong, nullable) UITextView *textView;
@property (nonatomic, strong, nullable) NSString *placeholder;
@property (nonatomic, strong, nullable) NSString *editingPlaceholder;
@property (nonatomic, assign) int maxLength;
@property (nonatomic, strong, nullable) IBInspectable UIColor *placeholderLargeColor;
@property (nonatomic, strong, nullable) IBInspectable UIColor *placeholderSmallColor;

- (void)updateAfterSpeech;


@end
