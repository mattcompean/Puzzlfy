//
//  PuzzlePiece.m
//  Puzzlfy
//
//  Created by Bahaa Zaid on 3/18/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "PuzzlePiece.h"

@implementation PuzzlePiece

- (id)init {
    self = [super init];
    
    self.image = NULL;
    
    return self;
}

- (void) finalize {
    if (self.image) {
        CGImageRelease(self.image);
    }
}

@end
