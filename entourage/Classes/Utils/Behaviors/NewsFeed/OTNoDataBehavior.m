//
//  OTNoDataBehavior.m
//  entourage
//
//  Created by sergiu buceac on 11/15/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTNoDataBehavior.h"
#import "OTConsts.h"
#import "NSAttributedString+OTBuilder.h"

@interface OTNoDataBehavior ()

@property (nonatomic, strong) NSAttributedString *noDataGuideText;
@property (nonatomic, strong) NSAttributedString *noDataEntourageText;

@end

@implementation OTNoDataBehavior

- (void)initialize {
    [self loadNoDataTexts];
    self.txtNoData.attributedText = self.noDataEntourageText;
}

- (void)closePopup:(id)sender {
    [self togglePopupOpen:NO];
}

- (void)switchedToNewsfeeds {
    self.txtNoData.attributedText = self.noDataEntourageText;
}

- (void)switchedToGuide {
    self.txtNoData.attributedText = self.noDataGuideText;
}

- (void)showNoData {
    [self togglePopupOpen:YES];
}

- (void)hideNoData {
    [self togglePopupOpen:NO];
}

#pragma mark - private methods

- (void)togglePopupOpen:(BOOL)open {
    self.noDataPopup.hidden = !open;
}

- (void)loadNoDataTexts {
    self.noDataEntourageText = [NSAttributedString buildLinkForTextView:self.txtNoData withText:OTLocalizedString(@"no_data_entourages") toLinkText:@"" withLink:@""];
    self.noDataGuideText = [NSAttributedString buildLinkForTextView:self.txtNoData withText:OTLocalizedString(@"no_data_guide") toLinkText:OTLocalizedString(@"no_data_guide_link") withLink:NO_GIUDE_DATA_LINK];
}

@end
