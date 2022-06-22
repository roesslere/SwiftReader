//
//  UserPreferences.m
//  swiftreader
//
//  Created by Ethan Roessler  on 2/13/22.
//

#import "UserPreferences.h"

static TextRecognitionLevel RecognitionLevel = TR_ACCURATE;

@implementation UserPreferences

+(NSUserDefaults*)g_UserPreferences
{
	static UserPreferences* g_UserPreferences = nil;
	if (!g_UserPreferences)
	{
		g_UserPreferences = [[UserPreferences alloc] init];
		
		// Initialize settings if they don't exist
		if ([g_UserPreferences objectForKey:@"bPlayTutorial"] == nil)
		{
			[g_UserPreferences setBool:true forKey:@"bPlayTutorial"];
		}
		if ([g_UserPreferences objectForKey:@"bLaunchAtLogin"] == nil)
		{
			[g_UserPreferences setBool:true forKey:@"bLaunchAtLogin"];
		}
		if ([g_UserPreferences objectForKey:@"bViewRecognizedText"] == nil)
		{
			[g_UserPreferences setBool:false forKey:@"bViewRecognizedText"];
		}
		if ([g_UserPreferences objectForKey:@"TextRecognitionLevel"] == nil)
		{
			[g_UserPreferences setObject:@(RecognitionLevel) forKey:@"TextRecognitionLevel"];
		}
		if ([g_UserPreferences objectForKey:@"UIColor1"] == nil)
		{
			[g_UserPreferences setObject:@"#FFFFFF" forKey:@"UIColor1"];
		}
		if ([g_UserPreferences objectForKey:@"UIColor2"] == nil)
		{
			[g_UserPreferences setObject:@"#FFFFFF" forKey:@"UIColor2"];
		}
	}
	
	return g_UserPreferences;
}

@end
