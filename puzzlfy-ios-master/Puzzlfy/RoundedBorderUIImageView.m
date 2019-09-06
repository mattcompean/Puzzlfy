//
//  RoundedBorderUIImageView.m
//  Puzzlfy
//
//  Created by Adham Aboul Einein on 5/20/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "RoundedBorderUIImageView.h"

@implementation RoundedBorderUIImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
//        [self.layer setBorderColor:[UIColor colorWithRed:82 green:1 blue:11 alpha:1]];
        [self.layer setBorderColor:[UIColor colorWithRed:84.0f/255.0f green:6.0f/255.0f blue:110.0f/255.0f alpha:1.0f].CGColor];
        [self.layer setBorderWidth:2.0];
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
