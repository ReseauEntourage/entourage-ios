//
//  OTBarButtonView.h
//  entourage
//
//  Created by veronica.gliga on 09/11/2017.
//  Copyright © 2017 Entourage. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BarButtonViewPosition) {
    BarButtonViewPositionLeft,
    BarButtonViewPositionRight
};

@interface OTBarButtonView : UIView

@property (nonatomic, assign) BarButtonViewPosition position;

@end
