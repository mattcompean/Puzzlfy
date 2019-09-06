//
//  GalleryCollectionView.h
//  Puzzlfy
//
//  Created by Youmna on 5/7/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKVerticalScrollBar.h"
@interface GalleryCollectionView : UICollectionView
@property (nonatomic, readonly) WKVerticalScrollBar *verticalScrollBar;
@end
