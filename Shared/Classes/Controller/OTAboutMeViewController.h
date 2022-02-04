//
//  OTAboutMeViewController.h
//  entourage
//
//  Created by veronica.gliga on 26/10/2017.
//  Copyright © 2017 Entourage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTTextWithCount.h"
#import "OTTextView.h"

@protocol OTUserEditAboutProtocol <NSObject>

- (void)setNewAboutMe:(NSString *)aboutMe;

@end

@interface OTAboutMeViewController : UIViewController

@property (nonatomic, weak) id<OTUserEditAboutProtocol> delegate;
@property (nonatomic, weak) IBOutlet OTTextWithCount *aboutMeTextWithCount;
@property (nonatomic, strong) NSString *aboutMeMessage;
@property (nonatomic, weak) IBOutlet UIButton *closeButton;
@property (nonatomic, weak) IBOutlet UIButton *sendButton;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@end
