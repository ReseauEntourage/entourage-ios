//
//  OTMailSenderBehavior.h
//  entourage
//
//  Created by veronica.gliga on 27/03/2017.
//  Copyright © 2017 Entourage. All rights reserved.
//

#import "OTBehavior.h"
#import "OTCloseReason.h"
#import "OTEntourage.h"

@interface OTMailSenderBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet UIViewController *owner;
@property (nonatomic, strong) NSString *successMessage;

- (BOOL)sendMailWithSubject:(NSString *)subject andRecipient: (NSString *)recipient;
- (BOOL)sendCloseMail: (OTCloseReason) reason forItem: (OTEntourage *) feedItem;
- (BOOL)sendStructureMail:(NSString *)subject;
- (BOOL)sendMailWithSubject:(NSString *)subject andRecipient:(NSString *)recipient body:(NSString*)body;

@end
