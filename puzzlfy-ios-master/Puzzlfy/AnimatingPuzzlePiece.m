//
//  AnimatingPuzzlePiece.m
//  Puzzlfy
//
//  Created by Youmna on 7/2/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "AnimatingPuzzlePiece.h"
#import "Constants.h"

@implementation AnimatingPuzzlePiece

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.numberOfVibrations = NUMBER_OF_VIBRATIONS_FOR_PUZZLE_PIECE;
    }
    return self;
}

-(id)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self) {
        self.numberOfVibrations = NUMBER_OF_VIBRATIONS_FOR_PUZZLE_PIECE;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
