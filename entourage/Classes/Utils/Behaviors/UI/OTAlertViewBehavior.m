//
//  OTAlertViewBehavior.m
//  entourage
//
//  Created by veronica.gliga on 07/03/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTAlertViewBehavior.h"

@interface OTAlertViewBehavior () <UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *buttonTitles;
@property (nonatomic, strong) NSMutableArray *buttonActions;

@end

@implementation OTAlertViewBehavior

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.buttonTitles = [NSMutableArray new];
    self.buttonActions = [NSMutableArray new];
}

- (void)addAction:(NSString *)title delegate:(void (^)())delegate {
    [self.buttonTitles addObject:title];
    [self.buttonActions addObject:delegate];
}

- (void)show {
    if(self.buttonTitles.count == 0)
        return;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.title message:self.content delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    for (int i = 0; i< self.buttonTitles.count; i++)
        [alert addButtonWithTitle:self.buttonTitles[i]];
    [alert show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    void (^action)() = self.buttonActions[buttonIndex];
    action();
}

@end
