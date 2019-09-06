//
//  User.h
//  Puzzlfy
//
//  Created by Adham Aboul Einein on 7/6/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSNumber * achvHardPuzzlesSolved;
@property (nonatomic, retain) NSNumber * achvMediumPuzzlesSolved;
@property (nonatomic, retain) NSNumber * achvSolvedPuzzles;
@property (nonatomic, retain) NSNumber * achvStickers;
@property (nonatomic, retain) NSNumber * achvTakePhoto;
@property (nonatomic, retain) NSNumber * achvTakeVideo;
@property (nonatomic, retain) NSNumber * difficulty;
@property (nonatomic, retain) NSString * gcUserId;
@property (nonatomic, retain) NSNumber * music;
@property (nonatomic, retain) NSNumber * showOutlines;
@property (nonatomic, retain) NSNumber * showSilhouette;
@property (nonatomic, retain) NSNumber * sound;
@property (nonatomic, retain) NSData * stickersUsed;
@property (nonatomic, retain) NSNumber * micPermission;

@end
