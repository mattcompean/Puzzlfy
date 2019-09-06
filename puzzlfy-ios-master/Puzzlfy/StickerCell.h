//
//  StickerCell.h
//  Puzzlfy
//
//  Created by Youmna on 5/12/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StickerCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *image;
@property (strong, nonatomic) UIPanGestureRecognizer *recognizer;
@property (nonatomic) NSInteger index;
-(void)setBorder:(BOOL)hasBorders;

@end
