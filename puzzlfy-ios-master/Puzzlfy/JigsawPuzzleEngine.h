//
//  JigsawPuzzleEngine.h
//  Puzzlfy
//
//  Created by Bahaa Zaid on 3/16/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PuzzlePiece.h"

@interface JigsawPuzzleEngine : NSObject

- (JigsawPuzzleEngine *) initWithImage:(CGImageRef)puzzleImage withDifficultyValue:(NSInteger) difficultyValue withX:(NSInteger) tilesX andY: (NSInteger) tilesY;

@property (readonly) CGImageRef puzzleImage;
@property (readonly) NSInteger tilesX;
@property (readonly) NSInteger tilesY;
@property (readonly) NSInteger difficultyValue;
@property (readonly) CGFloat pieceWidth;
@property (nonatomic) CGFloat backGroundAlpha;

- (CGImageRef) getStrokedImage;

- (PuzzlePiece *) puzzlePieceAtX:(NSInteger) x andY:(NSInteger) y;
- (PuzzlePiece *) puzzlePieceAtIndex:(NSInteger) index;
- (CGImageRef) aliasedImageForPieceAtX:(NSInteger) x andY:(NSInteger) y;

@end
