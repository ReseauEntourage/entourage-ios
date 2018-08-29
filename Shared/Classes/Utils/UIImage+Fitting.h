//
//  UIImage+Fitting.h
//

#import <Foundation/Foundation.h>


@interface UIImage(Fitting)

- (CGSize)sizeForHeight:(CGFloat)height;
- (UIImage*) imageOfSquareSize:(CGFloat)squareMarginSize;
-(UIImage*) imageByScalingAndCroppingForSize:(CGSize)targetSize;

@end
