//
//  OTGuideDetailsViewController.m
//  entourage
//
//  Created by Mihai Ionescu on 05/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTGuideDetailsViewController.h"
#import "UIViewController+menu.h"
#import "OTConsts.h"
#import "OTMailSenderBehavior.h"

@import MessageUI;

@interface OTGuideDetailsViewController () <MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIView* titleView;
@property (nonatomic, weak) IBOutlet UIButton *categoryButton;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailsLabel;
@property (nonatomic, weak) IBOutlet UIButton *addressButton;
@property (nonatomic, weak) IBOutlet UIButton *phoneButton;
@property (nonatomic, weak) IBOutlet UIButton *emailButton;
@property (nonatomic, weak) IBOutlet UIButton *webButton;
@property (nonatomic, weak) IBOutlet UIButton *btnSendMail;
@property (nonatomic, weak) IBOutlet OTMailSenderBehavior *mailSender;

@end

@implementation OTGuideDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.mailSender initialize];
    self.title = OTLocalizedString(@"guideTitle");
    self.navigationController.navigationBarHidden = NO;
    [self setupCloseModal];
    
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUI {
    // Category
    if (self.category != nil) {
        self.titleView.backgroundColor = self.category.color;
        [self.categoryButton setTitle:[@" " stringByAppendingString:self.category.name] forState:UIControlStateNormal];
        [self.categoryButton setImage:[UIImage imageNamed:[NSString stringWithFormat:kPOITransparentImagePrefix, self.category.sid.intValue]] forState:UIControlStateNormal];
    } else {
        self.titleView.hidden = YES;
    }
    // POI
    [self.nameLabel setText:self.poi.name];
    [self.detailsLabel setText:self.poi.details];
    if (self.poi.address != nil && self.poi.address.length > 0) {
        self.addressButton.hidden = NO;
        [self.addressButton setTitle:self.poi.address forState:UIControlStateNormal];
    } else {
        [self.addressButton removeFromSuperview];
    }
    if (self.poi.phone != nil && self.poi.phone.length > 0) {
        self.phoneButton.hidden = NO;
        [self.phoneButton setTitle:[@"Tel: " stringByAppendingString:self.poi.phone] forState:UIControlStateNormal];
    } else {
        [self.phoneButton removeFromSuperview];
    }
    if (self.poi.email != nil && self.poi.email.length > 0) {
        self.emailButton.hidden = NO;
        [self.emailButton setTitle:self.poi.email forState:UIControlStateNormal];
        
    } else {
        [self.emailButton removeFromSuperview];
    }
    if (self.poi.website != nil && self.poi.website.length > 0) {
        self.webButton.hidden = NO;
        [self.webButton setTitle:self.poi.website forState:UIControlStateNormal];
    } else {
        [self.webButton removeFromSuperview];
    }
    self.btnSendMail.layer.borderColor = UIColor.whiteColor.CGColor;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/********************************************************************************/
#pragma mark - Buttons handling

- (IBAction)sendStructureMail:(id)sender {
    [self.mailSender sendStructureMail:[NSString stringWithFormat:OTLocalizedString(@"structure_subject"), self.poi.name]];
}

- (IBAction)showAddress:(id)sender {
    NSString *mapString = [NSString stringWithFormat:@"http://maps.apple.com/?address=%@", [self.poi.address stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    NSURL *mapURL = [NSURL URLWithString:mapString];
    [[UIApplication sharedApplication] openURL:mapURL];
}

- (IBAction)showPhone:(id)sender {
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.path = self.poi.phone;
    components.scheme = @"tel";
    [[UIApplication sharedApplication] openURL:components.URL];
}

- (IBAction)showEmail:(id)sender {
    if (![MFMailComposeViewController canSendMail]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                       message:OTLocalizedString(@"about_email_notavailable")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    MFMailComposeViewController* composeVC = [[MFMailComposeViewController alloc] init];
    composeVC.mailComposeDelegate = self;
    
    // Configure the fields of the interface.
    [composeVC setToRecipients:@[self.poi.email]];
    [composeVC setSubject:@""];
    [composeVC setMessageBody:@"" isHTML:NO];
    
    // Present the view controller modally.
    [self presentViewController:composeVC animated:YES completion:nil];
}

- (IBAction)showWebsite:(id)sender {
    NSString *url = self.poi.website;
    if (![url containsString:@"http"]) {
        url = [NSString stringWithFormat:@"http://%@", url];
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

/********************************************************************************/
#pragma mark - MFMailComposerDelegate

-(void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
