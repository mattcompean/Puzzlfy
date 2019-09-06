//
//  DBManager.m
//  Puzzlfy
//
//  Created by Adham Aboul Einein on 5/13/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "DBManager.h"
#import "AppDelegate.h"
#import "Constants.h"

@implementation DBManager

+ (DBManager *)getInstance {
	static DBManager *sharedInstance;
	if (!sharedInstance) {
		sharedInstance = [[DBManager alloc] init];
	}
	return sharedInstance;
}

- (NSManagedObjectContext *)managedObjectContext
{
    return [(AppDelegate *)[[UIApplication sharedApplication]delegate]managedObjectContext];
}

- (void)saveObjectContext:(NSError **)error
{
    [self.managedObjectContext save:error];
}

- (NSArray *)fetchEntityByName:(NSString *)name withError:(NSError **)error
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    //    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:name inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSArray *fetchedRecords = [self.managedObjectContext executeFetchRequest:fetchRequest error:error];
    return fetchedRecords;
}

- (id)getEntityByName:(NSString *)name
{
    return [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:self.managedObjectContext];
}

- (User *)getUser
{
    NSError* error;
    NSArray *users = [self fetchEntityByName:USER_MODEL withError: &error];
    if (users.count) {
        return [users objectAtIndex:0];
    }
    else {
        return [self getEntityByName:USER_MODEL];
    }
    return nil;
}

- (CGPoint)getNumberOfPuzzlePieces
{
    switch ([[[self getUser]difficulty] intValue]) {
        case 0:
            return CGPointMake(DIFFICULTY_EASY_X, DIFFICULTY_EASY_Y);
            break;
        case 1:
            return CGPointMake(DIFFICULTY_MEDIUM_X, DIFFICULTY_MEDIUM_Y);
            break;
        case 2:
            return CGPointMake(DIFFICULTY_HARD_X, DIFFICULTY_HARD_Y);
            break;
        default:
            return CGPointMake(DIFFICULTY_SUPER_EASY_X, DIFFICULTY_SUPER_EASY_Y);
            break;
    }
}

- (int)getDifficulty
{
    return [[[self getUser]difficulty] intValue];
}

- (NSString *)getDifficultyName
{
    switch ([[[self getUser]difficulty] intValue]) {
        case 0:
            return @"EASY";
            break;
        case 1:
            return @"MEDIUM";
            break;
        case 2:
            return @"HARD";
            break;
        default:
            break;
    }
    
    return @"EASY";
}

- (int)getNumberOfSolvedPuzzles
{
    return [[[self getUser]achvSolvedPuzzles] intValue];
}

- (void)setNumberOfSolvedPuzzles:(int)num
{
    [[self getUser]setAchvSolvedPuzzles:[NSNumber numberWithInt:num]];
}

- (BOOL)isHardPuzzleAchievementUnlocked
{
    return [[[self getUser]achvHardPuzzlesSolved] boolValue];
}

- (void)setHardPuzzleAchievement:(BOOL)unlocked
{
    [[self getUser]setAchvHardPuzzlesSolved:[NSNumber numberWithBool:unlocked]];
}

- (BOOL)isMediumPuzzleAchievementUnlocked
{
    return [[[self getUser]achvMediumPuzzlesSolved] boolValue];
}

- (void)setMediumPuzzleAchievement:(BOOL)unlocked
{
    [[self getUser]setAchvMediumPuzzlesSolved:[NSNumber numberWithBool:unlocked]];
}

- (BOOL)isTakePhotoAchievementUnlocked
{
    return [[[self getUser]achvTakePhoto] boolValue];
}

- (void)setTakePhotoAchievement:(BOOL)unlocked
{
    [[self getUser]setAchvTakePhoto:[NSNumber numberWithBool:unlocked]];
}

- (BOOL)isTakeVideoAchievementUnlocked
{
    return [[[self getUser]achvTakeVideo] boolValue];
}

- (void)setTakeVideoAchievement:(BOOL)unlocked
{
    [[self getUser]setAchvTakeVideo:[NSNumber numberWithBool:unlocked]];
}

- (BOOL)isStickersAchievementUnlocked
{
    return [[[self getUser]achvStickers] boolValue];
}

- (void)setStickersAchievement:(BOOL)unlocked
{
    if (!unlocked) {
        [[self getUser]setStickersUsed: nil];
    }
    
    [[self getUser]setAchvStickers:[NSNumber numberWithBool:unlocked]];
}

- (NSArray *)getUsedStickers
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:[[self getUser] stickersUsed]];
}

- (void)updateUsedStickers:(NSString *)stickerID
{
    NSMutableArray *usedStickers = (NSMutableArray *)[self getUsedStickers];
    if (!usedStickers) {
        usedStickers = [NSMutableArray new];
    }
    if (![usedStickers containsObject:stickerID]) {
        [usedStickers addObject:stickerID];
        
        [[self getUser]setStickersUsed:[NSKeyedArchiver archivedDataWithRootObject:usedStickers]];
    }
}

- (NSString *)getGCUserID
{
    return [[self getUser]gcUserId];
}

- (void)setGCUserID:(NSString *)userID
{
    [[self getUser]setGcUserId:userID];
}

- (void)setMicPermission:(BOOL)permission
{
    [[self getUser]setMicPermission:[NSNumber numberWithBool:permission]];
}

- (BOOL)getMicPermission
{
    return [[[self getUser]micPermission] boolValue];
}
@end
