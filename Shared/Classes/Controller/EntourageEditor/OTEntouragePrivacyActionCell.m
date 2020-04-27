//
//  OTEntouragePrivacyActionCell.m
//  entourage
//
//  Created by Jr on 01/04/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

#import "OTEntouragePrivacyActionCell.h"

@implementation OTEntouragePrivacyActionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.ui_image_circle_public.layer.cornerRadius = self.ui_image_circle_public.frame.size.width / 2;
    self.ui_image_circle_public.layer.borderWidth = 1;
    self.ui_image_circle_public.layer.borderColor = [[UIColor colorWithDisplayP3Red:0.29 green:0.29 blue:0.29 alpha:1.0]CGColor];
    
    self.ui_image_circle_private.layer.cornerRadius = self.ui_image_circle_private.frame.size.width / 2;
    self.ui_image_circle_private.layer.borderWidth = 1;
    self.ui_image_circle_private.layer.borderColor = [[UIColor colorWithDisplayP3Red:0.29 green:0.29 blue:0.29 alpha:1.0]CGColor];
    
    self.ui_image_circle_fill_public.layer.cornerRadius = self.ui_image_circle_fill_public.frame.size.width / 2;
    self.ui_image_circle_fill_public.layer.backgroundColor = [[UIColor colorWithDisplayP3Red:0.29 green:0.29 blue:0.29 alpha:1.0]CGColor];
    
    self.ui_image_circle_fill_private.layer.cornerRadius = self.ui_image_circle_fill_private.frame.size.width / 2;
    self.ui_image_circle_fill_private.layer.backgroundColor = [[UIColor colorWithDisplayP3Red:0.29 green:0.29 blue:0.29 alpha:1.0]CGColor];
    
    [self.ui_label_public setText:OTLocalizedString(@"action_title_public")];
    [self.ui_label_private setText:OTLocalizedString(@"action_title_private")];
    [self.ui_label_description_public setText:OTLocalizedString(@"action_description_public")];
    [self.ui_label_description_private setText:OTLocalizedString(@"action_description_private")];
    
    [self changeSelectionIsPublic:YES];
    
}

-(void)changeSelectionIsPublic:(BOOL)isPublic {
    if (!isPublic) {
        [self.ui_image_circle_fill_private setHidden:NO];
        [self.ui_image_circle_fill_public setHidden:YES];
        self.ui_label_private.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        self.ui_label_public.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
        self.ui_label_description_private.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        self.ui_label_description_public.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
    }
    else {
        [self.ui_image_circle_fill_private setHidden:YES];
        [self.ui_image_circle_fill_public setHidden:NO];
        
        self.ui_label_private.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
        self.ui_label_public.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        self.ui_label_description_private.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
        self.ui_label_description_public.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    }
}

-(void)setActionDelegate:(id<OTAddEditEntourageDelegate>)delegate isPublic:(BOOL) isPublic {
    if ([delegate conformsToProtocol:@protocol(OTAddEditEntourageDelegate)]) {
        self.delegate = delegate;
    }
    
    [self changeSelectionIsPublic:isPublic];
}
//MARK: - IBActions -
- (IBAction)action_select_public:(id)sender {
    [self changeSelectionIsPublic:YES];
    [self.delegate editEntourageActionChangePrivacyPublic:YES];
}

- (IBAction)action_select_private:(id)sender {
    [self changeSelectionIsPublic:NO];
    [self.delegate editEntourageActionChangePrivacyPublic:NO];
}

@end
