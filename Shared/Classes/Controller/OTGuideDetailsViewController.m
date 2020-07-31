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
#import "entourage-Swift.h"

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
    [OTAppConfiguration configureNavigationControllerAppearance:self.navigationController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUI {
    // Category
    if (self.category != nil) {
        self.titleView.backgroundColor = self.category.color;
        NSString *catName = self.category.name;
        if ([self.category.name isEqualToString:@"Partenaires"]) {
            catName = OTLocalizedString(@"partners_entourage");
        }
        [self.categoryButton setTitle:[@" " stringByAppendingString:catName] forState:UIControlStateNormal];
        [self.categoryButton setImage:[UIImage imageNamed:[NSString stringWithFormat:kPOITransparentImagePrefix, self.category.sid.intValue]] forState:UIControlStateNormal];
    } else {
        self.titleView.hidden = YES;
    }
    // POI
    NSArray *buttons = @[self.addressButton, self.phoneButton, self.emailButton, self.webButton];
    for (UIButton *button in buttons) {
        [button setTitleColor:[ApplicationTheme shared].primaryNavigationBarTintColor forState:UIControlStateNormal];
    }
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
    [self.mailSender sendStructureMail:[NSString stringWithFormat:OTLocalizedString(@"structure_subject"), self.poi.name, self.poi.sid]];
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
    
    [OTAppConfiguration configureNavigationControllerAppearance:self.navigationController];
    MFMailComposeViewController* composeVC = [[MFMailComposeViewController alloc] init];
    composeVC.mailComposeDelegate = self;
    
    // Configure the fields of the interface.
    [composeVC setToRecipients:@[self.poi.email]];
    [composeVC setSubject:@""];
    [composeVC setMessageBody:@"" isHTML:NO];
    
    [OTAppConfiguration configureMailControllerAppearance:composeVC];
    
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
- (IBAction)action_share:(id)sender {
    NSString * name = self.poi.name;
    NSString * address = (self.poi.address == nil || self.poi.address.length == 0) ? @"" :  [@"Adresse: " stringByAppendingString:self.poi.address];
    NSString * phone = (self.poi.phone == nil  || self.poi.phone.length == 0) ? @"" : [@"Tel: " stringByAppendingString:self.poi.phone];
    NSString * url = ENTOURAGE_BITLY_LINK;
    NSString * message = [NSString stringWithFormat:OTLocalizedString(@"info_share_sms_poi"),name,address,phone,url];
   
    
    NSArray* sharedObjects=[NSArray arrayWithObjects:message,  nil];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:sharedObjects applicationActivities:nil];
    if (@available(iOS 11.0, *)) {
        activityViewController.excludedActivityTypes = @[UIActivityTypePrint,UIActivityTypeAirDrop,UIActivityTypeMarkupAsPDF,UIActivityTypePostToVimeo,UIActivityTypeOpenInIBooks,UIActivityTypePostToFlickr,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll,UIActivityTypePostToTencentWeibo];
    } else {
        activityViewController.excludedActivityTypes = @[UIActivityTypePrint,UIActivityTypeAirDrop,UIActivityTypePostToVimeo,UIActivityTypeOpenInIBooks,UIActivityTypePostToFlickr,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll,UIActivityTypePostToTencentWeibo];
    }
    
    [OTAppConfiguration configureActivityControllerAppearance:nil
                                                        color:[[ApplicationTheme shared] primaryNavigationBarTintColor]];
    
    activityViewController.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        [OTAppConfiguration configureActivityControllerAppearance:nil
                                                            color:[[ApplicationTheme shared] secondaryNavigationBarTintColor]];
    };
    activityViewController.navigationController.navigationBar.tintColor = [[ApplicationTheme shared] primaryNavigationBarTintColor];
    
    [self.navigationController presentViewController:activityViewController animated:true completion:nil];
}

/********************************************************************************/
#pragma mark - MFMailComposerDelegate

-(void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
