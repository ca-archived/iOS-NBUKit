//
//  NBUGalleryViewController.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2013/04/01.
//  Copyright (c) 2013 CyberAgent Inc.
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

#import "NBUGalleryViewController.h"
#import "NBUKitPrivate.h"

// Private category
@interface NBUGalleryViewController (Private) <UIScrollViewDelegate>

@end


@implementation NBUGalleryViewController
{
	NSRange _currentPreloadedRange;
    
	BOOL _isScrolling;
	
	UIStatusBarStyle _previousStatusBarStyle;
    UIBarStyle _previousNavigationBarStyle;
	
	UIView * _container;        // Used as view for the controller
	UIScrollView * _scrollView;
    UIScrollView * _thumnailsScrollView;
	
	NSMutableArray * _thumbnailViews;
	NSMutableArray * _views;
}

@synthesize objectArray = _objectArray;
@synthesize nibNameForViews = _nibNameForViews;
@synthesize nibNameForThumbnails = _nibNameForThumbnails;
@synthesize imageLoader = _imageLoader;
@synthesize imagePreloadCount = _imagePreloadCount;
@synthesize startingIndex = _startingIndex;
@synthesize currentIndex = _currentIndex;
@synthesize fullscreen = _fullscreen;
@synthesize thumbnailSize = _thumbnailSize;
@synthesize thumbnailMargin = _thumbnailMargin;
@synthesize spaceBetweenViews = _spaceBetweenViews;
@synthesize updatesTitle = _updatesTitle;
@synthesize updatesBars = _updatesBars;
@synthesize thumbnailsGridView = _thumbnailsGridView;
@synthesize previousButton = _previousButton;
@synthesize nextButton = _nextButton;
@synthesize pageControl = _pageControl;
@synthesize toggleThumbnailsViewButton = _toggleThumbnailsViewButton;
@synthesize captionLabel = _captionLabel;
@synthesize showThumbnailsView = _showThumbnailsView;
@synthesize navigationBarStyle = _navigationBarStyle;
@synthesize statusBarStyle = _statusBarStyle;
@synthesize viewsToHide = _viewsToHide;

- (void)commonInit
{
    [super commonInit];
    
    // Default values
    _nibNameForViews = @"NBUGalleryView";
    _nibNameForThumbnails = @"NBUGalleryThumbnailView";
    _updatesBars = YES;
    self.hidesBottomBarWhenPushed = YES;
    _updatesTitle = YES;
    _imagePreloadCount = 1;
    _spaceBetweenViews = 10.0;
    _thumbnailSize = CGSizeMake(75.0, 75.0);
    _thumbnailMargin = CGSizeMake(4.0, 4.0);
    _statusBarStyle = UIStatusBarStyleBlackTranslucent;
    _navigationBarStyle = UIBarStyleBlackTranslucent;
    
    // Create storage objects
    _views = [NSMutableArray array];
    _thumbnailViews = [NSMutableArray array];
    
    // Set the default loader
    _imageLoader = [NBUImageLoader sharedLoader];
}

- (void)loadView
{
    [NSBundle loadNibNamed:self.nibName ? self.nibName : @"NBUGalleryViewController"
                     owner:self
                   options:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set container and it's background color if not set
    _container = self.view;
    _container.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                   UIViewAutoresizingFlexibleHeight);
    if (!_container.backgroundColor)
    {
        _container.backgroundColor = [UIColor blackColor];
    }
    
    // Listen for frame changes to update layout during auto-rotation or going in and out of fullscreen
    [_container addObserver:self
                 forKeyPath:@"frame"
                    options:NSKeyValueObservingOptionOld
                    context:nil];
    
    // Setup scroller
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.autoresizesSubviews = NO;
    _scrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                    UIViewAutoresizingFlexibleHeight);
    _scrollView.frame = CGRectMake(0.0,
                                   0.0,
                                   _container.size.width + _spaceBetweenViews,
                                   _container.size.height);
    [_container insertSubview:_scrollView
                      atIndex:0];
    
    // Setup thumbnails
    if (_thumbnailsGridView)
    {
        _showThumbnailsView = NO;
        _thumbnailsGridView.hidden = YES;
        
        // Add a button to the navigation item to toggle thumbnails?
        if (!_toggleThumbnailsViewButton &&
            !self.navigationItem.rightBarButtonItem)
        {
            _toggleThumbnailsViewButton = [[UIBarButtonItem alloc] initWithTitle:nil
                                                                           style:UIBarButtonItemStyleBordered
                                                                          target:self
                                                                          action:@selector(toggleThumbnailsView:)];
            self.navigationItem.rightBarButtonItem = (UIBarButtonItem *)_toggleThumbnailsViewButton;
            
            [self updateToggleThumbnailsViewButton];
        }
        
        [_container addSubview:_thumbnailsGridView];
    }
	
    // Reload the gallery if possible
    if (_objectArray)
    {
        [self reloadGallery];
    }
}

