//
//  NavigationBarView.m
//  Puzzlfy
//
//  Created by Youmna on 5/5/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "NavigationBarView.h"
#import "PuzzleViewController.h"
#import "ViewUtilities.h"
#import "Notifications.h"

@implementation NavigationBarView

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveApplicationWillEnterBackgroundNotification) name:APP_WILL_ENTER_BACKGROUND_NOTIFICATION object:nil];
    }
    
    return self;
}

- (void) recieveApplicationWillEnterBackgroundNotification
{
    [self.owner stopMenuTimer];
    [self.menuButton setAlpha:0.5];
    [self.tapMenuTextView setAlpha:0];
}

- (IBAction)menuButtonPressed:(UIButton *)sender
{
    if ([self.owner isKindOfClass:[PuzzleViewController class]]) {
        [self.owner menuButtonPressed:sender isPuzzleView:YES];
    }
    else {
        [self.owner menuButtonPressed:sender isPuzzleView:NO];
    }
}

- (IBAction)backButtonPressed:(UIButton *)sender
{
    [self.owner backButtonPressed:sender];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_WILL_ENTER_BACKGROUND_NOTIFICATION object:nil];
}
@end
