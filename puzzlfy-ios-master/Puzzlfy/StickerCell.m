//
//  StickerCell.m
//  Puzzlfy
//
//  Created by Youmna on 5/12/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "StickerCell.h"

@implementation StickerCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [self.layer setCornerRadius:25.0f];
    [self.layer setMasksToBounds:YES];
    self.clipsToBounds = YES;
    [self.layer setBorderColor:[UIColor colorWithRed:255.0f/255.0f green:252.0f/255.0f blue:161.0f/255.0f alpha:1].CGColor];
}

-(void)setBorder:(BOOL)hasBorders
{
    if(hasBorders)
        [self.layer setBorderWidth:3];
    else
        [self.layer setBorderWidth:0];
}


@end
