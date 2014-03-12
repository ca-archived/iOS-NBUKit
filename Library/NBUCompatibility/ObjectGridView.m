//
//  ObjectGridView.m
//  NBUCompatibility
//
//  Created by Ernesto Rivera on 2012/02/29.
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

#import "ObjectGridView.h"
#import "NBUKitPrivate.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_COMPATIBILITY

@implementation ObjectGridView
{
    CGFloat _heightThatFits;
    NSMutableArray * _visibleObjects;
    NSMutableArray * _viewsOrFrames;
    
    BOOL _reuseViewsMode;
    
    NSRange _currentRange;
    CGRect _currentArea;
    
    BOOL _useModelView;
    UIView * _modelView;
    Class _modelClass;
    
    NSMutableSet * _reusableViews;
//    NSMutableString * _debug;
}

@dynamic delegate;

- (void)resetGridView
{
    [self stopObservingScrollViewDidScroll];
    self.objectArray = nil;
    _visibleObjects = nil;
    _reuseViewsMode = NO;
    _currentRange = NSMakeRange(0, 0);
    _currentArea = CGRectZero;
    _useModelView = NO;
}

- (void)commonInit
{
    [super commonInit];
    
    // Init reusable views
    _reusableViews = [NSMutableSet set];
    
    // Register for memory warnings
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMemoryWarning)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    
//        // By default grid views don't animate
//        self.animated = NO;

//        // Compatibility mode
//        _forceDoNotReuseViews = YES;
//        _forceLoadAllViews = YES;
}

- (void)dealloc
{
    // Stop observing
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    if (self.isEmpty)
    {
        NBULogVerbose(@"<<< %@ to %@ (gv originalSize)",
              NSStringFromCGSize(self.bounds.size),
              NSStringFromCGSize(CGSizeMake(size.width, self.originalSize.height)));
        return CGSizeMake(size.width,
                          self.originalSize.height);
    }
    NBULogVerbose(@"<<< %@ to %@ (gv)",
          NSStringFromCGSize(self.bounds.size),
          NSStringFromCGSize(CGSizeMake(size.width,
                                        _heightThatFits)));
    return CGSizeMake(size.width,
                      _heightThatFits);
}

#pragma mark - Object array management

- (void)addObject:(id)object
{
    [super addObject:object];
    
    [self setNeedsLayout];
}

- (void)removeObject:(id)object
{
    // Object index
    NSUInteger index = [self.objectArray indexOfObject:object];
    if (index == NSNotFound)
        return;
    
    [super removeObject:object];
    
    [self setNeedsLayout];
}

- (void)setObject:(id)object
           hidden:(BOOL)yesOrNo
{
    [super setObject:object
              hidden:yesOrNo];
    
    [self setNeedsLayout];
}

- (NSArray *)currentViews
{
    NSMutableArray * currentViews = [NSMutableArray array];
    for (id viewOrFrame in _viewsOrFrames)
    {
        if ([viewOrFrame isKindOfClass:[UIView class]] && viewOrFrame != self.loadMoreView)
        {
            [currentViews addObject:viewOrFrame];
        }
    }
    return currentViews;
}

#pragma mark - Scroll notifications

- (UIScrollView *)scrollView
{
    // Try to precise which scroll view
    UIViewController * controller = self.viewController;
    UIScrollView * scrollView;
    if (controller && [controller isKindOfClass:[ScrollViewController class]])
    {
        scrollView = ((ScrollViewController *)controller).scrollView;
    }
    return scrollView;
}

- (void)startObservingScrollViewDidScroll
{
    NBULogVerbose(@"Start observing...");
    [[NSNotificationCenter defaultCenter] removeObserver:self // Avoid observing multiple times!
                                                    name:ScrollViewDidScrollNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollViewDidScroll:)
                                                 name:ScrollViewDidScrollNotification
                                               object:self.scrollView];
}

- (void)stopObservingScrollViewDidScroll
{
    NBULogVerbose(@"Stop observing");
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:ScrollViewDidScrollNotification
                                                  object:nil];
}

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    
    if (self.window && _reuseViewsMode)
    {
        [self startObservingScrollViewDidScroll];
    }
    else
    {
        [self stopObservingScrollViewDidScroll];
    }
}

