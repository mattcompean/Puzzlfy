//
//  StickerUIView.m
//  Puzzlfy
//
//  Created by Youmna on 5/13/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "StickerUIView.h"
@interface StickerUIView()
@property (nonatomic, strong) UIPinchGestureRecognizer* pinchGesture;
@property (nonatomic, strong) UIRotationGestureRecognizer* rotateGesture;
@property (nonatomic, strong) UIPanGestureRecognizer* panGesture;
@property (nonatomic, strong) UITapGestureRecognizer* tapGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer* longGesture;
@end
@implementation StickerUIView

- (id)initWithFrame:(CGRect)frame andDelegate:(id)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = delegate;
        self.initialTransform = self.transform;
        [self initView];
    }
    return self;
}

-(id)initWithImage:(UIImage *)image andDelegate:(id)delegate
{
    self = [super initWithImage:image];
    if (self) {
        self.delegate = delegate;
        [self initView];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.delegate setCurrentStickerView:self];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
}

-(void)initView
{
    [self setContentMode:UIViewContentModeScaleAspectFit];
    [self initGestureRecognizers];
    self.lastScaleFactor = 1;
    self.lastScale = 1;
}

-(void)initGestureRecognizers
{
    [self setUserInteractionEnabled:YES];
    self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self.delegate action:@selector(viewPinched:)];
    [self addGestureRecognizer:self.pinchGesture];
    self.rotateGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self.delegate action:@selector(viewRotated:)];
    [self addGestureRecognizer:self.rotateGesture];
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.delegate action:@selector(viewPaned:)];
    [self addGestureRecognizer:self.panGesture];
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.delegate action:@selector(viewTapped:)];
    [self addGestureRecognizer:self.tapGesture];
//    self.longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self.delegate action:@selector(viewLongPressed:)];
//    [self addGestureRecognizer:self.longGesture];
    
    self.pinchGesture.delegate = self.delegate;
    self.rotateGesture.delegate = self.delegate;
    self.panGesture.delegate = self.delegate;
    self.tapGesture.delegate = self.delegate;
//    self.longGesture.delegate = self.delegate;
}


@end
