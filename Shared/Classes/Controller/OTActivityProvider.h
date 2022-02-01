//
//  OTActivityProvider.h
//  entourage
//
//  Created by veronica.gliga on 08/12/2017.
//  Copyright © 2017 Entourage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTActivityProvider : UIActivityItemProvider

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *emailBody;
@property (nonatomic, strong) NSString *emailSubject;

@end
