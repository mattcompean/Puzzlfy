//
//  GalleryCollectionView.m
//  Puzzlfy
//
//  Created by Youmna on 5/7/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "GalleryCollectionView.h"
#import "UIView+Shadow.h"

@interface GalleryCollectionView ()

@end
@implementation GalleryCollectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        //add top shadow
      //  [self makeInsetShadowWithRadius:15 Color:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3] Directions:[NSArray arrayWithObjects:@"top", nil]];
        //add scrollbar
        _verticalScrollBar = [[WKVerticalScrollBar alloc] initWithFrame:CGRectZero];
        [_verticalScrollBar setScrollView:self];
        [_verticalScrollBar.handle setHidden:YES];
    //    [_verticalScrollBar setUserInteractionEnabled:NO];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = [self bounds];
    [_verticalScrollBar setFrame:CGRectMake(0, 32, bounds.size.width, bounds.size.height-64)];
}



@end
