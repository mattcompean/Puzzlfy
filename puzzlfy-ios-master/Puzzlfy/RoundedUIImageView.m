//
//  RoundedUIImageView.m
//  Puzzlfy
//
//  Created by Adham Aboul Einein on 5/5/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "RoundedUIImageView.h"

@implementation RoundedUIImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self.layer setCornerRadius:25.0f];
        [self.layer setMasksToBounds:YES];
        self.clipsToBounds = YES;
    }
    return self;
}


@end
