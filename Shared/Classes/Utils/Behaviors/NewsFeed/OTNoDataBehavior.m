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
#import "entourage-Swift.h"

@interface OTNoDataBehavior ()

@property (nonatomic, strong) NSAttributedString *noDataGuideText;
@property (nonatomic, strong) NSAttributedString *noEventsText;
@property (nonatomic, strong) NSAttributedString *noDataEntourageText;
@property (nonatomic, assign) BOOL isGuide;

@end

@implementation OTNoDataBehavior

static bool guideClosed = NO;
static bool entourageClosed = NO;

- (void)initialize {
    self.isGuide = NO;
    [self loadNoDataTexts];
    self.txtNoData.attributedText = self.noDataEntourageText;
    self.noDataPopup.backgroundColor = [ApplicationTheme shared].backgroundThemeColor;
}

- (void)closePopup:(id)sender {
    if(self.isGuide)
        guideClosed = YES;
    else
        entourageClosed = YES;
    [self togglePopupOpen:NO];
}

- (void)switchedToNewsfeeds {
    self.isGuide = NO;
    self.txtNoData.attributedText = self.noDataEntourageText;
}

- (void)switchedToGuide {
    self.isGuide = YES;
    self.txtNoData.attributedText = self.noDataGuideText;
}

- (void)switchedToEvents {
    self.isGuide = NO;
    self.txtNoData.attributedText = self.noEventsText;
}

- (void)switchedToEncounters {
    self.isGuide = NO;
    self.txtNoData.attributedText = self.noDataEntourageText; //TODO: mettre les bons textes si vide ?
}

- (void)showNoData {
    if (self.isGuide && guideClosed) {
        return;
    }
    
    if (!self.isGuide && entourageClosed) {
        return;
    }
    
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
    self.noDataEntourageText = [NSAttributedString buildLinkForTextView:self.txtNoData
                                                               withText:OTLocalizedString(@"no_data_entourages")
                                                             toLinkText:@""
                                                               withLink:@""];
    
    self.noDataGuideText = [NSAttributedString buildLinkForTextView:self.txtNoData
                                                           withText:OTLocalizedString(@"no_data_guide")
                                                         toLinkText:OTLocalizedString(@"no_data_guide_link") withLink:NO_GIUDE_DATA_LINK];
    
    self.noEventsText = [NSAttributedString buildLinkForTextView:self.txtNoData
                                                        withText:OTLocalizedString(@"no_data_events")
                                                      toLinkText:@""
                                                        withLink:@""];
}

@end
