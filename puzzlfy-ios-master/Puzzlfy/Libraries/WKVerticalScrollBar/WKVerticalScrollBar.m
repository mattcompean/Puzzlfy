//
// WKVerticalScrollBar
// http://github.com/litl/WKVerticalScrollBar
//
// Copyright (C) 2012 litl, LLC
// Copyright (C) 2012 WKVerticalScrollBar authors
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
//

#import "WKVerticalScrollBar.h"

#define CLAMP(x, low, high)  (((x) > (high)) ? (high) : (((x) < (low)) ? (low) : (x)))
#define UIColorWithRGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
@interface WKVerticalScrollBar ()
- (void)commonInit;
@end

@implementation WKVerticalScrollBar

@synthesize handleWidth = _handleWidth;
@synthesize handleHitWidth = _handleHitWidth;
@synthesize handleSelectedWidth = _handleSelectedWidth;

@synthesize handleMinimumHeight = _handleMinimumHeight;
@synthesize handle = _handle;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _handleWidth = 10;
    _handleSelectedWidth = 10.0f;
    _handleHitWidth = 10.0f;
    _handleMinimumHeight = 70.0f;
    
    _handleCornerRadius = _handleWidth / 2;
    _handleSelectedCornerRadius = _handleSelectedWidth / 2;
    
    handleHitArea = CGRectZero;
    
    normalColor = [UIColorWithRGB(122,52,149) retain];
    selectedColor = [UIColorWithRGB(122,52,149) retain];
    
    _handle = [[CALayer alloc] init];
    [_handle setCornerRadius:_handleCornerRadius];
    [_handle setAnchorPoint:CGPointMake(2.2f, 0.0f)];
    [_handle setFrame:CGRectMake(0, 0, _handleWidth, 0)];
    [_handle setBackgroundColor:[normalColor CGColor]];
    [[self layer] addSublayer:_handle];
}

