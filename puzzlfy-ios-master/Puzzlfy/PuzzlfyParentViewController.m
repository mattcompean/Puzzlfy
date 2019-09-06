//
//  PuzzlfyParentViewController.m
//  Puzzlfy
//
//  Created by Youmna on 5/5/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "PuzzlfyParentViewController.h"
#import "NavigationBarView.h"
#import "SegueNames.h"
#import "PuzzleViewController.h"
#import "SoundUtilities.h"
#import "ViewUtilities.h"
#import "Notifications.h"
#import "Constants.h"

@interface PuzzlfyParentViewController ()
@property (nonatomic) NSTimer* menuTextTimer;
@end

@implementation PuzzlfyParentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NavigationBarView*)addNavigationBar
{
    NavigationBarView *bar = [ViewUtilities getNavBar];
    if (!bar) {
        bar = [[[NSBundle mainBundle] loadNibNamed:NAVIGATION_BAR_VIEW owner:self options:nil] objectAtIndex:0];
        [ViewUtilities setNavBar:bar];
    }
    
    UIView* navBarPlaceholder = [self.view viewWithTag:10];
    [navBarPlaceholder addSubview:bar];
    [bar setOwner:self];
    return bar;
    
}

-(void) adjustNavigationBarButtonsVisibility:(NavigationBarView*) bar
{
    [bar.backButton setHidden:NO];
    [bar.menuButton setHidden:NO];
}

-(void)menuTimerExceeded:(NSTimer*)timer
{
    [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
        [[timer.userInfo objectForKey:@"textView"] setAlpha:0];
        [[timer.userInfo objectForKey:@"menuButton"] setAlpha:0.5];
    }
    completion:^(BOOL finished){
        [timer invalidate];
        self.menuTextTimer = nil;
    }];
}

- (void)menuButtonPressed:(UIButton *)sender isPuzzleView:(BOOL)isPuzzleView {
    //first click
    if(sender.alpha < 1)
    {
        sender.alpha = 1;
        //show menu text
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:0
                         animations:^{
                            [((NavigationBarView*)sender.superview).tapMenuTextView setAlpha:1];
                         }
                         completion:^(BOOL finished){
                             NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys: ((NavigationBarView*)sender.superview).tapMenuTextView, @"textView", ((NavigationBarView*)sender.superview).menuButton, @"menuButton", nil];
                             self.menuTextTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(menuTimerExceeded:) userInfo:dict repeats:NO];
                         }];
    }
    //second click
    else {
        [self.menuTextTimer invalidate];
        self.menuTextTimer = nil;
        if (isPuzzleView) {
            [self performSegueWithIdentifier:SEGUE_GOTO_PUZZLE_SETTINGS_VIEW sender:self];
        }
        else {
            [self performSegueWithIdentifier:SEGUE_GOTO_SETTINGS_VIEW sender:self];
        }
        [SoundUtilities playSoundWithName:@"puzzlfy-button-menu" andFormat:@"mp3"];
        sender.alpha = 0.5;
    }
}

- (void)backButtonPressed:(UIButton *)sender {
    [SoundUtilities playSoundWithName:@"puzzlfy-button-back" andFormat:@"mp3"];
    [self resetNavBarBackBtn];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self adjustNavigationBarButtonsVisibility:[self addNavigationBar]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self adjustNavigationBarButtonsVisibility:[self addNavigationBar]];
    //play sounds
    [self playLoopSound];
    //get navBar
    UIView *placeholder = [self.view viewWithTag:10];
    if(placeholder)
    {
        NavigationBarView* bar;
        for(UIView *view in [placeholder subviews])
        {
            if([view isMemberOfClass:[NavigationBarView class]])
            {
                bar = (NavigationBarView*)view;
                break;
            }
        }
        if(bar)
        {
            [bar setOwner:self];
            bar.tapMenuTextView.alpha= 0;
            bar.menuButton.alpha = 0.5;
        }
    }
}

- (void)stopMenuTimer
{
    [self.menuTextTimer invalidate];
}

- (void)startMenuTimer
{
    
}

-(void)playLoopSound
{
    [SoundUtilities playMainSoundWithName:@"Another Happy Traveling loop"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resetNavBarBackBtn
{
    UIView *placeholder = [self.view viewWithTag:10];
    if(placeholder)
    {
        NavigationBarView* bar;
        for(UIView *view in [placeholder subviews])
        {
            if([view isMemberOfClass:[NavigationBarView class]])
            {
                bar = (NavigationBarView*)view;
                break;
            }
        }
        if(bar)
            [bar setOwner:nil];
    }
}

@end
