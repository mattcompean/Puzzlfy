//
//  SoundUtilities.m
//  Puzzlfy
//
//  Created by Youmna on 5/25/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "SoundUtilities.h"
#import <AVFoundation/AVFoundation.h>
#import "DBManager.h"
#import "Constants.h"

@implementation SoundUtilities
static AVAudioPlayer *audioPlayer;
static AVAudioPlayer *achievementsPlayer;
static AVAudioPlayer *mainAudioPlayer;
static NSString *currentMainSoundName;

+(void) playSoundWithName:(NSString*)name andFormat:(NSString*)format
{
    [SoundUtilities playSoundWithName:name andFormat:format isLooping:NO];
}

+(void) playSoundWithName:(NSString*)name andFormat:(NSString*)format isLooping:(BOOL)looping
{
    if([[[[DBManager getInstance] getUser] sound]boolValue])
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:format];
        audioPlayer =[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
        if(looping)
            [audioPlayer setNumberOfLoops:-1];
        [audioPlayer play];
    }
}

+(void) playAchievementsSound
{
    if([[[[DBManager getInstance] getUser] sound]boolValue])
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:SOUND_ACHIEVEMENT ofType:SOUND_TYPE_MP3];
        achievementsPlayer =[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
        [achievementsPlayer play];
    }
}

+(void) stopSound
{
    if(audioPlayer && [audioPlayer isPlaying])
        [audioPlayer stop];
}

+(void) restorePlayingMainSound
{
    if(currentMainSoundName)
        [SoundUtilities playMainSoundWithName:currentMainSoundName];
}

+(void) playMainSoundWithName:(NSString*)name
{
    if([[[[DBManager getInstance] getUser] music]boolValue])
    {
        if([SoundUtilities isMainSoundPlayingWithName:name])
            return;
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"mp3"];
        mainAudioPlayer =[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
        [mainAudioPlayer play];
        [mainAudioPlayer setVolume:0.2];
        [mainAudioPlayer setNumberOfLoops:-1];
    }
    currentMainSoundName = name;
}

+(void) playIdleSound
{
    if([[[[DBManager getInstance] getUser] sound]boolValue])
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"puzzlfy-idle" ofType:@"mp3"];
        audioPlayer =[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
        [audioPlayer play];
        [audioPlayer setNumberOfLoops:-1];
    }
}

+(BOOL) isMainSoundPlayingWithName:(NSString*)name
{
    if(mainAudioPlayer && [name isEqualToString:currentMainSoundName])
        return [mainAudioPlayer isPlaying];
    return NO;
}

+(void) stopMainSound
{
    [SoundUtilities stopMainSoundFromSettings];
    currentMainSoundName = nil;
}

+(void) stopMainSoundFromSettings
{
    if(mainAudioPlayer && [mainAudioPlayer isPlaying])
        [mainAudioPlayer stop];
}


@end
