//
//  SoundUtilities.h
//  Puzzlfy
//
//  Created by Youmna on 5/25/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SoundUtilities : NSObject
+(void) playSoundWithName:(NSString*)name andFormat:(NSString*)format;
+(void) playSoundWithName:(NSString*)name andFormat:(NSString*)format isLooping:(BOOL)looping;
+(void) playAchievementsSound;
+(void) stopSound;
+(void) playMainSoundWithName:(NSString*)name;
+(void) restorePlayingMainSound;
+(void) stopMainSound;
+(void) stopMainSoundFromSettings;
+(void) playIdleSound;
@end
