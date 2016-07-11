//
//  OTTourDetailsOptionsViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 08/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTFeedItemDetailsOptionsViewController.h"
#import "OTUser.h"
#import "UIColor+entourage.h"
#import "OTConsts.h"
#import "OTFeedItemFactory.h"

#define BUTTON_HEIGHT 44.0f
#define BUTTON_DELTAY  8.0f
#define BUTTON_FONT_SIZE 17

@interface OTFeedItemDetailsOptionsViewController ()

@property (nonatomic, weak) IBOutlet UIButton *cancelFeedItemButton;

@end

@implementation OTFeedItemDetailsOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    FeedItemState currentState = [[[OTFeedItemFactory createFor:self.feedItem] getStateInfo] getState];
    switch (currentState) {
        case FeedItemStateOngoing:
            [self addButtonWithTitle:OTLocalizedString(@"item_option_close") withSelectorNamed:@"doCloseFeedItem"];
            break;
        case FeedItemStateOpen:
        case FeedItemStateClosed:
            [self addButtonWithTitle:OTLocalizedString(@"item_option_freeze") withSelectorNamed:@"doFreezeFeedItem"];
            break;
        case FeedItemStateJoinAccepted:
            [self addButtonWithTitle:OTLocalizedString(@"item_option_quit") withSelectorNamed:@"doQuitFeedItem"];
            break;
        default:
            break;
    }
}

- (void)addButtonWithTitle:(NSString *)title withSelectorNamed:(NSString *)selector {
    CGRect frame = self.cancelFeedItemButton.frame;
    frame.origin.y -= (BUTTON_HEIGHT + BUTTON_DELTAY);
    frame.size.height = BUTTON_HEIGHT;
    
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    button.backgroundColor = [UIColor whiteColor];
    [button.titleLabel setFont:[UIFont systemFontOfSize:BUTTON_FONT_SIZE]];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor appOrangeColor] forState:UIControlStateNormal];
    [button addTarget:self action:NSSelectorFromString(selector) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (IBAction)doFreezeFeedItem {
    [[[OTFeedItemFactory createFor:self.feedItem] getStateTransition] deactivateWithSuccess:^(BOOL isTour) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } orFailure:nil];
}

- (IBAction)doCloseFeedItem {
    [[[OTFeedItemFactory createFor:self.feedItem] getStateTransition] stopWithSuccess:^() {
        [self.delegate promptToCloseFeedItem];
    }];
}

- (IBAction)doQuitFeedItem {
    [[[OTFeedItemFactory createFor:self.feedItem] getStateTransition] quitWithSuccess:^() {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (IBAction)dismissOptions {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
 OTTourJoinRequestViewController *controller = (OTTourJoinRequestViewController *)segue.destinationViewController;
 controller.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.1];
 [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];

}
*/

@end
