//
//  ObjectSlideView.m
//  NBUCompatibility
//
//  Created by Ernesto Rivera on 2011/12/27.
//  Copyright (c) 2011-2014 CyberAgent Inc.
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

#import "ObjectSlideView.h"
#import "NBUKitPrivate.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_COMPATIBILITY

#define kMinimumHeightToShowPageControl 150.0
#define kImageMargin 5.0
#define kMinimumIntervalToChangePage 2.0
#define kMaximumIntervalToChangePage 20.0
#define kPageControlHeight 20.0

@implementation ObjectSlideView
{
    // Private properties
    NSMutableArray * _views;
    NSUInteger _nVisibleViews;
    NSUInteger _nViews;
    UIView * _emptyView;
    BOOL _dontUpdatePageControl;
    BOOL _isDragging;
    NSTimer * _randomTimer;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        // Initializations
        _views = [NSMutableArray array];
        _nVisibleViews = 1;
        _centerViews = YES;
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Configure the scrollview
    self.scrollView.delegate = self;
    
    // Configure pageControl
    if (_pageControl)
    {
        CGRect frame = _pageControl.frame;
        frame.origin.y += frame.size.height - kPageControlHeight;
        frame.size.height = kPageControlHeight;
        _pageControl.frame = frame;
        _pageControl.numberOfPages = 0;
    }
}

- (UIScrollView *)scrollView
{
    if (!_scrollView)
    {
        // Create a scrollView and configure if necessary
        _scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        _scrollView.clipsToBounds = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        
        [self insertSubview:_scrollView
                    atIndex:0];
    }
    return _scrollView;
}

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    
    // If out of screen invalidate timer
    if (!self.window)
    {
        [_randomTimer invalidate];
    }
}

#pragma mark - Object array management

- (void)setObject:(NSArray *)objectArray
{
    // Remove deleted objects' views
    id object;
    UIView * view;
    for (NSUInteger i = 0; i<[self.objectArray count]; i++)
    {
        object = (self.objectArray)[i];
        if (![objectArray containsObject:object])
        {
            view = _views[i];
            [view removeFromSuperview];
        }
    }
    
    // Update remaining objects and add new ones
    NSMutableArray * tmp = [NSMutableArray array];
    NSUInteger index;
    for (object in objectArray)
    {
        index = [self.objectArray indexOfObject:object];
        
        // Update
        if (index != NSNotFound)
        {
            [self updateView:_views[index] object:object]; // 更新を行う
            
            [tmp addObject:_views[index]];
        }
        // New
        else
        {
            view = [self viewForObject:object];
            [tmp addObject:view];
            [_scrollView addSubview:view];
        }
    }
    _views = tmp;
    super.objectArray = objectArray;
}

- (void)updateView:(UIView *)view object:(id)object
{
    
    // Load view from a Nib file
//    if (self.nibNameForViews)
//    {
        // Also ask delegate to configure it?
        if (view && [self.delegate respondsToSelector:@selector(objectArrayView:configureView:withObject:)])
        {
            [self.delegate objectArrayView:self
                             configureView:view
                                withObject:object];
        }
        // Configure it if it's an ObjectView
        else if ([view isKindOfClass:[ObjectView class]])
        {
            ((ObjectView *)view).object = object;
        }
//    }
}

- (void)addObject:(id)object
{
    [super addObject:object];
    
    // Add its view
    UIView * view = [self viewForObject:object];
    [_views addObject:view];
    [_scrollView addSubview:view];
    
    [self setNeedsLayout];
}

- (void)removeObject:(id)object
{
    // Object index
    NSUInteger index = [self.objectArray indexOfObject:object];
    if (index == NSNotFound)
        return;
    
    [super removeObject:object];
    
    // Remove object's view
    UIView * view = _views[index];
    [_views removeObjectAtIndex:index];
    [view removeFromSuperview];
    
    [self setNeedsLayout];
}

- (NSArray *)currentViews
{
    return [NSArray arrayWithArray:_views];
}

#pragma mark - Actions

- (void)tapped:(id)sender
{
    [super tapped:sender];
    
    NSUInteger index = 0;
    if ([sender isKindOfClass:[UIGestureRecognizer class]])
    {
        index = floor(([sender locationInView:self].x + _scrollView.contentOffset.x) /
                      (_scrollView.contentSize.width  / _nViews));
        NBULogVerbose(@"location %f offset %f viewWidth %f index %@",
                      [sender locationInView:self].x, _scrollView.contentOffset.x, (_scrollView.contentSize.width  / _nViews), @(index));
    }
    
    [self presentModalFromItemAtIndex:index];
}

