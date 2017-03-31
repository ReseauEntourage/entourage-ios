//
//  OTMailSenderBehavior.h
//  entourage
//
//  Created by veronica.gliga on 27/03/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"
#import "OTCloseReason.h"
#import "OTEntourage.h"

@interface OTMailSenderBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet UIViewController *owner;

- (void)sendMailWithSubject:(NSString *)subject andRecipient: (NSString *)recipient;
- (void)sendCloseMail: (OTCloseReason) reason forItem: (OTEntourage *) feedItem;
- (void)sendStructureMail:(NSString *)subject;

@end
