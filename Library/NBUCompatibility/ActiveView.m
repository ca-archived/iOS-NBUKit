//
//  ActiveView.m
//  NBUCompatibility
//
//  Created by Ernesto Rivera on 2012/03/05.
//  Copyright (c) 2012-2014 CyberAgent Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "ActiveView.h"
#import "NBUKitPrivate.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_COMPATIBILITY

#define kMarginFromTop 30.0
#define kAnimationDuration 0.3

NSString * const SizeThatFitsChangedNotification = @"SizeThatFitsChangedNotification";
NSString * const ScrollToVisibleNotification = @"ScrollToVisibleNotification";
NSString * const ActiveViewTappedNotification = @"ActiveViewTappedNotification";
NSString * const ActiveViewDoubledTappedNotification = @"ActiveViewDoubledTappedNotification";
NSString * const ActiveViewSwipedNotification = @"ActiveViewSwipedNotification";

// Private class
@interface HighlightMask : UIView

@property (nonatomic) CGFloat cornerRadius;

@end

@implementation ActiveView
{
    // Private properties
    HighlightMask * _highlightMask;
    UITapGestureRecognizer * _tapRecognizer;
    UITapGestureRecognizer * _doubleTapRecognizer;
    UISwipeGestureRecognizer * _swipeRecognizer;
    BOOL _shouldNotFlashHighlight;
}

- (void)commonInit
{
    [super commonInit];
    
    // Animated by default
    _animated = YES;
    
    // Save the original size
    _originalSize = self.bounds.size;
    
    // Dynamic height subviews
    _dynamicHeightSubviews = [NSMutableArray array];
    
    // Deafult highlight corner color and radious
    _highlightColor = [UIColor colorWithWhite:0.0
                                        alpha:0.3];
    _highlightCornerRadius = 4.0;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Make sure to have a mutable array
    _dynamicHeightSubviews = [NSMutableArray arrayWithArray:_dynamicHeightSubviews];
}

- (void)setNoContentsViewText:(NSString *)text
{
    if (!_noContentsView)
        return;
    
    if ([_noContentsView isKindOfClass:[UILabel class]])
    {
        ((UILabel *)_noContentsView).text = text;
    }
    else
    {
        for (UIView * view in _noContentsView.subviews)
        {
            if ([view isKindOfClass:[UILabel class]])
            {
                ((UILabel *)view).text = text;
                break;
            }
        }
    }
}

#pragma mark - Methods/Actions

- (void)tapped:(id)sender
{
    if (!_doNotHighlightOnTap && !_shouldNotFlashHighlight)
        [self flashHighlightMask];
    [[NSNotificationCenter defaultCenter] postNotificationName:ActiveViewTappedNotification
                                                        object:self];
    
    // *** Override in subclasses or listen to ActiveViewTappedNotification ***
}

- (void)doubleTapped:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ActiveViewDoubledTappedNotification
                                                        object:self];
    
    // *** Override in subclasses or listen to ActiveViewTappedNotification ***
}

- (void)swiped:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ActiveViewSwipedNotification
                                                        object:self];
    
    // *** Override in subclasses or listen to ActiveViewSwipedNotification ***
}

- (void)postSizeThatFitsChangedNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SizeThatFitsChangedNotification
                                                        object:self];
}

- (void)postScrollToVisibleNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ScrollToVisibleNotification
                                                        object:self];
}

#pragma mark - Layout

- (BOOL)isAnimated
{
    // If not yet visible don't animate
    if (!self.window)
    {
        return NO;
    }
    
    // Try to rely on superviews
//    if (!_animated && [self.superview isKindOfClass:[ActiveView class]])
//    {
//        return [(ActiveView *)self.superview isAnimated];
//    }
    
    return _animated;
}

