//
//  OTEntourageEditItemImageCell.h
//  entourage
//
//  Created by sergiu.buceac on 17/05/2017.
//  Copyright © 2017 Entourage. All rights reserved.
//

#import "OTEntourageEditItemCell.h"

@interface OTEntourageEditItemImageCell : OTEntourageEditItemCell

@property (nonatomic, weak) IBOutlet UIImageView *itemImageView;

- (void)configureWith:(NSString *)title andText:(NSString *)description andImageName:(NSString *)imageName;

@end
