//
//  AcheivementsBadgeView.m
//  Puzzlfy
//
//  Created by Adham Aboul Einein on 6/1/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "AchievementsBadgeView.h"

@implementation AchievementsBadgeView

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
        [self.layer setCornerRadius:10.0f];
        [self.layer setMasksToBounds:YES];
        [self.layer setBorderColor:[UIColor colorWithRed:184.0f/255.0f green:89.0f/255.0f blue:216.0f/255.0f alpha:1].CGColor];
        [self.layer setBorderWidth:5];
        self.clipsToBounds = YES;
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