// For complex layouts override layoutSubviews
- (CGSize)sizeThatFits:(CGSize)size
{
    NBULogVerbose(@">>> %@ sizeThatFits: %@ dynamicHeightViews: %@",
                  NSStringFromClass([self class]),
                  NSStringFromCGSize(size),
                  _dynamicHeightSubviews);
    
    // Empty or no flexible subviews?
    if ((self.empty && _noContentsView) ||
        !_dynamicHeightSubviews ||
        ([_dynamicHeightSubviews count] == 0))
    {
        NBULogVerbose(@"<<< %@ to %@ (originalSize)",
                      NSStringFromCGSize(self.bounds.size),
                      NSStringFromCGSize(CGSizeMake(size.width, _originalSize.height)));
        return CGSizeMake(size.width,
                          _originalSize.height);
    }
    
    // Start with the original height
    CGFloat heightThatFits = self.bounds.size.height;
    
    // Adjust for each flexible subview...
    CGSize sizeDiff;
    CGSize sizeThatFits;
    for (UIView * view in _dynamicHeightSubviews)
    {
        sizeDiff.width = self.bounds.size.width - view.bounds.size.width;
        sizeThatFits = [view sizeThatFits:CGSizeMake(size.width - sizeDiff.width, CGFLOAT_MAX)];
        heightThatFits += sizeThatFits.height - view.bounds.size.height;
    }
    
    NBULogVerbose(@"<<< %@ to %@",
                  NSStringFromCGSize(self.bounds.size),
                  NSStringFromCGSize(CGSizeMake(size.width, heightThatFits)));
    return CGSizeMake(size.width,
                      heightThatFits);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // If empty show the noContentsView
    if (self.isEmpty)
    {
        // Add to view hierarchy if needed
        if (_noContentsView.superview != self)
        {
            _noContentsView.center = CGPointMake(CGRectGetMidX(self.bounds),
                                                 kMarginFromTop + (_noContentsView.frame.size.height / 2.0));
            [self addSubview:_noContentsView];
        }
        [UIView animateWithDuration:self.animated ? kAnimationDuration : 0.0
                              delay:0.0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{_noContentsView.alpha = 1.0;}
                         completion:NULL];
    }
    else
    {
        [UIView animateWithDuration:self.animated ? kAnimationDuration : 0.0
                              delay:0.0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{_noContentsView.alpha = 0.0;}
                         completion:NULL];
    }
}

- (void)setNoContentsView:(UIView *)noContentsView
{
    [_noContentsView removeFromSuperview];
    _noContentsView = noContentsView;
}

#pragma mark - Gesture management

- (BOOL)canBecomeFirstResponder
{
    return YES;
    // return _recognizeTap || _tapRecognizer.enabled; <- If enabled we shoudl add swipe and double taps
}

- (void)setHighlightCornerRadius:(CGFloat)highlightCornerRadius
{
    _highlightCornerRadius = highlightCornerRadius;
    
    if (_highlightMask)
    {
        _highlightMask.cornerRadius = highlightCornerRadius;
        [_highlightMask setNeedsDisplay];
    }
}

- (void)setHighlightColor:(UIColor *)highlightColor
{
    _highlightColor = highlightColor;
    
    if (_highlightMask)
    {
        _highlightMask.backgroundColor = highlightColor;
        [_highlightMask setNeedsDisplay];
    }
}

- (void)setRecognizeTap:(BOOL)recognizeTap
{
    _recognizeTap = recognizeTap;
    
    if (recognizeTap)
    {
        if (!_tapRecognizer)
        {
            _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                     action:@selector(tapped:)];
            _tapRecognizer.delegate = self;
            [self addGestureRecognizer:_tapRecognizer];
        }
        else
        {
            _tapRecognizer.enabled = YES;
        }
    }
    else
    {
        _tapRecognizer.enabled = NO;
    }
}

- (void)setRecognizeDoubleTap:(BOOL)recognizeDoubleTap
{
    _recognizeDoubleTap = recognizeDoubleTap;
    
    if (recognizeDoubleTap)
    {
        if (!_doubleTapRecognizer)
        {
            _doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(doubleTapped:)];
            _doubleTapRecognizer.delegate = self;
            _doubleTapRecognizer.numberOfTapsRequired = 2;
            [self addGestureRecognizer:_doubleTapRecognizer];
        }
        else
        {
            _doubleTapRecognizer.enabled = YES;
        }
    }
    else
    {
        _doubleTapRecognizer.enabled = NO;
    }
}

- (void)setRecognizeSwipe:(BOOL)recognizeSwipe
{
    _recognizeSwipe = recognizeSwipe;
    
    if (recognizeSwipe)
    {
        if (!_swipeRecognizer)
        {
            _swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                         action:@selector(swiped:)];
            _swipeRecognizer.delegate = self;
            [self addGestureRecognizer:_swipeRecognizer];
        }
        else
        {
            _swipeRecognizer.enabled = YES;
        }
    }
    else
    {
        _swipeRecognizer.enabled = NO;
    }
}