- (void)viewDidUnload
{
    [_container removeObserver:self
                    forKeyPath:@"frame"];
    _container = nil;
    _scrollView = nil;
    
    [super viewDidUnload];
}

- (void)dealloc
{
    [_container removeObserver:self
                    forKeyPath:@"frame"];
}

- (void)reloadGallery
{
    NBULogVerbose(@"%@", THIS_METHOD);
    
    // Remove previous photo views
    for (UIView * view in _views)
    {
        [view removeFromSuperview];
    }
    [_views removeAllObjects];
    
    // Remove previous thumbnails
    for (UIView * view in _thumbnailViews)
    {
        [view removeFromSuperview];
    }
    [_thumbnailViews removeAllObjects];
    
    // Build the new views
    if (_objectArray.count > 0)
    {
        [self buildViews];
        [self buildThumbnailViews];
        
        // Layout
        [self layoutViews];
    }
    
    // Refresh the current index
    _currentPreloadedRange = NSMakeRange(0, 0);
    self.currentIndex = _startingIndex;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
    self.showThumbnailsView = _showThumbnailsView;
	
	// Update bars' style
    if (!_updatesBars)
        return;
    _previousStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
	[[UIApplication sharedApplication] setStatusBarStyle:_statusBarStyle
                                                animated:animated];
    _previousNavigationBarStyle = self.navigationController.navigationBar.barStyle;
    self.navigationController.navigationBar.barStyle = _navigationBarStyle;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Restore bars' style
    if (!_updatesBars)
        return;
	[[UIApplication sharedApplication] setStatusBarStyle:_previousStatusBarStyle
                                                animated:animated];
    self.navigationController.navigationBar.barStyle = _previousNavigationBarStyle;
}

- (void)resizePhotoViewsWithSize:(CGSize)size
{
	CGFloat dx = 0.0;
    for (UIView * view in _views)
    {
        view.frame = CGRectMake(dx,
                                0.0,
                                size.width - _spaceBetweenViews,
                                size.height);
		dx += size.width;
	}
}

- (void)resetPhotoViewZoomLevels
{
	for (NBUGalleryView * view in _views)
    {
		[view resetZoom];
	}
}

//- (void)removeImageAtIndex:(NSUInteger)index
//{
//	UIView * view = _views[index];
// 	UIView * thumbnail = _thumbnailViews[index];
//    [_views removeObjectAtIndex:index];
//	[_thumbnailViews removeObjectAtIndex:index];
//    
//	[view removeFromSuperview];
//	[thumbnail removeFromSuperview];
//	
//	[self layoutViews];
//	[self updateButtons];
//    [self updateTitle];
//}

- (void)goToPrevious:(id)sender
{
    [self setCurrentIndex:_currentIndex - 1
                 animated:YES];
}

- (void)goToNext:(id)sender
{
    [self setCurrentIndex:_currentIndex + 1
                 animated:YES];
}

- (IBAction)pageControlWasTapped:(id)sender
{
    [self setCurrentIndex:_pageControl.currentPage
                 animated:YES];
}

- (void)layoutViews
{
	[self adjustThumbnailsView];
	[self updateScrollSize];
	[self updateCaption];
	[self resizePhotoViewsWithSize:_scrollView.size];
	[self layoutThumbnails];
	[self scrollToIndex:_currentIndex
               animated:NO];
    
    NBULogVerbose(@"+++ %@\ncontainer %@\nscrollView %@",
                  THIS_METHOD, _container, _scrollView);
}

#pragma mark - Private Methods

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	if([keyPath isEqualToString:@"frame"])
	{
        // Ignore change?
        CGRect oldFrame = [(NSValue *)change[NSKeyValueChangeOldKey] CGRectValue];
        if (CGRectEqualToRect(oldFrame, _container.frame))
            return;
        
        // Update layout
		[self layoutViews];
	}
}

