#import "OTRoundedButton.h"
#import "entourage-Swift.h"

@implementation OTRoundedButton

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self == nil) return nil;

    _inverted = NO;

    return self;
}

#pragma mark - Overrides

- (void)layoutSubviews {
    [self setupColors];
    [self setupRoundedCorners];
    [super layoutSubviews];
}

- (void)setInverted:(BOOL)inverted {
    _inverted = inverted;
    [self setupColors];
}

#pragma mark - Customization

- (void)setupRoundedCorners {
    self.layer.cornerRadius = self.bounds.size.height / 2;
}

- (void)setupColors {
    ApplicationTheme *theme = [ApplicationTheme shared];

    if (self.inverted == NO) {
        self.backgroundColor = theme.primaryNavigationBarTintColor;
        self.tintColor       = theme.secondaryNavigationBarTintColor;
    } else {
        self.backgroundColor = theme.secondaryNavigationBarTintColor;
        self.tintColor       = theme.primaryNavigationBarTintColor;
    }
}

@end
