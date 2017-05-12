//
//  OTTextView.h
//  entourage
//
//  Created by veronica.gliga on 11/04/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OTTextView : UITextView

@property (nonatomic, strong) IBInspectable NSString *placeholder;
@property (nonatomic, strong) IBInspectable NSString *editingPlaceholder;
@property (nonatomic, strong) IBInspectable UIColor *placeholderLargeColor;
@property (nonatomic, assign) BOOL computedFrames;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, assign) CGRect largePlaceholderFrame;
@property (nonatomic, assign) CGRect smallPlaceholderFrame;
@property (nonatomic, weak) id<UITextViewDelegate> forwardDelegate;

@end