- (void)adjustThumbnailsView
{
    // Calculate bar height
    CGFloat barHeight = 0.0;
    if (self.navigationController.navigationBar.translucent)
    {
        barHeight = self.navigationController.navigationBar.frame.size.height;
    }
    
	_thumbnailsGridView.frame = _container.bounds;
    _thumbnailsGridView.contentInset = UIEdgeInsetsMake(barHeight,
                                                        0.0,
                                                        0.0,
                                                        0.0);
    _thumbnailsGridView.scrollIndicatorInsets = UIEdgeInsetsMake(barHeight,
                                                                 0.0,
                                                                 0.0,
                                                                 0.0);
}

- (void)setFullscreen:(BOOL)fullscreen
{
    [self setEditing:fullscreen
            animated:NO];
}

- (void)toggleFullscreen:(id)sender
{
    [self setFullscreen:!_fullscreen
               animated:YES];
}

- (void)setFullscreen:(BOOL)fullscreen
             animated:(BOOL)animated
{
    if (_showThumbnailsView)
    {
        NBULogWarn(@"Can't go fullscreen when showing thumbnails' view");
        return;
    }
    
    _fullscreen = fullscreen;
    
    [self disableApp];
    
    [[UIApplication sharedApplication] setStatusBarHidden:fullscreen
                                            withAnimation:UIStatusBarAnimationFade];
    [self.navigationController setNavigationBarHidden:fullscreen
                                             animated:animated];
    [UIView animateWithDuration:animated ? 0.2 : 0.0
                     animations:^{
                         
                         for (UIView * view in _viewsToHide)
                         {
                             view.alpha = fullscreen ? 0.0 : 1.0;
                         }
                     }
                     completion:^(BOOL finished){
                         
                         [self enableApp];
                     }];
}

