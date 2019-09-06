//
//  SettingsViewController.m
//  Puzzlfy
//
//  Created by Youmna on 5/5/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "SettingsViewController.h"
#import "NavigationBarView.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "DBManager.h"
#import "SoundUtilities.h"
#import "GameCenterManager.h"
#import "ViewUtilities.h"
#import "EventsManager.h"
#import "Notifications.h"

@interface SettingsViewController ()

@property (nonatomic) int difficulty;
@property (strong, nonatomic) UIAlertView *alertView;

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)playLoopSound
{
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initButtonStates];
}

- (void)initButtonStates
{
    self.difficulty = [[[[DBManager getInstance] getUser] difficulty] intValue];
    
    switch (self.difficulty) {
        case 0:
            [self.difficutlyBtn setImage: [UIImage imageNamed: DIFFICULTY_EASY_IMG] forState:UIControlStateNormal];
            break;
        case 1:
            [self.difficutlyBtn setImage: [UIImage imageNamed: DIFFICULTY_MEDIUM_IMG] forState:UIControlStateNormal];
            break;
        case 2:
            [self.difficutlyBtn setImage: [UIImage imageNamed: DIFFICULTY_HARD_IMG] forState:UIControlStateNormal];
            break;
        case 3:
            [self.difficutlyBtn setImage: [UIImage imageNamed: DIFFICULTY_SUPER_EASY_IMG] forState:UIControlStateNormal];
            break;
        default:
            [self.difficutlyBtn setImage: [UIImage imageNamed: DIFFICULTY_EASY_IMG] forState:UIControlStateNormal];
            break;
    }
    
    if ([[[[DBManager getInstance] getUser] sound] boolValue]) {
        [self.soundBtn setImage:[UIImage imageNamed: SOUND_ON_IMG] forState:UIControlStateNormal];
        [self.soundBtn setSelected:NO];
    }
    else {
        [self.soundBtn setImage:[UIImage imageNamed: SOUND_OFF_IMG] forState:UIControlStateSelected];
        [self.soundBtn setSelected:YES];
    }
    
    if ([[[[DBManager getInstance] getUser] music] boolValue]) {
        [self.musicBtn setImage: [UIImage imageNamed: MUSIC_ON_IMG] forState:UIControlStateNormal];
        [self.musicBtn setSelected:NO];
    }
    else {
        [self.musicBtn setImage: [UIImage imageNamed: MUSIC_OFF_IMG] forState:UIControlStateSelected];
        [self.musicBtn setSelected:YES];
    }
    
    if ([[[[DBManager getInstance] getUser] showSilhouette] boolValue]) {
        [self.silhouetteToggle setImage: [UIImage imageNamed: SILHOUETTE_ON_IMG] forState:UIControlStateNormal];
        [self.silhouetteToggle setSelected:NO];
    }
    else {
        [self.silhouetteToggle setImage: [UIImage imageNamed: SILHOUETTE_OFF_IMG] forState:UIControlStateSelected];
        [self.silhouetteToggle setSelected:YES];
    }
    
    if ([[[[DBManager getInstance] getUser] showOutlines] boolValue]) {
        [self.outlinesToggle setImage: [UIImage imageNamed: OUTLINE_ON_IMG] forState:UIControlStateNormal];
        [self.outlinesToggle setSelected:NO];
    }
    else {
        [self.outlinesToggle setImage: [UIImage imageNamed: OUTLINE_OFF_IMG] forState:UIControlStateSelected];
        [self.outlinesToggle setSelected:YES];
    }

}

