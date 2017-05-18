//
//  OTEditEntourageTitleViewController.h
//  entourage
//
//  Created by sergiu.buceac on 18/05/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditTitleDelegate <NSObject>

- (void)titleEdited:(NSString *)title;

@end

@interface OTEditEntourageTitleViewController : UIViewController

@property (nonatomic, strong) NSString *currentTitle;
@property (nonatomic, weak) id<EditTitleDelegate> delegate;

@end