- (void)scrollViewDidScroll:(NSNotification *)notification
{
    // ScrollView's scrolled rect in this view's coordinates
    UIScrollView * scrollView = notification.object;
    if (!scrollView)
    {
        scrollView = self.scrollView;
    }
    CGRect scrolledRect = scrollView.bounds;
    scrolledRect.origin = scrollView.contentOffset;
    scrolledRect = [self convertRect:scrolledRect
                            fromView:scrollView];
    
    [self refreshArea:scrolledRect];
}

#pragma mark - Layout subviews

- (void)didReceiveMemoryWarning
{
    [_reusableViews removeAllObjects];
}

- (void)setNeedsLayout
{
    // Invalidate heightThatFits
    _heightThatFits = -1.0;
    
    [super setNeedsLayout];
}

- (void)layoutSubviews
{
    // Ignore if heightThatFits matches
    if (_heightThatFits == self.bounds.size.height)
    {
        return;
    }
    
    NBULogVerbose(@"layoutSubviews %@ subviews %@", NSStringFromCGSize(self.frame.size), @(self.subviews.count));
    
    [super layoutSubviews];
    
    // Empty?
    if (self.isEmpty)
    {
        // Remove all views
        UIView * view;
        for (view in _reusableViews)
        {
            [view removeFromSuperview];
        }
        for (view in self.currentViews)
        {
            [view removeFromSuperview];
            if (!_forceDoNotReuseViews && [self isViewReusable:view])
            {
                [_reusableViews addObject:view];
            }
        }
        
        [self.loadMoreView removeFromSuperview];
        if (self.bounds.size.height < self.originalSize.height)
        {
            [self postSizeThatFitsChangedNotification];
        }
        return;
    }

    // Not empty
    NBULogVerbose(@"animated %d", self.isAnimated);
    
    // There seems to be a big time difference between using animations and not, so I split them up
    if(self.isAnimated) {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [self reloadGrid];
                         }
                         completion:^(BOOL finished){

                             // Notify needed change?
                             if (//self.autoresizingMask & UIViewAutoresizingFlexibleHeight &&    // Has flexible height and...
                                 _heightThatFits != self.bounds.size.height)                    // ...height that fits is different?
                             {
                                 // Fire notification!
                                 NBULogVerbose(@"! %p heightThatFits changed: %f should be %f",
                                            self,
                                            self.bounds.size.height,
                                            _heightThatFits);
                                 [self postSizeThatFitsChangedNotification];
                             }
                         }];
    } else {
        [self reloadGrid];
    
        // Notify needed change?
        if (_heightThatFits != self.bounds.size.height)// ...height that fits is different?
        {
            // Fire notification!
            NBULogVerbose(@"! %p heightThatFits changed: %f should be %f",
                       self,
                       self.bounds.size.height,
                       _heightThatFits);
            [self postSizeThatFitsChangedNotification];
        }
    }
}

