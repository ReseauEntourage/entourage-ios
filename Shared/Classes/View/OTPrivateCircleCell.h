//
//  OTPrivateCircleCell.h
//  entourage
//
//  Created by Smart Care on 23/05/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OTPrivateCircleCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIButton *btnProfile;
@property (nonatomic, weak) IBOutlet UILabel *lblDisplayName;

- (void)configureWithTitle:(NSString*)title url:(NSString*)url;
@end
