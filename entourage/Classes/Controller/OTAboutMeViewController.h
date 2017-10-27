//
//  OTAboutMeViewController.h
//  entourage
//
//  Created by veronica.gliga on 26/10/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTTextWithCount.h"
#import "OTTextView.h"

@protocol OTUserEditAboutProtocol <NSObject>

- (void)setNewAboutMe:(NSString *)aboutMe;

@end

@interface OTAboutMeViewController : UIViewController

@property (nonatomic, weak) id<OTUserEditAboutProtocol> delegate;
@property (nonatomic, weak) IBOutlet OTTextView *aboutMeMessage;

@end
