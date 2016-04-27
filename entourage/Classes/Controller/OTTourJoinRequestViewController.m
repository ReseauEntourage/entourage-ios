//
//  OTTourJoinRequestViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 01/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTourJoinRequestViewController.h"
#import "OTTourService.h"
#import "SVProgressHUD.h"
#import "OTConsts.h"

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
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUI {
    
    
    NSDictionary *lightAttrs = @{NSFontAttributeName : [UIFont systemFontOfSize:17 weight:UIFontWeightLight]};
    NSDictionary *mediumAttrs = @{NSFontAttributeName : [UIFont systemFontOfSize:17 weight:UIFontWeightMedium]};
    NSAttributedString *merciAttrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@!\n\n", OTLocalizedString(@"thanks").uppercaseString] attributes:mediumAttrs];
    NSAttributedString *cetteTourAttrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", OTLocalizedString(@"tour_join_intro")] attributes:lightAttrs];
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
    
    [[OTTourService new] joinTour:self.tour
                      withMessage:message
                          success:^(OTTourJoiner *joiner) {
                              NSLog(@"sent request to join tour %@: %@", self.tour.sid, message);
                              self.tour.joinStatus = @"pending";
                          }
                          failure:^(NSError *error) {
                              NSLog(@"failed joining tour %@ with error %@", self.tour.sid, error.description);
                              [self dismissViewControllerAnimated:YES completion:^{
                                  [SVProgressHUD showErrorWithStatus:[error.userInfo valueForKey:@"JSONResponseSerializerWithDataKey"]];
                              }];
                          }];

    
    if ([self.tourJoinRequestDelegate respondsToSelector:@selector(dismissTourJoinRequestController)]) {
        [self.tourJoinRequestDelegate dismissTourJoinRequestController];
    }
}


@end
