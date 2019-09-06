//
//  GameCenterManager.h
//  Puzzlfy
//
//  Created by Adham Aboul Einein on 5/21/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@interface GameCenterManager : NSObject

@property (nonatomic) BOOL gameCenterEnabled;
@property (nonatomic, strong) NSString *leaderboardIdentifier;

+ (GameCenterManager *)getInstance;
-(void)authenticateLocalPlayer;
- (void) updateAchievementWithIdentifier: (NSArray*) identifier percentComplete: (float) percent showBanner:(BOOL)showBanner;
- (void) resetAchievements;
@end