- (void)presentModal:(id)sender
{
    [self presentModalFromItemAtIndex:0];
}

- (void)presentModalFromItemAtIndex:(NSUInteger)index
{
#ifdef NBUCOMPATIBILITY
    ObjectSlideViewController * controller = [[NSBundle loadNibNamed:@"ObjectSlideViewController"
                                                               owner:nil
                                                             options:nil] objectAtIndex:0];
    controller.objectView.nibNameForViews = self.nibNameForViews;
    controller.object = self.objectArray;
    
    [self.viewController.navigationController pushViewController:controller
                                                        animated:YES];
    
    NBULogVerbose(@"content width %f current page %d frame width %f",
                  _scrollView.contentSize.width, _pageControl.currentPage, _scrollView.frame.size.width);
    
    controller.objectView.pageControl.numberOfPages = _nViews;
    controller.objectView.pageControl.currentPage = index;
#endif
}

- (IBAction)changePage:(id)sender
{
    // User scrolled, cancel random changes
    self.changePagesRandomly = NO;
    
	// Scroll to the appropriate page
    _dontUpdatePageControl = YES;
    CGRect frame = _scrollView.bounds;
    frame.origin.x = frame.size.width * _pageControl.currentPage;
    [_scrollView scrollRectToVisible:frame animated:YES];
}

#pragma mark - Change pages randomly

- (void)setRandomTimer
{
    // Set timer
    float interval = kMinimumIntervalToChangePage + ((kMaximumIntervalToChangePage - kMinimumIntervalToChangePage) *
                                                     ((arc4random() % 101) / 100.0));
    
    [_randomTimer invalidate];
    _randomTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                    target:self
                                                  selector:@selector(changePageRandomly)
                                                  userInfo:nil
                                                   repeats:NO];
}

- (void)changePageRandomly
{
    if ((arc4random() % 2) && (_pageControl.currentPage > 0))
        _pageControl.currentPage--;
    else
        _pageControl.currentPage++;
    
    [self changePage:self];
    [self setRandomTimer];
}

- (void)setChangePagesRandomly:(BOOL)changePagesRandomly
{
    // Invalidate timer or too few views?
    if (!changePagesRandomly || self.objectArray.count <= 1)
    {
        [_randomTimer invalidate];
        return;
    }
    [self setRandomTimer];
}

#pragma mark - Scroll view delegate

// Update page control if needed ToDo fix
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    [[UIApplication sharedApplication] sendAction:@selector(postScrollViewContentOffsetChangedNotification)
                                               to:nil
                                             from:self
                                         forEvent:nil];
    
    // No need to update page control?
    if (_dontUpdatePageControl)
        return;
	
    // User scrolled, cancel random changes
    self.changePagesRandomly = NO;
    
    // Switch the indicator when more than 50% of the previous/next page is visible
    int page = 0;
    float pageWidth = _scrollView.frame.size.width;
    float offset = _scrollView.contentOffset.x;
    if (_scrollView.contentOffset.x > 0)
    {
        if ((int)offset % (int)pageWidth != 0)
        {
            page = ceil(offset/pageWidth);
        }
        else
        {
            page = floor((offset - pageWidth / 2) / pageWidth) + 1;
        }
        
    }
    
    NBULogVerbose(@"currentPage %d",page);
    _pageControl.currentPage = page;
}

// At the begin and end of scroll dragging reset pageControlUsed
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _dontUpdatePageControl = NO;
    _isDragging = YES;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _dontUpdatePageControl = NO;
    _isDragging = NO;
}

#pragma mark - Layout subviews

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Empty?
    if (self.isEmpty)
        return;
    
    [UIView animateWithDuration:self.isAnimated ? 0.3 : 0.0
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         
                         [self _layoutSubviews];
                     }
                     completion:NULL
     ];
}

