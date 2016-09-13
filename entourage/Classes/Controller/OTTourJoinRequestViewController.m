//
//  OTTourJoinRequestViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 01/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTourJoinRequestViewController.h"
#import "OTTourService.h"
#import "OTEntourageService.h"
#import "OTTour.h"
#import "OTEntourage.h"

#import "SVProgressHUD.h"
#import "OTConsts.h"
#import "IQKeyboardManager.h"

@interface OTTourJoinRequestViewController ()

@property (nonatomic, weak) IBOutlet UILabel *greetingLabel;
@property (nonatomic, weak) IBOutlet UITextView *greetingMessage;

@end

@implementation OTTourJoinRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    //[[IQKeyboardManager sharedManager] disableInViewControllerClass:[self class]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
   
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
     //[[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUI {
    
    
    NSDictionary *lightAttrs = @{NSFontAttributeName : [UIFont systemFontOfSize:17 weight:UIFontWeightLight]};
    NSDictionary *mediumAttrs = @{NSFontAttributeName : [UIFont systemFontOfSize:17 weight:UIFontWeightMedium]};
    NSAttributedString *merciAttrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@!\n\n", OTLocalizedString(@"thanks").uppercaseString] attributes:mediumAttrs];
    NSAttributedString *cetteTourAttrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", OTLocalizedString(@"tour_join_intro")] attributes:lightAttrs];
    NSAttributedString *messageAttrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", OTLocalizedString(@"tour_join_message")] attributes:mediumAttrs];
    
    NSMutableAttributedString *greetingAttrString = merciAttrString.mutableCopy;
    [greetingAttrString appendAttributedString:cetteTourAttrString];
    [greetingAttrString appendAttributedString:messageAttrString];

    [self.greetingLabel setAttributedText:greetingAttrString];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller. 
}
*/

- (IBAction)doDismiss {
    if ([self.tourJoinRequestDelegate respondsToSelector:@selector(dismissTourJoinRequestController)]) {
        [self.tourJoinRequestDelegate dismissTourJoinRequestController];
    }
}


- (IBAction)doSendRequest {
    NSString *message = self.greetingMessage.text;
    if (!message)
        message = @"";
    [SVProgressHUD show];
    if ([self.feedItem isKindOfClass:[OTTour class]]) {
        OTTour *tour = (OTTour*)_feedItem;
        [[OTTourService new] joinMessageTour:tour
                                     message:message
                                     success:^(OTTourJoiner *joiner) {
            [SVProgressHUD dismiss];
            NSLog(@"JoinMessageTour was sent. :)");
        } failure:^(NSError *error) {
            [SVProgressHUD dismiss];
            NSLog(@"Failed to send join message tour: %@", error.description);
        }];
    }
    else if ([self.feedItem isKindOfClass:[OTEntourage class]]) {
        OTEntourage *entourage = (OTEntourage *)_feedItem;
        [[OTEntourageService new] joinMessageEntourage:entourage message:message success:^(OTTourJoiner *joiner) {
            [SVProgressHUD dismiss];
            NSLog(@"JoinMessage was sent. :)");
        } failure:^(NSError *error) {
            [SVProgressHUD dismiss];
            NSLog(@"Failed to send join message: %@", error.description);
        }];
    }

    
    if ([self.tourJoinRequestDelegate respondsToSelector:@selector(dismissTourJoinRequestController)]) {
        [self.tourJoinRequestDelegate dismissTourJoinRequestController];
    }
}


@end
