//
//  OTTourJoinRequestViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 01/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTourJoinRequestViewController.h"

@interface OTTourJoinRequestViewController ()

@property (nonatomic, weak) IBOutlet UILabel *greetingLabel;

@end

@implementation OTTourJoinRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUI {
    NSDictionary *lightAttrs = @{NSFontAttributeName : [UIFont systemFontOfSize:17 weight:UIFontWeightLight]};
    NSDictionary *mediumAttrs = @{NSFontAttributeName : [UIFont systemFontOfSize:17 weight:UIFontWeightMedium]};
    NSAttributedString *merciAttrString = [[NSAttributedString alloc] initWithString:@"MERCI!\n\n"attributes:mediumAttrs];
    NSAttributedString *cetteTourAttrString = [[NSAttributedString alloc] initWithString:@"Cette maraude étant privée, \nvotre demande a été \ntransmise au créateur.\n\n" attributes:lightAttrs];
    NSAttributedString *messageAttrString = [[NSAttributedString alloc] initWithString:@"Si vous le souhaitez, \nenvoyez-lui un message:" attributes:mediumAttrs];
    
    
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
    
    
    if ([self.tourJoinRequestDelegate respondsToSelector:@selector(dismissTourJoinRequestController)]) {
        [self.tourJoinRequestDelegate dismissTourJoinRequestController];
    }
}


@end
