//
//  OTDebugLog.m
//  entourage
//
//  Created by sergiu buceac on 10/31/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTDebugLog.h"
#import "SVProgressHUD.h"
#import "OTDeepLinkService.h"
#import "OTAppConfiguration.h"
#import "entourage-Swift.h"

@import MessageUI;

@interface OTDebugLog () <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSString *logPath;

@end

@implementation OTDebugLog

- (instancetype)init {
    self = [super init];
    if(self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        self.logPath = [documentsDirectory stringByAppendingPathComponent:@"EMA.log"];
    }
    return self;
}

+ (OTDebugLog*)sharedInstance {
    static OTDebugLog* sharedInstance;
    static dispatch_once_t debugLogToken;
    dispatch_once(&debugLogToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (void)log:(NSString *)message {
    NSLog(@"\nLOG - %@", message);
}

- (void)setConsoleOutput {

    if (![[OTAppConfiguration sharedInstance].environmentConfiguration runsOnProduction]) {
        freopen([self.logPath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
    }
}

- (void)sendEmail {
    
    if ([[OTAppConfiguration sharedInstance].environmentConfiguration runsOnProduction]) {
        return;
    }

    if(![MFMailComposeViewController canSendMail]) {
        [SVProgressHUD showErrorWithStatus:@"No mail client to send mail with"];
        return;
    }
    
    NSArray *toRecipents = [NSArray arrayWithObject:@"lazar.sidor@tecknoworks.com"];
    
    MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
    mailer.mailComposeDelegate = self;
    [mailer setSubject:@"Debug log"];
    [mailer setMessageBody:@"Check attachment" isHTML:NO];
    [mailer setToRecipients:toRecipents];
    
    NSData *fileData = [NSData dataWithContentsOfFile:self.logPath];
    [mailer addAttachmentData:fileData mimeType:@"doc" fileName:@"EMA.log"];
    
    UIViewController *topVC = [[OTDeepLinkService new] getTopViewController];
    [topVC presentViewController:mailer animated:YES completion:NULL];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
