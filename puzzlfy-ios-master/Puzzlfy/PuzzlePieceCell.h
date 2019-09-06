//
//  PuzzlePieceCell.h
//  Puzzlfy
//
//  Created by Bahaa Zaid on 3/20/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PuzzlePieceCell : UICollectionViewCell
@property (strong) PuzzlePiece *puzzlePiece;
@property NSInteger cellIndex;
@end
