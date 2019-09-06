//
//  DBManager.h
//  Puzzlfy
//
//  Created by Adham Aboul Einein on 5/13/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface DBManager : NSObject

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

+ (DBManager *)getInstance;
- (void)saveObjectContext:(NSError **)error;
- (User *)getUser;
- (CGPoint)getNumberOfPuzzlePieces;
- (int)getDifficulty;
- (NSString *)getDifficultyName;
- (int)getNumberOfSolvedPuzzles;
- (BOOL)isHardPuzzleAchievementUnlocked;
- (BOOL)isMediumPuzzleAchievementUnlocked;
- (BOOL)isTakePhotoAchievementUnlocked;
- (BOOL)isTakeVideoAchievementUnlocked;
- (BOOL)isStickersAchievementUnlocked;
- (NSArray *)getUsedStickers;
- (NSString *)getGCUserID;
- (BOOL)getMicPermission;

- (void)setNumberOfSolvedPuzzles:(int)num;
- (void)setHardPuzzleAchievement:(BOOL)unlocked;
- (void)setMediumPuzzleAchievement:(BOOL)unlocked;
- (void)setTakePhotoAchievement:(BOOL)unlocked;
- (void)setTakeVideoAchievement:(BOOL)unlocked;
- (void)setStickersAchievement:(BOOL)unlocked;
- (void)updateUsedStickers:(NSString *)stickerID;
- (void)setGCUserID:(NSString *)userID;
- (void)setMicPermission:(BOOL)permission;

@end
