//
//  StickerImageView.h
//  Puzzlfy
//
//  Created by Youmna on 5/18/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "RoundedUIView.h"

@interface StickerImageView : RoundedUIView
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
- (IBAction)pauseVideo:(id)sender;
- (IBAction)replayVideo:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *videoPlayBtn;
@end