-(void) adjustNavigationBarButtonsVisibility:(NavigationBarView*) bar
{
    [bar.menuButton setHidden:YES];
    [bar.backButton setHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toggleSoundState:(id)sender
{
    [SoundUtilities playSoundWithName:GENERIC_BUTTON_SOUND andFormat:SOUND_TYPE_MP3];
    NSNumber *sound = [[[DBManager getInstance] getUser] sound];
    
    if (![sound boolValue]) {
        [sender setImage: [UIImage imageNamed: SOUND_ON_IMG] forState:UIControlStateNormal];
        [[[DBManager getInstance] getUser] setSound:[NSNumber numberWithBool:YES]];
        [sender setSelected:NO];
    }
    else {
        [sender setImage:[UIImage imageNamed: SOUND_OFF_IMG] forState:UIControlStateSelected];
        [[[DBManager getInstance] getUser] setSound:[NSNumber numberWithBool:NO]];
        [sender setSelected:YES];
    }
    NSError *error;
    [[DBManager getInstance] saveObjectContext:&error];
}

- (IBAction)toggleMusicState:(id)sender
{
    [SoundUtilities playSoundWithName:GENERIC_BUTTON_SOUND andFormat:SOUND_TYPE_MP3];
    NSNumber *music = [[[DBManager getInstance] getUser] music];
    
    if (![music boolValue]) {
        [sender setImage: [UIImage imageNamed: MUSIC_ON_IMG] forState:UIControlStateNormal];
        [[[DBManager getInstance] getUser] setMusic:[NSNumber numberWithBool:YES]];
        [SoundUtilities restorePlayingMainSound];
        [sender setSelected:NO];
    }
    else {
        [sender setImage:[UIImage imageNamed: MUSIC_OFF_IMG] forState:UIControlStateSelected];
        [[[DBManager getInstance] getUser] setMusic:[NSNumber numberWithBool:NO]];
        [sender setSelected:YES];
        [SoundUtilities stopMainSoundFromSettings];
    }
    
    NSError *error;
    [[DBManager getInstance] saveObjectContext:&error];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Yes"]) {
        [self.delegate didDifficultyChange:YES];
        [self toggleDifficulty:self.difficutlyBtn];
        self.showDifficultyAlert = NO;
    }
    else if ([title isEqualToString:@"No"]) {
        
    }
}

- (IBAction)changeDifficulty:(id)sender
{
    if (!self.isGameInPorgress) {
        [self toggleDifficulty:sender];
    }
    else {
        if (self.showDifficultyAlert) {
            self.alertView = [[UIAlertView alloc] initWithTitle:@"Puzzlfy" message:@"This action will reset your current progress. Do it anyway?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveApplicationWillEnterBackgroundNotification) name:APP_WILL_ENTER_BACKGROUND_NOTIFICATION object:nil];
            [self.alertView show];
        }
        else {
            [self toggleDifficulty:sender];
        }
    }
}

- (void)toggleDifficulty:(id)sender
{
    [SoundUtilities playSoundWithName:GENERIC_BUTTON_SOUND andFormat:SOUND_TYPE_MP3];
    switch (self.difficulty) {
        case 0:
            [sender setImage: [UIImage imageNamed: DIFFICULTY_MEDIUM_IMG] forState:UIControlStateNormal];
            self.difficulty = DIFFICULTY_MEDIUM;
            [[[DBManager getInstance] getUser] setDifficulty: [NSNumber numberWithInt:self.difficulty]];
            break;
        case 1:
            [sender setImage: [UIImage imageNamed: DIFFICULTY_HARD_IMG] forState:UIControlStateNormal];
            self.difficulty = DIFFICULTY_HARD;
            [[[DBManager getInstance] getUser] setDifficulty: [NSNumber numberWithInt:self.difficulty]];
            break;
        case 2:
            [sender setImage: [UIImage imageNamed: DIFFICULTY_SUPER_EASY_IMG] forState:UIControlStateNormal];
            self.difficulty = DIFFICULTY_SUPER_EASY;
            [[[DBManager getInstance] getUser] setDifficulty: [NSNumber numberWithInt:self.difficulty]];
            break;
        case 3:
            [sender setImage: [UIImage imageNamed: DIFFICULTY_EASY_IMG] forState:UIControlStateNormal];
            self.difficulty = DIFFICULTY_EASY;
            [[[DBManager getInstance] getUser] setDifficulty: [NSNumber numberWithInt:self.difficulty]];
            break;
    }
    
    NSError *error;
    [[DBManager getInstance] saveObjectContext:&error];
}

- (IBAction)openAchievements:(id)sender
{
    [EventsManager reportEventWithType:EVENT_ACHIEVEMENTS_CLICKED withParameters:nil];
    [SoundUtilities playSoundWithName:GENERIC_BUTTON_SOUND andFormat:SOUND_TYPE_MP3];
    [self showLeaderboardAndAchievements:YES];
}

- (IBAction)toggleSihoutteState:(id)sender
{
    [SoundUtilities playSoundWithName:GENERIC_BUTTON_SOUND andFormat:SOUND_TYPE_MP3];
    NSNumber *silhouette = [[[DBManager getInstance] getUser] showSilhouette];
    
    if (![silhouette boolValue]) {
        [sender setImage: [UIImage imageNamed: SILHOUETTE_ON_IMG] forState:UIControlStateNormal];
        [[[DBManager getInstance] getUser] setShowSilhouette:[NSNumber numberWithBool:YES]];
        [sender setSelected:NO];
    }
    else {
        [sender setImage:[UIImage imageNamed: SILHOUETTE_OFF_IMG] forState:UIControlStateSelected];
        [[[DBManager getInstance] getUser] setShowSilhouette:[NSNumber numberWithBool:NO]];
        [sender setSelected:YES];
    }
    
    NSError *error;
    [[DBManager getInstance] saveObjectContext:&error];
}

- (IBAction)toggleOutlineState:(id)sender
{
    [SoundUtilities playSoundWithName:GENERIC_BUTTON_SOUND andFormat:SOUND_TYPE_MP3];
    NSNumber *outlines = [[[DBManager getInstance] getUser] showOutlines];
    
    if (![outlines boolValue]) {
        [sender setImage: [UIImage imageNamed: OUTLINE_ON_IMG] forState:UIControlStateNormal];
        [[[DBManager getInstance] getUser] setShowOutlines:[NSNumber numberWithBool:YES]];
        [sender setSelected:NO];
    }
    else {
        [sender setImage:[UIImage imageNamed: OUTLINE_OFF_IMG] forState:UIControlStateSelected];
        [[[DBManager getInstance] getUser] setShowOutlines:[NSNumber numberWithBool:NO]];
        [sender setSelected:YES];
    }
    
    NSError *error;
    [[DBManager getInstance] saveObjectContext:&error];
}

- (IBAction)orderPhotoPrint:(id)sender
{
    [EventsManager reportEventWithType:EVENT_ORDER_PRINT_CLICKED withParameters:nil];
    [SoundUtilities playSoundWithName:GENERIC_BUTTON_SOUND andFormat:SOUND_TYPE_MP3];
    [ViewUtilities presentInformation:@"Coming Soon!"];
}

- (IBAction)infoButtonClicked:(id)sender
{
    [SoundUtilities playSoundWithName:GENERIC_BUTTON_SOUND andFormat:SOUND_TYPE_MP3];
}

#pragma mark - Leaderboard and Achievemets

-(void)showLeaderboardAndAchievements:(BOOL)shouldShowLeaderboard{
    GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
    
    gcViewController.gameCenterDelegate = self;
    
    if (shouldShowLeaderboard) {
        gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
        gcViewController.leaderboardIdentifier = [[GameCenterManager getInstance] leaderboardIdentifier];
    }
    else{
        gcViewController.viewState = GKGameCenterViewControllerStateAchievements;
    }
    
    [self presentViewController:gcViewController animated:YES completion:nil];
}

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)recieveApplicationWillEnterBackgroundNotification
{
    if(self.alertView && !self.alertView.hidden)
    {
        [self.alertView dismissWithClickedButtonIndex:1 animated:NO];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_WILL_ENTER_BACKGROUND_NOTIFICATION object:nil];
}


@end
