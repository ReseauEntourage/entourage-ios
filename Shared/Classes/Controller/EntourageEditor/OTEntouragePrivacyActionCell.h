//
//  OTEntouragePrivacyActionCell.h
//  entourage
//
//  Created by Jr on 01/04/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTAddEditEntourageDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface OTEntouragePrivacyActionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *ui_image_circle_public;
@property (weak, nonatomic) IBOutlet UIImageView *ui_image_circle_fill_public;

@property (weak, nonatomic) IBOutlet UIImageView *ui_image_circle_private;
@property (weak, nonatomic) IBOutlet UIImageView *ui_image_circle_fill_private;
@property (weak, nonatomic) IBOutlet UILabel *ui_label_public;
@property (weak, nonatomic) IBOutlet UILabel *ui_label_private;
@property (weak, nonatomic) IBOutlet UILabel *ui_label_description_public;
@property (weak, nonatomic) IBOutlet UILabel *ui_label_description_private;


@property (weak, nonatomic) IBOutlet UILabel *ui_label_title_alone;
@property (weak, nonatomic) IBOutlet UILabel *ui_label_description_alone;

@property(weak,nonatomic) id<OTAddEditEntourageDelegate> delegate;

- (void)setActionDelegate:(id<OTAddEditEntourageDelegate>) delegate isPublic:(BOOL) isPublic;

@end



NS_ASSUME_NONNULL_END
