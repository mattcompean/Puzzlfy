//
//  RoundedUIView.m
//  Puzzlfy
//
//  Created by Adham Aboul Einein on 5/6/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "RoundedUIView.h"

@implementation RoundedUIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [self.layer setCornerRadius:10.0f];
    [self.layer setMasksToBounds:YES];
    self.clipsToBounds = YES;
}

-(void) setCornerRadius:(CGFloat)radius
{
    [self.layer setCornerRadius:radius];
}


@end