- (void)enableApp
{
	[[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

- (void)disableApp
{
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
}

- (void)didTapPhotoView:(UIView *)photoView
{
	if(_isScrolling)
        return;
	
	// Toggle fullscreen.
	[self setFullscreen:!_fullscreen
               animated:YES];
}

- (void)updateCaption
{
    if (!_captionLabel)
        return;
    
    // Get the caption
    NSString * caption;
    if ([_imageLoader respondsToSelector:@selector(captionForObject:)])
    {
        caption = [_imageLoader captionForObject:_objectArray[_currentIndex]];
    }
    
    // Update label
    if (caption.length > 0)
    {
        _captionLabel.hidden = NO;
        _captionLabel.text = caption;
    }
    else
    {
        _captionLabel.hidden = YES;
        _captionLabel.text = nil;
    }
}

- (void)updateScrollSize
{
	[_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width * _objectArray.count,
                                           _scrollView.frame.size.height)];
}

- (void)updateTitle
{
    if (!_updatesTitle)
        return;
    
    self.navigationItem.title = [NSString stringWithFormat:
                                 NSLocalizedStringWithDefaultValue(@"NBUGalleryViewController title image X of XX",
                                                                   nil, nil,
                                                                   @"%i of %i",
                                                                   @"NBUGalleryViewController title image X of XX"),
                                 _currentIndex + 1,
                                 _objectArray.count];
}

- (void)updateButtons
{
	_previousButton.enabled = _currentIndex > 0;
	_nextButton.enabled = _currentIndex < _objectArray.count - 1;
    _pageControl.numberOfPages = _objectArray.count;
    _pageControl.currentPage = _currentIndex;
}

- (void)setCurrentIndex:(NSInteger)index
{
    [self setCurrentIndex:index
                 animated:NO];
}

- (void)setCurrentIndex:(NSInteger)index
               animated:(BOOL)animated
{
    // Zoom out the previous view?
    if (_currentIndex < (NSInteger)_views.count)
    {
        [_views[_currentIndex] performSelector:@selector(resetZoom)
                                    withObject:nil
                                    afterDelay:0.3];
    }
    
    // Constrain index
    index = MAX(index, 0);
    index = MIN(index, (NSInteger)_objectArray.count);
    _currentIndex = index;
    
    // Update UI
    [self updateCaption];
	[self updateTitle];
	[self updateButtons];
    [self scrollToIndex:_currentIndex
               animated:animated];
    
    // Preload images
    [self updateLoadedImages];
}

- (void)scrollToIndex:(NSUInteger)index
             animated:(BOOL)animated
{
	CGFloat xp = _scrollView.frame.size.width * index;
	_isScrolling = animated;
    [UIView animateWithDuration:animated ? 0.3 : 0.0
                     animations:^
     {
         [_scrollView scrollRectToVisible:CGRectMake(xp,
                                                     0.0,
                                                     _scrollView.frame.size.width,
                                                     _scrollView.frame.size.height)
                                 animated:NO];
     }
                     completion:^(BOOL finished)
     {
         [self scrollingHasEnded];
     }];
}

// creates all the image views for this gallery
- (void)buildViews
{
    NBUGalleryView * view;
	for (NSUInteger i = 0; i < _objectArray.count; i++)
    {
		view = [NSBundle loadNibNamed:_nibNameForViews
                                owner:self
                              options:nil][0];
//		view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//		view.autoresizesSubviews = YES;
		[_scrollView addSubview:view];
		[_views addObject:view];
	}
}

- (void)buildThumbnailViews
{
	UIView * thumbnailView;
	for (NSUInteger i = 0; i < _objectArray.count; i++)
    {
		thumbnailView = [NSBundle loadNibNamed:_nibNameForThumbnails
                                         owner:self
                                       options:nil][0];
		thumbnailView.tag = i;
		[_thumbnailsGridView addSubview:thumbnailView];
		[_thumbnailViews addObject:thumbnailView];
	}
}

- (void)layoutThumbnails
{
	CGFloat dx = _thumbnailMargin.width;
	CGFloat dy = _thumbnailMargin.height;
    CGRect frame = CGRectZero;
	for (UIView * thumbnailView in _thumbnailViews)
    {
        frame = CGRectMake(dx,
                           dy,
                           _thumbnailSize.width,
                           _thumbnailSize.height);
        
		thumbnailView.frame = frame;
		
		// Increment position
		dx += _thumbnailSize.width + _thumbnailMargin.width;
		
		// New row?
		if(dx + _thumbnailSize.width + _thumbnailMargin.width > _thumbnailsGridView.size.width)
		{
			dx = _thumbnailMargin.width;
			dy += _thumbnailSize.height + _thumbnailMargin.height;
		}
	}
	
	// Set the content size of the thumb scroller
	_thumbnailsGridView.contentSize = CGSizeMake(_thumbnailsGridView.size.width,
                                                 CGRectGetMaxY(frame) + _thumbnailMargin.height);
}

- (void)setShowThumbnailsView:(BOOL)yesOrNo
{
    [self setShowThumbnailsView:yesOrNo
                       animated:NO];
}

- (IBAction)toggleThumbnailsView:(id)sender
{
    [self setShowThumbnailsView:!_showThumbnailsView
                       animated:YES];
}

- (void)setShowThumbnailsView:(BOOL)yesOrNo
                     animated:(BOOL)animated
{
    if (!_thumbnailsGridView)
        return;
    
    _showThumbnailsView = yesOrNo;
    
    // Show?
    if (yesOrNo)
    {
        [self layoutThumbnails];
        [self loadAllThumbnails];
        [self scrollThumbnailsViewToIndex:_currentIndex
                                 animated:NO];
    }
    
    // Animate transition
    [UIView transitionWithView:_thumbnailsGridView
                      duration:animated ? 0.666 : 0.0
                       options:yesOrNo ? UIViewAnimationOptionTransitionCurlDown : UIViewAnimationOptionTransitionCurlUp
                    animations:^{
                        _thumbnailsGridView.hidden = !yesOrNo;
                    }
                    completion:NULL];
    [UIView animateWithDuration:animated ? 0.2 : 0.0
                     animations:^{
                         [self updateToggleThumbnailsViewButton];
                     }];
}

- (void)updateToggleThumbnailsViewButton
{
    _toggleThumbnailsViewButton.title = (_showThumbnailsView ?
                                         NSLocalizedStringWithDefaultValue(@"NBUGalleryViewController show thumbnails button",
                                                                           nil, nil,
                                                                           @"Close",
                                                                           @"NBUGalleryViewController show thumbnails button") :
                                         NSLocalizedStringWithDefaultValue(@"NBUGalleryViewController hide thumbnails button",
                                                                           nil, nil,
                                                                           @"Show all",
                                                                           @"NBUGalleryViewController hide thumbnails button"));
}

- (void)scrollThumbnailsViewToIndex:(NSUInteger)index
                           animated:(BOOL)animated
{
    NSUInteger viewsPerRow = (NSUInteger)((_thumbnailsGridView.size.width - _thumbnailMargin.width) /
                                          (_thumbnailSize.width + _thumbnailMargin.width));
    NSUInteger row = index / viewsPerRow;
    CGRect rect = CGRectMake(0.0,
                             row * (_thumbnailSize.height + _thumbnailMargin.height),
                             _thumbnailsGridView.size.width,
                             _thumbnailSize.height + (2.0 * _thumbnailMargin.height));
    [_thumbnailsGridView scrollRectToVisible:rect
                                    animated:animated];
}

- (IBAction)thumbnailWasTapped:(UIView *)sender
{
	[self setCurrentIndex:sender.tag
                 animated:NO];
    [self setShowThumbnailsView:NO
                       animated:YES];
}

#pragma mark - Image Loading

- (void)setObjectArray:(NSArray *)objectArray
{
    NBULogInfo(@"%@ %@", THIS_METHOD, objectArray);
    
    _objectArray = objectArray;
    
    // Con we reload the gallery?
    if (self.isViewLoaded)
    {
        [self reloadGallery];
    }
}

- (void)updateLoadedImages
{
    NSRange oldRange = _currentPreloadedRange;
    
    // Calculate new range
    NSInteger startIndex = MAX(0,
                               _currentIndex - (NSInteger)_imagePreloadCount);
    NSInteger count = MIN(1 + (2 * (NSInteger)_imagePreloadCount),
                          (NSInteger)_objectArray.count - startIndex);
    _currentPreloadedRange = NSMakeRange(startIndex,
                                         MAX(0, count));
    
    NBULogVerbose(@"%@ %@ -> %@",
                  THIS_METHOD, NSStringFromRange(oldRange), NSStringFromRange(_currentPreloadedRange));
    
    // Remove from old range
    for (NSUInteger index = oldRange.location; NSLocationInRange(index, oldRange); index++)
    {
        if (NSLocationInRange(index, _currentPreloadedRange))
            continue;
        
        [self unloadFullsizeImageWithIndex:index];
    }
    
    // Preload images in new range
    for (NSUInteger index = startIndex; NSLocationInRange(index, _currentPreloadedRange); index++)
    {
        if (NSLocationInRange(index, oldRange))
            continue;
        
        [self preloadImageAtIndex:index];
    }
}

- (void)preloadImageAtIndex:(NSUInteger)index
{
    NBULogVerbose(@"%@ %d", THIS_METHOD, index);
    
    [_imageLoader imageForObject:_objectArray[index]
                            size:NBUImageSizeFullResolution
                     resultBlock:^(UIImage * image,
                                   NSError * error)
     {
         NBUGalleryView * view = _views[index];
         view.imageView.image = image;
         view.loading = NO;
     }];
}

- (void)unloadFullsizeImageWithIndex:(NSUInteger)index
{
    NBULogVerbose(@"%@ %d", THIS_METHOD, index);
    
    if ([_imageLoader respondsToSelector:@selector(unloadImageForObject:)])
    {
        [_imageLoader unloadImageForObject:_objectArray[index]];
    }
}

- (void)loadAllThumbnails
{
	for (NSUInteger i=0; i < _objectArray.count; i++)
    {
		[self loadThumbnailImageWithIndex:i];
	}
}

- (void)loadThumbnailImageWithIndex:(NSUInteger)index
{
    NBULogVerbose(@"%@ %d", THIS_METHOD, index);
    
    [_imageLoader imageForObject:_objectArray[index]
                            size:NBUImageSizeThumbnail
                     resultBlock:^(UIImage * image,
                                   NSError * error)
     {
         ((NBUGalleryThumbnailView *)_thumbnailViews[index]).imageView.image = image;
     }];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	_isScrolling = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
	if( !decelerate )
	{
		[self scrollingHasEnded];
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	[self scrollingHasEnded];
}

- (void)scrollingHasEnded
{
	_isScrolling = NO;
	
	NSUInteger index = floor(_scrollView.contentOffset.x / _scrollView.frame.size.width);
    
	if((NSInteger)index != _currentIndex)
    {
		self.currentIndex = index;;
    }
}

@end

