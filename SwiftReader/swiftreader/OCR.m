//
//  OCR.m
//  swiftreader
//
//  Created by Ethan Roessler  on 9/12/21.
//

#import "OCR.h"
#import <AppKit/AppKit.h>
#import <Vision/Vision.h>
#import <QuartzCore/CoreAnimation.h>
#import <CoreImage/CoreImage.h>
#import "UserPreferences.h"
#import "Statics/UIStyle.h"

#define CLAMP(x, low, high)  (((x) > (high)) ? (high) : (((x) < (low)) ? (low) : (x)))

@implementation OCR

+(CGImageRef)ScreenShotWithWidth:(CGFloat)Width Height:(CGFloat)Height X:(CGFloat)X Y:(CGFloat)Y
{
	CGRect Rect = CGRectMake(X, Y, Width, Height);
	CGImageRef ScreenShot = CGWindowListCreateImage(Rect, kCGWindowListOptionOnScreenOnly, kCGNullWindowID, kCGWindowImageDefault);
	
	return ScreenShot;
}

-(NSString*)RecognizeTextHandlerWithRequest:(VNRequest*)Request Error:(NSError*)NSError
{
	return nil;
}

+(bool)ReadTextWithWidth:(CGFloat)Width Height:(CGFloat)Height X:(CGFloat)X Y:(CGFloat)Y Layer:(CALayer**)Layer StartObservation:(StartObservationBlock)StartObservation StopObservation:(StopObservationBlock)StopObservation Completion:(CompletionBlock)Completion
{
	CALayer* TextRectLayer = [[CALayer alloc] init];
	
	CGRect ScreenRect = CGRectMake(0.f, 0.f, 0.f, 0.f);
	if ([NSScreen mainScreen] != nil)
	{
		ScreenRect = [[NSScreen mainScreen] frame];
		[TextRectLayer setFrame:ScreenRect];
	}
	
	__block CGImageRef Image = [self ScreenShotWithWidth:Width Height:Height X:X Y:Y];
	
	/*
	CGFloat ImageWidth = 0;
	CGFloat ImageHeight = 0;
	if ([[UserPreferences g_UserPreferences] boolForKey:@"ViewRecognizedText"])
	{
		ImageWidth = (CGFloat)CGImageGetWidth(Image);
		ImageHeight = (CGFloat)CGImageGetHeight(Image);
	}
	*/

	CGAffineTransform ScreenTransform = CGAffineTransformIdentity;
	ScreenTransform = CGAffineTransformTranslate(ScreenTransform, 0, ScreenRect.size.height + [[[[[NSApplication sharedApplication] windows] firstObject] contentView] safeAreaInsets].top);
	ScreenTransform = CGAffineTransformScale(ScreenTransform, 1, -1);
	
	CGPoint ImagePos = CGPointApplyAffineTransform((CGPoint){X, Y}, ScreenTransform);
	
	NSDictionary* Options = [[NSDictionary alloc] init];
	VNImageRequestHandler* RequestHandler = [[VNImageRequestHandler alloc] initWithCGImage:Image options:Options];
	
	__block BOOL bIsComplete = false;
	__block NSMutableArray<VNRecognizedText*>* RecognizedText = [[NSMutableArray alloc] init];
	VNRecognizeTextRequest* TextRequest = [[VNRecognizeTextRequest alloc] initWithCompletionHandler:^(VNRequest* Request, NSError* Error) {
		NSArray<VNRecognizedTextObservation*>* Observations = [Request results];
		if (Observations != nil)
		{
			if ([Observations count] > 0)
			{
				for (int i = 0; i < [Observations count]; i++)
				{
					VNRecognizedText* Text = [[Observations[i] topCandidates:1] firstObject];
					[RecognizedText addObject:Text];
					
					// Needs to be more fleshed out
					/*
					if ([[UserPreferences g_UserPreferences] boolForKey:@"ViewRecognizedText"])
					{
						VNRectangleObservation* TextRectObservation = [Text boundingBoxForRange:(NSRange){0, [[Text string] length]} error:nil];
						
						CGSize TranslatedSize = {CLAMP([TextRectObservation boundingBox].size.width * ImageWidth / 2, 20, ImageWidth), CLAMP([TextRectObservation boundingBox].size.height * ImageHeight / 2, 20, ImageHeight)};
						CGPoint TranslatedOrigin = {[TextRectObservation boundingBox].origin.x * ImageWidth / 2.f + ImagePos.x, ([TextRectObservation boundingBox].origin.y) * ImageHeight / 2.f + ImagePos.y - ImageHeight / 2.f};
						
						float MaxFontSize = 300.f;
						NSFont* Font = [NSFont boldSystemFontOfSize:MaxFontSize];
						CGSize FontSize = [[Text string] sizeWithAttributes: @{NSFontAttributeName: Font}];
						while (FontSize.width >= TranslatedSize.width || FontSize.height >= TranslatedSize.height)
						{
							MaxFontSize -= 1.f;
							Font = [NSFont boldSystemFontOfSize:MaxFontSize];
							FontSize = [[Text string] sizeWithAttributes: @{NSFontAttributeName: Font}];
						}
						
						CATextLayer* TextLayer = [[CATextLayer alloc] init];
						[TextLayer setFrame: CGRectMake(TranslatedOrigin.x, TranslatedOrigin.y - ((TranslatedSize.height - FontSize.height)), TranslatedSize.width, TranslatedSize.height)];
						[TextLayer setFontSize: MaxFontSize];
						[TextLayer setAlignmentMode: kCAAlignmentLeft];
						[TextLayer setString: [Text string]];
						[TextLayer setContentsScale: [[NSScreen mainScreen] backingScaleFactor]];
						
						[TextRectLayer addSublayer: TextLayer];
					}
					*/
				}
			}
		}
		
		bIsComplete = true;
	}];
	VNRequestTextRecognitionLevel RecognitionLevel = [[UserPreferences g_UserPreferences] objectForKey:@"TextRecognitionLevel"] == TR_ACCURATE ? VNRequestTextRecognitionLevelAccurate : VNRequestTextRecognitionLevelFast;
	[TextRequest setRecognitionLevel: RecognitionLevel];
	
	NSArray* TextRequests = @[TextRequest];
	if ([RequestHandler performRequests:TextRequests error:nil])
	{
		NSMutableString* Text = [[NSMutableString alloc] init];
		for (int i = 0; i < [RecognizedText count]; i++)
		{
			NSString* t = [[RecognizedText objectAtIndex:i] string];
			[Text appendString:t];
			if (i < [RecognizedText count] - 1)
			{
				[Text appendString:@"\n"];
			}
		}
		
		
		for (CALayer* l in [*Layer sublayers])
		{
			[l removeFromSuperlayer];
		}
		
		// Hacky fix
		CALayer* CompletionLayer = [[CALayer alloc] init];
		[CompletionLayer setFrame:CGRectMake(ImagePos.x, ImagePos.y - Height, Width, Height)];
		[CompletionLayer setBackgroundColor: [[UIStyle ColorTranslucentGrey] CGColor]];
		[CompletionLayer setAllowsEdgeAntialiasing: true];
		
		CABasicAnimation* FadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
		FadeIn.fromValue = [NSNumber numberWithFloat:0.0];
		FadeIn.toValue = [NSNumber numberWithFloat:1.0];
		FadeIn.duration = 0.2;
		FadeIn.autoreverses = false;
		FadeIn.repeatCount = 1;
		FadeIn.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
		[CompletionLayer addAnimation:FadeIn forKey:@"FadeInAnimation"];
		
		[TextRectLayer setNeedsDisplay];
		
		*Layer = TextRectLayer;
		if (Completion != nil)
			Completion(Layer, ImagePos.x, ImagePos.y, Width, Height);
		
		if ([Text length] > 0)
		{
			NSPasteboard* Pasteboard = [NSPasteboard generalPasteboard];
			[Pasteboard clearContents];
			[Pasteboard setString:Text forType:NSPasteboardTypeString];
		}
		return true;
	}
	else
	{
		return false;
	}
}

@end
