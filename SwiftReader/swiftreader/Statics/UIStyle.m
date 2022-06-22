//
//  UIStyle.m
//  swiftreader
//
//  Created by Ethan Roessler  on 11/4/21.
//

#import "UIStyle.h"

@implementation UIStyle

// Need to find a better work around; colors can't have gestures if they are completely clear
+(NSColor*)ColorClearTouchable
{
	return [NSColor colorWithWhite:0 alpha:0.01];
}

+(NSColor*)ColorTranslucentGrey
{
	return [NSColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.6];
}

+(NSColor*)ColorLightGreen
{
	return [NSColor colorWithRed:0.548 green:0.931 blue:0.599 alpha:1.0];
}

@end
