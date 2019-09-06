//
//  PuzzlfyParentViewController.h
//  Puzzlfy
//
//  Created by Youmna on 5/5/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PuzzlfyParentViewController : UIViewController

- (void)menuButtonPressed:(UIButton *)sender isPuzzleView:(BOOL)isPuzzleView;
- (void)backButtonPressed:(UIButton *)sender;
-(void)playLoopSound;
- (void)resetNavBarBackBtn;
- (void)stopMenuTimer;
@end
