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

#import "AWSIoT.h"
#import "AWSIoTData.h"
#import "AWSIoTDataManager.h"
#import "AWSIoTDataModel.h"
#import "AWSIoTDataResources.h"
#import "AWSIoTDataService.h"
#import "AWSIoTManager.h"
#import "AWSIoTModel.h"
#import "AWSIoTResources.h"
#import "AWSIoTService.h"
#import "MQTTDecoder.h"
#import "MQTTEncoder.h"
#import "MQTTMessage.h"
#import "MQTTSession.h"
#import "MQttTxFlow.h"
#import "AWSSRWebSocket.h"

FOUNDATION_EXPORT double AWSIoTVersionNumber;
FOUNDATION_EXPORT const unsigned char AWSIoTVersionString[];