- (void)reloadGrid
{
    // Remove all views
    UIView * view;
    for (view in _reusableViews)
    {
        [view removeFromSuperview];
    }
    for (view in self.currentViews)
    {
        [view removeFromSuperview];
        if (!_forceDoNotReuseViews && [self isViewReusable:view])
        {
            [_reusableViews addObject:view];
        }
    }
    [self.loadMoreView removeFromSuperview];
    
    // Prepare the model view
    if (self.nibNameForViews)
    {
        _modelView = [self dequeueOrLoadViewFromNib];
        _modelClass = [_modelView class];
    }
    
    // Identify visible objects
    _visibleObjects = [NSMutableArray arrayWithArray:self.objectArray];
    for (view in self.hiddenObjects)
    {
        [_visibleObjects removeObject:view];
    }
    if (self.hasMoreObjects && self.loadMoreView)
    {
        [_visibleObjects addObject:self.loadMoreView];
    }
    
    // Setup the current area
    _currentArea.size = CGSizeMake(MAX(_currentArea.size.width, self.bounds.size.width),
                                   MAX(_currentArea.size.height, 480.0));
    
    NBULogVerbose(@"reloadGrid: %@ visible objects (%@ hidden), current area %@, %@ reusable views",
                  @(_visibleObjects.count), @(self.hiddenObjects.count), NSStringFromCGRect(_currentArea), @(_reusableViews.count));
    
    // Rebuild _viewsOrFrames
    CGRect frame = CGRectMake(self.margin.width,
                              self.margin.height,
                              self.targetObjectViewSize.width,
                              self.targetObjectViewSize.height);
    CGFloat currentRowHeight = 0.0;
    _viewsOrFrames = [NSMutableArray array];
    _currentRange = NSMakeRange(NSNotFound, 0);
    _reuseViewsMode = NO;
    id object;
    for (NSUInteger index = 0; index < _visibleObjects.count; index++)
    {
        object = _visibleObjects[index];

        // Use model view if outside current area
        _useModelView = (!_forceLoadAllViews && !CGRectIntersectsRect(frame, _currentArea));
        
        // Update current range
        if (!_useModelView)
        {
            if (_currentRange.location == NSNotFound)
            {
                _currentRange.location = index;
            }
            _currentRange.length++;
        }
        
        // Can we skip the view?
        if (_useModelView &&
            _equallySizedViews &&
            !CGSizeEqualToSize(frame.size, CGSizeZero))
        {
            view = nil;
        }
        // We can't
        else
        {
            // Prepare a view
            view = [self viewForObject:object];
            
            // Do we need to calculate the view's size?
            if (!_equallySizedViews ||
                CGSizeEqualToSize(frame.size, CGSizeZero))
            {
                [self adjustViewSize:view];
                frame.size = view.frame.size;
            }

        }
        
        // If the view is too wide to fit, begin a new row
        BOOL currentViewOnNextRow = CGRectGetMaxX(frame) + self.margin.width > self.bounds.size.width;
        if(currentViewOnNextRow) {
            frame.origin.x = self.margin.width;
            frame.origin.y = frame.origin.y + currentRowHeight + self.margin.height;
            currentRowHeight = frame.size.height; // It's the only one in the row so far
        } else {
            currentRowHeight = MAX(currentRowHeight, frame.size.height); // The row is as tall as the tallest inhabitant
        }
        
        // Update _viewsOrFrames...
        if (view && view != _modelView)
        {
            view.frame = frame;
            [self addSubview:view];
            
            // ...with a view
            [_viewsOrFrames addObject:view];
            
        }
        else
        {
            // ...with a frame
            [_viewsOrFrames addObject:[NSValue valueWithCGRect:frame]];
            
            // Activated reuse mode
            if (!_reuseViewsMode)
            {
                NBULogVerbose(@"Reuse mode ON");
                _reuseViewsMode = YES;
            }
        }
        
        // Update values for the next view
        frame.origin.x += frame.size.width + self.margin.width;
        
        // If the next view will be outside of the bounds, begin new row
        if (frame.origin.x + self.margin.width >= self.bounds.size.width)
        {
            frame.origin = CGPointMake(self.margin.width,
                                       frame.origin.y + currentRowHeight + self.margin.height);
            currentRowHeight = 0.0;
        }
    }

    _heightThatFits = frame.origin.y + currentRowHeight + self.margin.height;
    
    // Listen to scroll notifications?
    if (_reuseViewsMode)
    {
        [self startObservingScrollViewDidScroll];
    }
    else
    {
        [self stopObservingScrollViewDidScroll];
    }
    
    // Check for out-of-bounds
    if (_currentRange.location == NSNotFound)
    {
        _currentRange.location = 0;
    }
    
    // Clean up model view
    _modelView = nil;
    _useModelView = NO;
    
    NBULogVerbose(@"reloadGrid finished: frame %@, range %@, %@ subviews",
                  NSStringFromCGRect(self.frame), NSStringFromRange(_currentRange), @(self.currentViews.count));
    NBULogVerbose(@"%@", _viewsOrFrames);
}

- (void)setFrame:(CGRect)frame
{
    super.frame = frame;
    
    // Make sure to refresh the current scrolled area
    [self scrollViewDidScroll:nil];
}

