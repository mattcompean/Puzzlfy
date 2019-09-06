//
//  PuzzlfyGalleryViewController.h
//  Puzzlfy
//
//  Created by Youmna on 5/6/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "PuzzlfyParentViewController.h"

@interface PuzzlfyGalleryViewController : PuzzlfyParentViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *collectionViewContainer;
@property (strong, nonatomic) IBOutlet UIImageView *vPermissionsImageView;

@end