- (HighlightMask *)highlightMask
{
    if (!_highlightMask)
    {
        _highlightMask = [[HighlightMask alloc] initWithFrame:self.bounds];
        _highlightMask.backgroundColor = _highlightColor;
        _highlightMask.cornerRadius = _highlightCornerRadius;
        [self addSubview:_highlightMask];
    }
    return _highlightMask;
}

- (void)showHighlightMask
{
    [self bringSubviewToFront:self.highlightMask];
    _highlightMask.alpha = 1.0;
}

- (void)hideHighlightMask
{
    [UIView animateWithDuration:0.1
                     animations:^{_highlightMask.alpha = 0.0;}];
}

- (void)flashHighlightMask
{
    [self showHighlightMask];
    [self performSelector:@selector(hideHighlightMask)
               withObject:nil
               afterDelay:0.1];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    if (((UITouch *)[touches anyObject]).view == self &&
        _recognizeTap)
    {
        if (!_doNotHighlightOnTap)
            [self showHighlightMask];
        _shouldNotFlashHighlight = YES;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if (((UITouch *)[touches anyObject]).view == self)
    {
        [self hideHighlightMask];
        _shouldNotFlashHighlight = NO;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    
    if (((UITouch *)[touches anyObject]).view == self)
    {
        [self hideHighlightMask];
        _shouldNotFlashHighlight = NO;
    }
}

// Only receive direct touches?
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch
{
    BOOL receive = NO;
    
    // Single tap
    if (gestureRecognizer == _tapRecognizer)
    {
        receive = _recognizeTap && (_receiveSubviewTouches ||
                                    (touch.view == self) ||
                                    !touch.view.userInteractionEnabled ||
                                    ([touch.view isKindOfClass:[ActiveView class]] &&
                                     !((ActiveView *)touch.view).recognizeTap));
    }
    // Double tap
    else if (gestureRecognizer == _doubleTapRecognizer)
    {
        receive = _recognizeDoubleTap && (_receiveSubviewTouches ||
                                          (touch.view == self) ||
                                          !touch.view.userInteractionEnabled ||
                                          ([touch.view isKindOfClass:[ActiveView class]] &&
                                           !((ActiveView *)touch.view).recognizeDoubleTap));
    }
    // Swipe
    else if (gestureRecognizer == _swipeRecognizer)
    {
        receive = _recognizeSwipe;
    }
    
    NBULogVerbose(@"%@ shouldReceiveTouch: %@",
                  NSStringFromClass([self class]),
                  NBUStringFromBOOL(receive));
    return receive;
}

@end


@implementation ActiveLabel


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        // Save the original size
        _originalSize = self.bounds.size;
        _maxSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    }
    return self;
}

// For complex layouts override layoutSubviews
- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize sizeThatFits = [super sizeThatFits:size];
    
    // Grows height
    if (self.autoresizingMask & UIViewAutoresizingFlexibleHeight)
    {
        if (size.width == CGFLOAT_MAX)
        {
            NBULogWarn(@"Active label autoresizing masks are nor properly set %@", self);
        }
        sizeThatFits = CGSizeMake(size.width,
                                  MAX(sizeThatFits.height, _originalSize.height));
    }
    
    // Only grows width
    else
    {
        if (size.height == CGFLOAT_MAX)
        {
            NBULogWarn(@"Active label autoresizing masks are nor properly set %@", self);
        }
        sizeThatFits = CGSizeMake(MAX(sizeThatFits.width, _originalSize.width),
                                  size.height);
    }
    
    NBULogVerbose(@"<<< %@ to %@ (supper sizeThatFits %@: %@) (al: %@)",
                  NSStringFromCGSize(self.bounds.size), NSStringFromCGSize(sizeThatFits), NSStringFromCGSize(size), NSStringFromCGSize([super sizeThatFits:size]), self.text);
    
    return CGSizeMake(MIN(sizeThatFits.width, _maxSize.width),
                      MIN(sizeThatFits.height, _maxSize.height));
}

@end


#import <QuartzCore/QuartzCore.h>

@implementation HighlightMask

@dynamic cornerRadius;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.alpha = 0.0;
        self.opaque = NO;
        self.cornerRadius = 4.0;
        self.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                 UIViewAutoresizingFlexibleHeight);
    }
    return self;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    self.layer.cornerRadius = cornerRadius;
}

- (CGFloat)cornerRadius
{
    return self.layer.cornerRadius;
}

@end

