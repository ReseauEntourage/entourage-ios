#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AWSLambda.h"
#import "AWSLambdaInvoker.h"
#import "AWSLambdaModel.h"
#import "AWSLambdaResources.h"
#import "AWSLambdaService.h"

FOUNDATION_EXPORT double AWSLambdaVersionNumber;
FOUNDATION_EXPORT const unsigned char AWSLambdaVersionString[];

