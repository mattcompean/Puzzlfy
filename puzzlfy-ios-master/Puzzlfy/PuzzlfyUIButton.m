//
//  PuzzlfyUIButton.m
//  Puzzlfy
//
//  Created by Adham Aboul Einein on 6/9/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "PuzzlfyUIButton.h"

@implementation PuzzlfyUIButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setExclusiveTouch:YES];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setExclusiveTouch:YES];
    }
    return self;
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setExclusiveTouch:YES];
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
