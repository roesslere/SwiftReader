//
//  OCR.h
//  swiftreader
//
//  Created by Ethan Roessler  on 9/12/21.
//

#ifndef OCR_h
#define OCR_h
#import <Foundation/Foundation.h>

@class VNRequest;
@class CALayer;
@class ObservableSnapRectVars;

@interface OCR: NSObject

typedef void (^StartObservationBlock)(void);
typedef void (^StopObservationBlock)(void);
typedef void (^CompletionBlock)(CALayer** OverlayLayer, CGFloat X, CGFloat Y, CGFloat Width, CGFloat Height);

-(NSString*)RecognizeTextHandlerWithRequest:(VNRequest*)Request Error:(NSError*)NSError;
+(bool)ReadTextWithWidth:(CGFloat)Width Height:(CGFloat)Height X:(CGFloat)X Y:(CGFloat)Y Layer:(CALayer**)Layer StartObservation:(StartObservationBlock)StartObservation StopObservation:(StopObservationBlock)StopObservation Completion:(CompletionBlock)Completion;

@end

#endif /* OCR_h */