- (void)refreshArea:(CGRect)area
{
    NBULogVerbose(@"refreshArea: %@", NSStringFromCGRect(area));
    //    UIEdgeInsets insets = UIEdgeInsetsMake(-50.0, 0.0, -50.0, 0.0); // Test
    UIEdgeInsets insets = UIEdgeInsetsMake(100.0, 0.0, 100.0, 0.0);
    
    // Calculate new current area
    NSRange lastRange = _currentRange;
    CGRect lastArea = _currentArea;
    _currentArea = CGRectIntersection(self.bounds, CGRectMake(area.origin.x - insets.left,
                                                              area.origin.y - insets.top,
                                                              area.size.width + insets.left + insets.right,
                                                              area.size.height + insets.top + insets.bottom));
    if (CGRectIsNull(_currentArea))
    {
        _currentArea = CGRectZero;
    }
    
    NSInteger index;
    BOOL insideCurrentArea = YES;
//    _debug = [NSMutableString string];
    
    // Moving down?
    if (lastArea.origin.y < _currentArea.origin.y ||
        (lastArea.origin.y == _currentArea.origin.y && lastArea.size.height < _currentArea.size.height))
    {
//        [_debug appendFormat:@"%@ %@ >>>", NSStringFromCGRect(_currentArea), NSStringFromRange(lastRange)];
        index = (NSInteger)lastRange.location;
        
//        [_debug appendFormat:@"(R:%d)", index];
        
        // Reuse views from the lastRange
        for (;
             index < (lastRange.location + lastRange.length) && index < _viewsOrFrames.count;
             index++)
        {
            insideCurrentArea = [self collectReusableViewAtIndex:(NSUInteger)index];
            
            // Jump if current area is reached
            if (insideCurrentArea)
            {
                _currentRange.location = (NSUInteger)index;
                index = (NSInteger)(lastRange.location + lastRange.length);
                break;
            }
            
            // Current location moves as we collect views
            _currentRange.location = (NSUInteger)index;
        }
        // Update lenght
        _currentRange.length += lastRange.location - _currentRange.location;
        
//        [_debug appendFormat:@"(F:%d)", index];
        
        // Make sure we have reached the current area
        if (!insideCurrentArea)
        {
            for (;
                 !insideCurrentArea && index < _viewsOrFrames.count;
                 index++)
            {
                _currentRange.location = (NSUInteger)index;
                insideCurrentArea = [self checkIfFrameInArea:(NSUInteger)index];
            }
            index--; // Rewind one!
        }
        
//        [_debug appendFormat:@"(P:%d)", index];
        
        // Populate empty frames while in the current area
        for (;
             insideCurrentArea && index < _viewsOrFrames.count;
             index++)
        {
            _currentRange.length = (NSUInteger)index - _currentRange.location;
            insideCurrentArea = [self populateFrameAtIndex:(NSUInteger)index];
        }
        
//        [_debug appendFormat:@"(E:%d)", index];
        
//        [_debug appendFormat:@">>> %@", NSStringFromRange(_currentRange)];
    }
    
    // Moving up
    else
    {
//        [_debug appendFormat:@"%@ %@ <<<", NSStringFromCGRect(_currentArea), NSStringFromRange(lastRange)];
        index = (NSInteger)(lastRange.location + lastRange.length - 1);
        
//        [_debug appendFormat:@"(R:%d)", index];
        
        // Reuse views from the lastRange
        for (;
             index >= lastRange.location && index >= 0;
             index--)
        {
            insideCurrentArea = [self collectReusableViewAtIndex:(NSUInteger)index];
            
            // Jump if current area is reached
            if (insideCurrentArea)
            {
                index = (NSInteger)lastRange.location - 1;
                break;
            }
            
            // Length gets shorter as we collect views
            _currentRange.length--;
        }
        
//        [_debug appendFormat:@"(F:%d)", index];
        
        // Make sure we have reached the current area
        if (!insideCurrentArea)
        {
            for (;
                 !insideCurrentArea && index >= 0;
                 index--)
            {
                insideCurrentArea = [self checkIfFrameInArea:(NSUInteger)index];
            }
            index++; // Rewind one!
            _currentRange.location = (NSUInteger)index;
        }
        
//        [_debug appendFormat:@"(P:%d)", index];
        
        // Populate empty frames while in the current area
        for (;
             insideCurrentArea && index >= 0;
             index--)
        {
            insideCurrentArea = [self populateFrameAtIndex:(NSUInteger)index];
            
            if (insideCurrentArea)
            {
                // Update location and length as we populate
                _currentRange.location = (NSUInteger)index;
                _currentRange.length++;
            }
        }
        
//        [_debug appendFormat:@"(E:%d)", index];
        
//        [_debug appendFormat:@"<<< %@", NSStringFromRange(_currentRange)];
    }
    
//    NBULogVerbose(@"%@", _debug);
}

