//
//  StickersMainView.m
//  Puzzlfy
//
//  Created by Youmna on 5/27/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "StickersMainView.h"
#import "Notifications.h"

@interface StickersMainView () {
    BOOL _shouldFlash;
}

@end

@implementation StickersMainView

#define ANIMATION_DURATION 0.5
#define SECOND_ANIMATION_DURATION 1
#define ANIMATION_DELAY 1.5

- (id)init
{
    self = [super init];
    if (self) {
        [self addNotificationListener];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addNotificationListener];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addNotificationListener];
    }
    return self;
}

- (void)addNotificationListener
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:START_PUZZLFY_ANIMATION_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startAnimation) name:START_PUZZLFY_ANIMATION_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:STOP_PUZZLFY_ANIMATION_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endFlashing) name:STOP_PUZZLFY_ANIMATION_NOTIFICATION object:nil];
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    
    self.bottomScrollView.userInteractionEnabled = YES;
    if(self.videoStickers)
    {
        UIView *view = [self.videoStickers hitTest:[self convertPoint:point toView:self.videoStickers] withEvent:event];
        if(view)
        {
            self.bottomScrollView.scrollEnabled = NO;
            self.bottomScrollView.userInteractionEnabled = NO;
            return [super hitTest:point withEvent:event];
        }
    }

    if(CGRectContainsPoint(self.vArrowView.frame, [self convertPoint:point toView:self.vArrowView]))
    {
        self.bottomScrollView.scrollEnabled = YES;
        self.bottomScrollView.userInteractionEnabled = YES;
    }
    else{
        self.bottomScrollView.scrollEnabled = NO;
    }
    if([self convertPoint:point toView:self.vArrowView].y < 0)
        self.bottomScrollView.userInteractionEnabled = NO;

    
    return [super hitTest:point withEvent:event];
}

- (void)startAnimation
{
    [self performSelector:@selector(startFlashing) withObject:nil afterDelay:ANIMATION_DELAY];
}

- (void) startFlashing
{
    _shouldFlash = YES;
    [self flashOn];
}

- (void) endFlashing
{
    _shouldFlash = NO;
}

- (void)flashOff
{
    UIImage *normal = [UIImage imageNamed:@"puzzlfy-btn.png"];
    [UIView transitionWithView:self.puzzlfyBtn duration:ANIMATION_DURATION options:(UIViewAnimationOptionTransitionCrossDissolve|UIViewAnimationOptionAllowUserInteraction) animations:^{
        [self.puzzlfyBtn setImage:normal forState:UIControlStateNormal];
    } completion:^(BOOL finished) {
        if(_shouldFlash) {
            [self performSelector:@selector(flashOn) withObject:nil afterDelay:ANIMATION_DELAY];
        }
    }];
    
}

- (void)flashOn
{
    UIImage *highlighted = [UIImage imageNamed:@"puzzlfy-highlited-btn.png"];
    [UIView transitionWithView:self.puzzlfyBtn duration:SECOND_ANIMATION_DURATION options:(UIViewAnimationOptionTransitionCrossDissolve|UIViewAnimationOptionAllowUserInteraction) animations:^{
        [self.puzzlfyBtn setImage:highlighted forState:UIControlStateNormal];
    } completion:^(BOOL finished) {
        [self flashOff];
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:START_PUZZLFY_ANIMATION_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:STOP_PUZZLFY_ANIMATION_NOTIFICATION object:nil];
}

@end
