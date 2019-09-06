//
//  PuzzleViewController.h
//  Puzzlfy
//
//  Created by Bahaa Zaid on 3/16/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PuzzlfyParentViewController.h"
#import "SettingsProtocol.h"

@interface PuzzleViewController : PuzzlfyParentViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate, SettingsProtocol, UIAlertViewDelegate>

@property (strong, nonatomic) UIImage *image;

@end
