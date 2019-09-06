//
//  ViewController.m
//  Puzzlfy
//
//  Created by Bahaa Zaid on 3/16/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "WelcomeViewController.h"
#import "NavigationBarView.h"
#import "SegueNames.h"
#import "Constants.h"
#import "SoundUtilities.h"

@interface WelcomeViewController ()
@property (nonatomic, strong) UITapGestureRecognizer* tapGestureRecognizer;
@end

@implementation WelcomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewTapped:(UITapGestureRecognizer *) sender
{
    [self performSegueWithIdentifier:SEGUE_GOTO_PUZZLE_SELECTION_VIEW sender:self];
}

-(void) adjustNavigationBarButtonsVisibility:(NavigationBarView*) bar
{
    [bar.backButton setHidden:YES];
    [bar.menuButton setHidden:NO];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:SEGUE_GOTO_PUZZLE_SELECTION_VIEW])
        [SoundUtilities playSoundWithName:@"puzzlfy-button-play" andFormat:SOUND_TYPE_MP3];
    
    [self resetNavBarBackBtn];
}
@end
