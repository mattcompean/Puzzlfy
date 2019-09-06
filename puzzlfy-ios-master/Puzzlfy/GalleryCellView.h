//
//  GalleryCellView.h
//  Puzzlfy
//
//  Created by Youmna on 5/6/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface GalleryCellView : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UIImageView *playImage;
@property(nonatomic, strong) ALAsset *asset;
@property BOOL isVideo;
@end
