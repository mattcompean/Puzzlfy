//
//  StickerUIView.h
//  Puzzlfy
//
//  Created by Youmna on 5/13/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StickerUIViewDelegate.h"

@interface StickerUIView : UIImageView 
@property (strong, nonatomic) id<StickerUIViewDelegate, UIGestureRecognizerDelegate> delegate;
@property (nonatomic) CGFloat lastScaleFactor;
@property (nonatomic) CGFloat lastScale;
@property (nonatomic) CGAffineTransform initialTransform;
- (id)initWithFrame:(CGRect)frame andDelegate:(id)delegate;
-(id)initWithImage:(UIImage *)image andDelegate:(id)delegate;
@end
