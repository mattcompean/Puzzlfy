//
//  GalleryCellView.m
//  Puzzlfy
//
//  Created by Youmna on 5/6/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "GalleryCellView.h"


@implementation GalleryCellView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) setAsset:(ALAsset *)asset
{
    _asset = asset;
    self.isVideo = NO;
    self.photoImageView.image = [UIImage imageWithCGImage:[asset thumbnail]];
    if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
        self.isVideo = YES;
        [self.playImage setHidden:NO];
    }
    else{
        [self.playImage setHidden:YES];
    }
}

@end
