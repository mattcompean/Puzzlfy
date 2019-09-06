//
//  StickersMainView.h
//  Puzzlfy
//
//  Created by Youmna on 5/27/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PuzzlfyUIButton.h"

@interface StickersMainView : UIView
@property (strong, nonatomic) IBOutlet UIScrollView *bottomScrollView;
@property (strong, nonatomic) UIView *videoStickers;
@property (strong, nonatomic) IBOutlet UIView *vArrowView;
@property (strong, nonatomic) IBOutlet PuzzlfyUIButton *puzzlfyBtn;

@end
