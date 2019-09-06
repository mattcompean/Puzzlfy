//
//  StickerImageView.m
//  Puzzlfy
//
//  Created by Youmna on 5/18/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "StickerImageView.h"
#import "Constants.h"
#import "Notifications.h"
#import "ViewUtilities.h"
#import "SoundUtilities.h"

@implementation StickerImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)pauseVideo:(id)sender
{
    [SoundUtilities playSoundWithName:GENERIC_BUTTON_SOUND andFormat:SOUND_TYPE_MP3];
    NSDictionary *data;
    if ([sender isSelected]) {
        [sender setImage: [UIImage imageNamed: PAUSE_IMG] forState:UIControlStateNormal];
        data = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt: PLAYER_PLAY], @"action", nil];
        [sender setSelected:NO];
    }
    else {
        [sender setImage: [UIImage imageNamed: PLAY_IMG] forState:UIControlStateSelected];
        data = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt: PLAYER_PAUSE], @"action", nil];
        [sender setSelected:YES];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:PLAYER_ACTIONS_NOTIFICATION object:data];
}

- (IBAction)replayVideo:(id)sender
{
    [SoundUtilities playSoundWithName:GENERIC_BUTTON_SOUND andFormat:SOUND_TYPE_MP3];
    [self.videoPlayBtn setImage: [UIImage imageNamed: PAUSE_IMG] forState:UIControlStateNormal];
    [self.videoPlayBtn setSelected:NO];
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt: PLAYER_RESTART], @"action", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:PLAYER_ACTIONS_NOTIFICATION object:data];
}
@end
