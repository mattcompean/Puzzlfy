//
//  PuzzlePiece.h
//  Puzzlfy
//
//  Created by Bahaa Zaid on 3/18/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PuzzlePiece : NSObject

@property CGImageRef image;
@property NSInteger locationX;
@property NSInteger locationY;
@property CGSize fullSize;
@property CGPoint origin;

- (void) finalize;

@end