- (void)dealloc
{
    [_handle release];
    
    [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
    [_scrollView removeObserver:self forKeyPath:@"contentSize"];
    [_scrollView release];
    
    [_handleAccessoryView release];
    
    [normalColor release];
    [selectedColor release];
    
    [super dealloc];
}

- (UIScrollView *)scrollView
{
    return _scrollView;
}

- (void)setScrollView:(UIScrollView *)scrollView;
{
    [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
    [_scrollView removeObserver:self forKeyPath:@"contentSize"];
    
    [_scrollView release];
    _scrollView = [scrollView retain];
    
    [_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [_scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    [_scrollView setShowsVerticalScrollIndicator:NO];
    
    [self setNeedsLayout];
}

- (UIView *)handleAccessoryView
{
    return _handleAccessoryView;
}

- (void)setHandleAccessoryView:(UIView *)handleAccessoryView
{
    [handleAccessoryView retain];
    [_handleAccessoryView removeFromSuperview];
    [_handleAccessoryView release];
    _handleAccessoryView = handleAccessoryView;
    
    [_handleAccessoryView setAlpha:0.0f];
    [self addSubview:_handleAccessoryView];
    [self setNeedsLayout];
}

- (void)setHandleColor:(UIColor *)color forState:(UIControlState)state
{
    if (state == UIControlStateNormal) {
        [color retain];
        [normalColor release];
        normalColor = color;
    } else if (state == UIControlStateSelected) {
        [color retain];
        [selectedColor release];
        selectedColor = color;
    }
}

-(void)setHandleWidth:(CGFloat)handleWidth
{
    [_handle setFrame:CGRectMake(0, 0, _handleWidth, 0)];
}

- (CGFloat)handleCornerRadius
{
    return _handleCornerRadius;
}

- (void)setHandleCornerRadius:(CGFloat)handleCornerRadius
{
    _handleCornerRadius = handleCornerRadius;
    
    if (!handleDragged) {
        [_handle setCornerRadius:_handleCornerRadius];
    }
}

- (CGFloat)handleSelectedCornerRadius
{
    return _handleSelectedCornerRadius;
}

- (void)setHandleSelectedCornerRadius:(CGFloat)handleSelectedCornerRadius
{
    _handleSelectedCornerRadius = handleSelectedCornerRadius;
    
    if (handleDragged) {
        [_handle setCornerRadius:_handleSelectedCornerRadius];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat contentHeight = [_scrollView contentSize].height;
    CGFloat frameHeight = [_scrollView frame].size.height;
    
    if (contentHeight <= frameHeight) {
        // Prevent divide by 0 below when we arrive here before _scrollView has geometry.
        // Also explicity hide handle when not needed, occasionally it's left visible due to
        // layoutSubviews being called with transient & invalid geometery
        [_handle setOpacity:0.0f];
        return;
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    CGRect bounds = [self bounds];
    
    // Calculate the current scroll value (0, 1) inclusive.
    // Note that contentOffset.y only goes from (0, contentHeight - frameHeight)
    // prevent divide by 0 below when we arrive here before _scrollView has geometry
    CGFloat scrollValue = (contentHeight - frameHeight == 0) ? 0
    : [_scrollView contentOffset].y / (contentHeight - frameHeight);
    
    // Set handleHeight proportionally to how much content is being currently viewed
    CGFloat handleHeight = CLAMP((frameHeight / contentHeight) * bounds.size.height,
                                 _handleMinimumHeight, bounds.size.height);
    
    [_handle setOpacity:(handleHeight == bounds.size.height) ? 0.0f : 1.0f];
    
    // Not only move the handle, but also shift where the position maps on to the handle,
    // so that the handle doesn't go off screen when the scrollValue approaches 1.
    CGFloat handleY = CLAMP((scrollValue * bounds.size.height) - (scrollValue * handleHeight),
                            0, bounds.size.height - handleHeight);
    
    CGFloat previousWidth = [_handle bounds].size.width ?: _handleWidth;
    [_handle setPosition:CGPointMake(bounds.size.width, handleY)];
    [_handle setBounds:CGRectMake(0, 0, previousWidth, handleHeight)];
    
    // Center the accessory view to the left of the handle
    CGRect accessoryFrame = [_handleAccessoryView frame];
    [_handleAccessoryView setCenter:CGPointMake(bounds.size.width - _handleHitWidth - (accessoryFrame.size.width / 2),
                                                handleY + (handleHeight / 2))];
    
    handleHitArea = CGRectMake(bounds.size.width - _handleHitWidth, handleY,
                               _handleHitWidth, handleHeight);
    
    [CATransaction commit];
}

- (BOOL)handleVisible
{
    return [_handle opacity] == 1.0f;
}

- (void)growHandle
{
    if (![self handleVisible]) {
        return;
    }
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.3f];
    
    [_handle setCornerRadius:_handleSelectedCornerRadius];
    [_handle setBounds:CGRectMake(0, 0, _handleSelectedWidth, [_handle bounds].size.height)];
    [_handle setBackgroundColor:[selectedColor CGColor]];
    
    [CATransaction commit];
    
    [UIView animateWithDuration:0.3f animations:^{
        [_handleAccessoryView setAlpha:1.0f];
    }];
}

- (void)shrinkHandle
{
    if (![self handleVisible]) {
        return;
    }
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.3f];
    
    [_handle setCornerRadius:_handleCornerRadius];
    [_handle setBounds:CGRectMake(0, 0, _handleWidth, [_handle bounds].size.height)];
    [_handle setBackgroundColor:[normalColor CGColor]];
    
    [CATransaction commit];
    
    [UIView animateWithDuration:0.3f animations:^{
        [_handleAccessoryView setAlpha:0.0f];
    }];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return CGRectContainsPoint(handleHitArea, point);
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (![self handleVisible]) {
        return NO;
    }
    
    lastTouchPoint = [touch locationInView:self];
    
    // When the user initiates a drag, make the handle grow so it's easier to see
    handleDragged = YES;
    [self growHandle];
    
    [self setNeedsLayout];
    
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint point = [touch locationInView:self];
    
    CGSize contentSize = [_scrollView contentSize];
    CGPoint contentOffset = [_scrollView contentOffset];
    CGFloat frameHeight = [_scrollView frame].size.height;
    CGFloat deltaY = ((point.y - lastTouchPoint.y) / [self bounds].size.height)
    * [_scrollView contentSize].height;
    
    [_scrollView setContentOffset:CGPointMake(contentOffset.x,  CLAMP(contentOffset.y + deltaY,
                                                                      0, contentSize.height - frameHeight))
                         animated:NO];
    lastTouchPoint = point;
    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    lastTouchPoint = CGPointZero;
    
    // When user drag is finished, return handle to previous size
    handleDragged = NO;
    [self shrinkHandle];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object != _scrollView) {
        return;
    }
    
    [self setNeedsLayout];
}

//code added by Youmna
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.scrollView touchesBegan:touches withEvent:event];
}


@end
