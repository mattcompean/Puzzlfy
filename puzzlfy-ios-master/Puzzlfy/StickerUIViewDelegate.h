//
//  StickerUIViewDelegate.h
//  Puzzlfy
//
//  Created by Youmna on 5/13/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol StickerUIViewDelegate <NSObject>
-(void)viewTapped:(UITapGestureRecognizer *) sender;
-(void)viewPinched:(UIPinchGestureRecognizer *) sender;
-(void)viewRotated:(UIRotationGestureRecognizer *) sender;
-(void)viewPaned:(UIPanGestureRecognizer *) sender;
-(void)setCurrentStickerView:(UIView*)view;
@end
