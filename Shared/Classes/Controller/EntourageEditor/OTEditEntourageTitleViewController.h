//
//  OTEditEntourageTitleViewController.h
//  entourage
//
//  Created by sergiu.buceac on 18/05/2017.
//  Copyright © 2017 Entourage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTEntourage.h"

@protocol EditTitleDelegate <NSObject>

- (void)titleEdited:(NSString *)title;

@end

@interface OTEditEntourageTitleViewController : UIViewController

@property (nonatomic, strong) NSString *currentTitle;
@property (nonatomic, strong) OTEntourage *currentEntourage;
@property (nonatomic, weak) id<EditTitleDelegate> delegate;

@end
