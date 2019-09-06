//
//  GameCenterManager.m
//  Puzzlfy
//
//  Created by Adham Aboul Einein on 5/21/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "GameCenterManager.h"
#import "ViewUtilities.h"
#import "DBManager.h"
#import "AchievementsNames.h"

@implementation GameCenterManager

+ (GameCenterManager *)getInstance {
	static GameCenterManager *sharedInstance;
	if (!sharedInstance) {
		sharedInstance = [[GameCenterManager alloc] init];
	}
	return sharedInstance;
}

-(void)authenticateLocalPlayer{
    // Instantiate a GKLocalPlayer object to use for authenticating a player.
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil) {
            self.gameCenterEnabled = NO;
        }
        else{
            if ([GKLocalPlayer localPlayer].authenticated) {
                [self checkUserAchievementsState:[[GKLocalPlayer localPlayer] playerID]];
                
                self.gameCenterEnabled = YES;
                
                // Get the default leaderboard identifier.
                [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
                    
                    if (error != nil) {
                        NSLog(@"%@", [error localizedDescription]);
                    }
                    else{
                        self.leaderboardIdentifier = leaderboardIdentifier;
                    }
                }];
            }
            else {
                self.gameCenterEnabled = NO;
            }
        }
    };
}

- (void)checkUserAchievementsState:(NSString *)newUserID
{
    switch ([self didUserChange:newUserID]) {
        // User was not logged in before
        case 0:
            [self syncUserAchievements];
            break;
        // User did change
        case 1:
            [self resetLocalUserAchievements];
            break;
        // User didn't change, sync achievements to handle if user was offline or logged out then logged in again
        case 2:
            [self syncUserAchievements];
            break;
        default:
            break;
    }
}

- (void)resetLocalUserAchievements
{
    [[DBManager getInstance]setNumberOfSolvedPuzzles:0];
    [[DBManager getInstance]setMediumPuzzleAchievement:NO];
    [[DBManager getInstance]setHardPuzzleAchievement:NO];
    [[DBManager getInstance]setStickersAchievement:NO];
    [[DBManager getInstance]setTakePhotoAchievement:NO];
    [[DBManager getInstance]setTakeVideoAchievement:NO];
    
    NSError *error;
    [[DBManager getInstance] saveObjectContext:&error];
}

- (void)syncUserAchievements
{
    if ([[DBManager getInstance]isMediumPuzzleAchievementUnlocked]) {
        [self updateAchievementWithIdentifier:[NSArray arrayWithObjects:ACHIEVEMENT_MASTER_SPILSBERRY, ACHIEVEMENT_MASTER_SPILSBERRY_TITLE, nil] percentComplete:100 showBanner:NO];
    }
    if ([[DBManager getInstance]isHardPuzzleAchievementUnlocked]) {
        [self updateAchievementWithIdentifier:[NSArray arrayWithObjects:ACHIEVEMENT_PROFESSOR_SPILSBERRY, ACHIEVEMENT_PROFESSOR_SPILSBERRY_TITLE, nil] percentComplete:100 showBanner:NO];
    }
    if ([[DBManager getInstance]isStickersAchievementUnlocked]) {
        [self updateAchievementWithIdentifier:[NSArray arrayWithObjects:ACHIEVEMENT_STICKY_SPILSBERRY, ACHIEVEMENT_STICKY_SPILSBERRY_TITLE, nil] percentComplete:100 showBanner:NO];
    }
    if ([[DBManager getInstance]isTakePhotoAchievementUnlocked]) {
        [self updateAchievementWithIdentifier:[NSArray arrayWithObjects:ACHIEVEMENT_SNAPPY_SPILSBERRY, ACHIEVEMENT_SNAPPY_SPILSBERRY_TITLE, nil] percentComplete:100 showBanner:NO];
    }
    if ([[DBManager getInstance]isTakeVideoAchievementUnlocked]) {
        [self updateAchievementWithIdentifier:[NSArray arrayWithObjects:ACHIEVEMENT_ACTION_SPILSBERRY, ACHIEVEMENT_ACTION_SPILSBERRY_TITLE, nil] percentComplete:100 showBanner:NO];
    }
    int solvedPuzzles = [[DBManager getInstance]getNumberOfSolvedPuzzles];
    
    if (solvedPuzzles == 1) {
        [self updateAchievementWithIdentifier:[NSArray arrayWithObjects:ACHIEVEMENT_YOUNG_SPILSBERRY, ACHIEVEMENT_YOUNG_SPILSBERRY_TITLE, nil] percentComplete:100 showBanner:NO];
    }
    if (solvedPuzzles >= 10) {
        [self updateAchievementWithIdentifier:[NSArray arrayWithObjects:ACHIEVEMENT_SUPER_SPILSBERRY, ACHIEVEMENT_SUPER_SPILSBERRY_TITLE, nil] percentComplete:100 showBanner:NO];
    }
}

- (int)didUserChange:(NSString *)userID
{
    if ([[DBManager getInstance]getGCUserID] == nil) {
        [[DBManager getInstance]setGCUserID:userID];
        return 0;
    }
    else if ([[[DBManager getInstance]getGCUserID] isEqualToString:userID]) {
        return 2;
    }
    else {
        [[DBManager getInstance]setGCUserID:userID];
        return 1;
    }
}

- (void) updateAchievementWithIdentifier: (NSArray*) identifier percentComplete: (float) percent showBanner:(BOOL)showBanner
{
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
        if (error != nil) {
            [self createAchievementWithIdentifier:identifier percentComplete:percent showBanner:showBanner];
        }
        else {
            if (achievements != nil) {
                for (GKAchievement *ach in achievements) {
                    if ([[ach identifier] isEqualToString:[identifier objectAtIndex:0]]) {
                        return;
                    }
                }
            }
            [self createAchievementWithIdentifier:identifier percentComplete:percent showBanner:showBanner];
        }
    }];
}

- (void)createAchievementWithIdentifier: (NSArray *)identifier percentComplete: (float) percent showBanner:(BOOL)showBanner
{
    GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier: [identifier objectAtIndex:0]];
    //    [achievement setShowsCompletionBanner:YES];
    NSArray *achievements = [NSArray arrayWithObjects:achievement, nil];
    if (achievement && [achievement percentComplete] < 100)
    {
        achievement.percentComplete = percent;
        [GKAchievement reportAchievements:achievements withCompletionHandler:^(NSError *error) {
            if (error != nil) {
                NSLog(@"Error in reporting achievements: %@", error);
            }
            else if (showBanner){
                [ViewUtilities showAchievementsBadgeViewWithTitle:[identifier objectAtIndex:1]];
            }
        }];
    }
}

- (void) resetAchievements
{
    // Clear all locally saved achievement objects.
//    achievementsDictionary = [[NSMutableDictionary alloc] init];
    // Clear all progress saved on Game Center.
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error)
     {
         if (error != nil){
             
         }
     }];
}


@end
