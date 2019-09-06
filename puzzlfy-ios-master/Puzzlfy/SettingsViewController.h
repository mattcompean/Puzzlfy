//
//  SettingsViewController.h
//  Puzzlfy
//
//  Created by Youmna on 5/5/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "PuzzlfyParentViewController.h"
#import "SettingsProtocol.h"
#import <GameKit/GameKit.h>

@interface SettingsViewController : PuzzlfyParentViewController <UIAlertViewDelegate, GKGameCenterControllerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *difficutlyBtn;
@property (strong, nonatomic) IBOutlet UIButton *soundBtn;
@property (strong, nonatomic) IBOutlet UIButton *musicBtn;
@property (strong, nonatomic) IBOutlet UIButton *achievementsBtn;
@property (strong, nonatomic) IBOutlet UIButton *silhouetteToggle;
@property (strong, nonatomic) IBOutlet UIButton *outlinesToggle;
@property (nonatomic) BOOL isGameInPorgress;
@property (nonatomic) BOOL showDifficultyAlert;
@property (strong, nonatomic) id<SettingsProtocol>delegate;

- (IBAction)toggleSoundState:(id)sender;
- (IBAction)toggleMusicState:(id)sender;
- (IBAction)changeDifficulty:(id)sender;
- (IBAction)openAchievements:(id)sender;
- (IBAction)toggleSihoutteState:(id)sender;
- (IBAction)toggleOutlineState:(id)sender;
- (IBAction)orderPhotoPrint:(id)sender;
- (IBAction)infoButtonClicked:(id)sender;

@end