- (void)_layoutSubviews
{
    // Remove hidden views
    NSMutableArray * visibleViews = [NSMutableArray arrayWithArray:_views];
    NSUInteger index;
    UIView * view;
    for (id object in self.hiddenObjects)
    {
        index = [self.objectArray indexOfObject:object];
        view = _views[index];
        view.hidden = YES;
        [visibleViews removeObject:view];
    }
    
    // Is there a target
    BOOL hasTargetSize = !CGSizeEqualToSize(self.targetObjectViewSize, CGSizeZero);
    
    // Calculate margins, number of views per page and the current view
    NSUInteger currentView = (NSUInteger)_pageControl.currentPage * _nVisibleViews;
    CGSize availableSize = CGSizeMake(self.bounds.size.width,
                                      self.bounds.size.height - (2 * self.margin.height));
    if(self.margin.width == 0.0)
    {
        self.margin = CGSizeMake(MIN(kImageMargin, availableSize.width - availableSize.height),
                                 self.margin.height);
    }
    _nViews = visibleViews.count + ((self.hasMoreObjects && self.loadMoreView)? 1 : 0);
    if (hasTargetSize)
    {
        _nVisibleViews = floor(availableSize.width / (self.targetObjectViewSize.width + self.margin.width));
    }
    else
    {
        _nVisibleViews = floor(availableSize.width / (availableSize.height + self.margin.width));
    }
    _nVisibleViews = MIN(_nVisibleViews, _nViews);
    _nVisibleViews = MAX(_nVisibleViews, 1);
    
    // If the frame is too small hide page control
    _pageControl.alpha = (availableSize.height < kMinimumHeightToShowPageControl) ? 0.0 : 1.0;
    
    // Adjust scrollView avoiding changing the current page
    CGRect frame;
    if (_centerViews)
    {
        frame = CGRectMake(0.0,
                           self.margin.height,
                           hasTargetSize ? _nVisibleViews * (self.targetObjectViewSize.width + self.margin.width):
                           _nVisibleViews * (availableSize.height + self.margin.width),
                           hasTargetSize ? self.targetObjectViewSize.height :
                           availableSize.height);
        frame.origin.x = (self.frame.size.width - frame.size.width) / 2.0;
    }
    else
    {
        frame = CGRectMake(0.0,
                           self.margin.height,
                           availableSize.width,
                           hasTargetSize ? self.targetObjectViewSize.height :
                           availableSize.height);
    }
    _dontUpdatePageControl = YES;
    _scrollView.frame = frame;
    
    // Adjust views' frames
    frame = CGRectMake(_centerViews ? self.margin.width / 2.0:
                       self.margin.width,
                       0.0,
                       hasTargetSize ? self.targetObjectViewSize.width :
                       frame.size.height,
                       hasTargetSize ? self.targetObjectViewSize.height :
                       frame.size.height);
    for (view in visibleViews)
    {
        view.frame = frame;
        
        // Prepare next frame
        frame.origin.x += frame.size.width + self.margin.width;
    }
    
    // Load more view
    if (self.hasMoreObjects && self.loadMoreView)
    {
        if (self.loadMoreView.superview != self)
        {
            [self addSubview:self.loadMoreView];
        }
        self.loadMoreView.frame = frame;
        frame.origin.x += frame.size.width + self.margin.width;
    }
    else
    {
        [self.loadMoreView removeFromSuperview];
    }
    
    // Adjust page control and scroll view keeping the current image
    _pageControl.numberOfPages = ceil(_nViews * 1.0 / _nVisibleViews);
    _pageControl.currentPage = _pageControl.numberOfPages; // Needed for a UIKit bug
    _pageControl.currentPage = currentView / _nVisibleViews;
    
    _scrollView.contentSize = CGSizeMake(_centerViews ? frame.origin.x - (self.margin.width / 2.0) :
                                         frame.origin.x,
                                         frame.size.height);
    
    NBULogVerbose(@"content width %f current page %@ frame width %f",
                  _scrollView.contentSize.width, @(_pageControl.currentPage), _scrollView.frame.size.width);
    
    CGFloat offsetX = _scrollView.pagingEnabled ? _scrollView.frame.size.width * _pageControl.currentPage : _scrollView.contentOffset.x;
    if (offsetX > 0.0 &&
        offsetX + _scrollView.frame.size.width > _scrollView.contentSize.width)
    {
        offsetX = _scrollView.contentSize.width - _scrollView.frame.size.width;
    }
    
    _scrollView.contentOffset = CGPointMake(offsetX,
                                            0.0);
}

@end

