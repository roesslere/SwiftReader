//
//  UserPreferences.h
//  swiftreader
//
//  Created by Ethan Roessler  on 2/13/22.
//

#ifndef Preferences_h
#define Preferences_h
#import <Foundation/Foundation.h>


@interface UserPreferences: NSUserDefaults

typedef enum TextRecognitionLevel: int
{
	TR_ACCURATE,
	TR_FAST
} TextRecognitionLevel;

+(NSUserDefaults*)g_UserPreferences;

@end

#endif /* Preferences_h */
