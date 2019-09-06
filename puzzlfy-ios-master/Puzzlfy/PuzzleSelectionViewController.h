//
//  PuzzleSelectionViewController.h
//  Puzzlfy
//
//  Created by Bahaa Zaid on 3/16/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PuzzlfyParentViewController.h"

#define USER_IMAGE_INDEX 2

@interface PuzzleSelectionViewController : PuzzlfyParentViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *vShadowView;
@end