- (BOOL)collectReusableViewAtIndex:(NSUInteger)index
{
    UIView * view = _viewsOrFrames[index];
//    NSAssert([view isKindOfClass:[UIView class]], @"%@ is not a view", view);
    if (![view isKindOfClass:[UIView class]])
    {
        NBULogWarn(@"Object at index %@ can't be collected (%@ is not a view)", @(index), view);
        return NO;
    }
    
    
    // View inside current area?
    if (CGRectIntersectsRect(view.frame, _currentArea))
    {
        // We reached the area!
//        [_debug appendString:@"|"];
        return YES;
    }
    
    // Not a reusable view?
    if (![self isViewReusable:view])
    {
        // Then just skip it
//        [_debug appendString:@"_"];
        return NO;
    }
    
    // Mark as reusable
    if (!_forceDoNotReuseViews)
    {
        [_reusableViews addObject:view];
    }
    
    // Replace view for a frame
    _viewsOrFrames[index] = [NSValue valueWithCGRect:view.frame];
//    [_debug appendString:@"^"];
    return NO;
}

- (BOOL)isViewReusable:(UIView *)view
{
    // For now...
    return [view isMemberOfClass:_modelClass];
}

- (BOOL)checkIfFrameInArea:(NSUInteger)index
{
    id viewOrFrame = _viewsOrFrames[index];
    CGRect frame;
    
    if ([viewOrFrame isKindOfClass:[UIView class]])
    {
//        [_debug appendString:@"_"];
        frame = ((UIView *)viewOrFrame).frame;
    }
    else
    {
//        [_debug appendString:@" "];
        frame = ((NSValue *)viewOrFrame).CGRectValue;
    }
    
    return CGRectIntersectsRect(frame, _currentArea);
}

- (BOOL)populateFrameAtIndex:(NSUInteger)index
{
    id viewOrFrame = _viewsOrFrames[index];
    CGRect frame;
    
    // Skip non reusable views
    if ([viewOrFrame isKindOfClass:[UIView class]])
    {
//        [_debug appendString:@"_"];
        frame = ((UIView *)viewOrFrame).frame;
        return CGRectIntersectsRect(frame, _currentArea);
    }
    
    
    // Outside current area?
    frame = ((NSValue *)viewOrFrame).CGRectValue;
    if (!CGRectIntersectsRect(frame, _currentArea))
    {
        // We left the area!
//        [_debug appendString:@"|"];
        return NO;
    }
    
    // Add a view and replace the frame
    UIView * view = [self viewForObject:_visibleObjects[index]];
    view.frame = frame;
    if (view.superview != self)
    {
        [self addSubview:view];
    }
    _viewsOrFrames[index] = view;
    
    return YES;
}

- (UIView *)dequeueOrLoadViewFromNib
{
    // Model view?
    if (_useModelView && _modelView)
    {
        return _modelView;
    }
    
    // Try to reuse
    UIView * view = [_reusableViews anyObject];
    if (view)
    {
//        [_debug appendString:@"•"];
        [_reusableViews removeObject:view];
        return view;
    }
    
    // Load a new one as a last resort
    //[_debug appendString:@"*"];
    return [NSBundle loadNibNamed:self.nibNameForViews
                             owner:self
                           options:nil][0];
}

@end

