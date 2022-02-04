//
//  OTAlertViewBehavior.m
//  entourage
//
//  Created by veronica.gliga on 07/03/2017.
//  Copyright © 2017 Entourage. All rights reserved.
//

#import "OTAlertViewBehavior.h"
#import "OTConsts.h"

@interface OTAlertViewBehavior ()

@property (nonatomic, strong) NSMutableArray<UIAlertAction *> *alertActions;

@end

@implementation OTAlertViewBehavior

- (void)awakeFromNib {
    [super awakeFromNib];
    self.alertActions = [NSMutableArray new];
}

- (void)addAction:(NSString *)title handler:(void (^)(UIAlertAction*))handler {
    [self.alertActions addObject:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:handler]];
}

- (void)presentOnViewController:(UIViewController*)viewController {
    if(self.alertActions.count == 0)
        return;
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:self.title
                                                                        message:self.content
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    for (UIAlertAction *action in self.alertActions) {
        [controller addAction:action];
    }

    [viewController presentViewController:controller animated:YES completion:nil];
}

+ (void)setupOngoingCreateEntourageWithAction:(OTAlertViewBehavior *)action {
    action.title = OTLocalizedString(@"tour_ongoing");
    action.content = [NSString stringWithFormat:OTLocalizedString(@"confirm_entourage_create"), [OTLocalizedString(@"action") lowercaseString]];
}

@end
