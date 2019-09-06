//
//  NavigationBarView.h
//  Puzzlfy
//
//  Created by Youmna on 5/5/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PuzzlfyParentViewController.h"

@interface NavigationBarView : UIView
- (IBAction)menuButtonPressed:(UIButton *)sender;
- (IBAction)backButtonPressed:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) IBOutlet UIImageView *tapMenuTextView;

@property (strong, nonatomic) PuzzlfyParentViewController* owner;

@end
