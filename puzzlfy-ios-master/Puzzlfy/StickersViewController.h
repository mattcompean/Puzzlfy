//
//  StickersViewController.h
//  Puzzlfy
//
//  Created by Youmna on 5/6/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "PuzzlfyParentViewController.h"
#import "RoundedUIView.h"
#import  <AssetsLibrary/AssetsLibrary.h>
#import "StickerUIViewDelegate.h"
#import "StickerImageView.h"
#import "BottomRoundedUIView.h"
#import "PuzzlfyUIButton.h"

@interface StickersViewController : PuzzlfyParentViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, StickerUIViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSObject *puzzleAsset;
@property (nonatomic) int puzzleAssetType;
@property (strong, nonatomic) IBOutlet PuzzlfyUIButton *puzzlfyBtn;

@property (strong, nonatomic) UIImageView *imageView;
//@property (strong, nonatomic) IBOutlet UIView *imagePlaceholder;
@property (strong, nonatomic) UIView *imagePlaceholder;
@property (strong, nonatomic) StickerImageView *ImageAreaView;
- (IBAction)PuzzlfyButtonClicked:(UIButton *)sender;
@property (strong, nonatomic) UIScrollView *imageScrollView;
@property (strong, nonatomic) IBOutlet UICollectionView *categoriesCollectionView;
@property (strong, nonatomic) IBOutlet BottomRoundedUIView *categoriesContainerView;
@property (strong, nonatomic) IBOutlet UICollectionView *stickesCollectionView;
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UIView *bottomSwipeView;
@property (strong, nonatomic) IBOutlet UIImageView *vBackgroundImageView;
@property (nonatomic) NSInteger videoLoopCount;
@property (nonatomic) NSString* audioTrack;
@property (nonatomic) BOOL bAddWatermark;
- (IBAction)moreStickersButton:(UIButton *)sender;

@end
