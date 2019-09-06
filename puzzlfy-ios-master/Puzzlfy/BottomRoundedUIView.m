//
//  BottomRoundedUIView.m
//  Puzzlfy
//
//  Created by Youmna on 5/18/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "BottomRoundedUIView.h"

@implementation BottomRoundedUIView

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
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: self.bounds byRoundingCorners: UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii: (CGSize){20.0, 20.0}].CGPath;
    
    self.layer.mask = maskLayer;
}


@end
