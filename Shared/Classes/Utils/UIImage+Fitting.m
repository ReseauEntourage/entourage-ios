//
//  UIImage+Fitting.m
//

#import "UIImage+Fitting.h"

static inline double radians (double degrees) {return degrees * M_PI/180;}

@implementation UIImage(Fitting)

- (CGSize)sizeForHeight:(CGFloat)height;
{
	CGFloat aspectRatio = (self.size.width/self.size.height);
	return CGSizeMake(height*aspectRatio, height);
}

- (UIImage*) imageOfSquareSize:(CGFloat)squareMarginSize
{
	return [self imageByScalingAndCroppingForSize: CGSizeMake(squareMarginSize,squareMarginSize)];
}

-(UIImage*) imageByScalingAndCroppingForSize:(CGSize)targetSize
{
	UIImage *newImage = nil;        
	CGSize imageSize = self.size;
	CGFloat width = imageSize.width;
	CGFloat height = imageSize.height;
	CGFloat targetWidth = targetSize.width;
	CGFloat targetHeight = targetSize.height;
	CGFloat scaleFactor = 0.0;
	CGFloat scaledWidth = targetWidth;
	CGFloat scaledHeight = targetHeight;
	CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
	
	if (CGSizeEqualToSize(imageSize, targetSize) == NO) 
	{
		CGFloat widthFactor = targetWidth / width;
		CGFloat heightFactor = targetHeight / height;
		
		// scale the image
		if (widthFactor > heightFactor) 
		{
			scaleFactor = widthFactor; // scale to fit height
		}
		else
		{
			scaleFactor = heightFactor; // scale to fit width
		}
		
		scaledWidth  = width * scaleFactor;
		scaledHeight = height * scaleFactor;
		
		// center the image
		if (widthFactor > heightFactor)
		{
			thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
		}
		else 
			if (widthFactor < heightFactor)
			{
				thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
			}
	}       
	
	UIGraphicsBeginImageContext(targetSize);
	
	CGRect thumbnailRect = CGRectZero;
	thumbnailRect.origin = thumbnailPoint;
	thumbnailRect.size.width  = scaledWidth;
	thumbnailRect.size.height = scaledHeight;
	
	[self drawInRect:thumbnailRect];
	
	newImage = UIGraphicsGetImageFromCurrentImageContext();
	if(newImage == nil) 
		NSLog(@"could not scale image");
	
	//pop the context to get back to the default
	UIGraphicsEndImageContext();
	return newImage;
}


@end
