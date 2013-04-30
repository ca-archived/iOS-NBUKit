//
//  NBUGalleryView.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2013/04/17.
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

#import "NBUGalleryView.h"

// Private class
@interface NBUGalleryScrollView : UIScrollView <UIScrollViewDelegate>

@property(nonatomic, readonly) NBUGalleryView * superview;
@property (nonatomic, getter=isZoomed) BOOL zoomed;

@end


@implementation NBUGalleryView
{
    NBUGalleryScrollView * _scrollView;
}

@dynamic viewController;
@synthesize imageView = _imageView;
@synthesize activityView = _activityView;
@synthesize loading = _loading;

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Create scrollView
    _scrollView = [[NBUGalleryScrollView alloc] initWithFrame:self.bounds];
    [self insertSubview:_scrollView
           belowSubview:_imageView];
    
    // Configure imageView
    _imageView.frame = _scrollView.bounds;
    [_scrollView addSubview:_imageView];
    
    self.loading = YES;
}

- (void)setLoading:(BOOL)loading
{
    _scrollView.maximumZoomScale = loading ? 1.0 : 3.0;
    _activityView.hidden = !loading;
}

- (void)setFrame:(CGRect)frame
{
	// store position of the image view if we're scaled or panned so we can stay at that point
	CGPoint imagePoint = _imageView.frame.origin;
	
	super.frame = frame;
	
	[self updateContentSize];
	
	// resize image view and keep it proportional to the current zoom scale
	_imageView.frame = CGRectMake(imagePoint.x,
                                  imagePoint.y,
                                  frame.size.width * _scrollView.zoomScale,
                                  frame.size.height * _scrollView.zoomScale);
}

- (void)resetZoom
{
    _scrollView.zoomed = NO;
}

- (void)updateContentSize
{
    _scrollView.contentSize = CGSizeMake(_scrollView.size.width * _scrollView.zoomScale,
                                         _scrollView.size.height * _scrollView.zoomScale);
}

@end


@implementation NBUGalleryScrollView
{
    NSTimer * _tapTimer;
}

@dynamic superview;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Configure the scrollView
        self.clipsToBounds = YES;
        self.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                 UIViewAutoresizingFlexibleHeight);
        self.autoresizesSubviews = YES;
        self.contentMode = UIViewContentModeCenter;
//        self.maximumZoomScale = 3.0;
        self.minimumZoomScale = 1.0;
        self.decelerationRate = 0.85;
//        self.contentSize = CGSizeMake(self.size.width,
//                                      self.size.height);
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.userInteractionEnabled = YES;
        self.delegate = self;
    }
    return self;
}

#pragma mark - ScrollView delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return self.superview.imageView;
}

#pragma mark - Handle taps

- (BOOL)isZoomed
{
    return self.zoomScale != self.minimumZoomScale;
}

- (void)setZoomed:(BOOL)zoomed
{
    [self setZoomed:zoomed
           animated:NO];
}

- (void)setZoomed:(BOOL)zoomed
         animated:(BOOL)animated
{
    [self stopTapTimer];
    
    [self setZoomScale:zoomed ? self.maximumZoomScale : self.minimumZoomScale
              animated:animated];
}

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
	UITouch * touch = event.allTouches.anyObject;
	
	if (touch.tapCount == 2)
    {
		[self stopTapTimer];
		
        // Already zoomed?
		if(self.zoomed)
		{
			[self setZoomed:NO
                   animated:YES];
		}
        
        // Zoom
		else
        {
			// define a rect to zoom to.
			CGPoint touchCenter = [touch locationInView:self];
			CGSize zoomRectSize = CGSizeMake(self.size.width / self.maximumZoomScale,
                                             self.size.height / self.maximumZoomScale );
			CGRect zoomRect = CGRectMake(touchCenter.x - zoomRectSize.width * 0.5,
                                         touchCenter.y - zoomRectSize.height * 0.5,
                                         zoomRectSize.width,
                                         zoomRectSize.height);
			
			// correct too far left
			if(zoomRect.origin.x < 0.0)
				zoomRect = CGRectMake(0.0,
                                      zoomRect.origin.y,
                                      zoomRect.size.width,
                                      zoomRect.size.height);
			
			// correct too far up
			if(zoomRect.origin.y < 0.0)
				zoomRect = CGRectMake(zoomRect.origin.x,
                                      0.0,
                                      zoomRect.size.width,
                                      zoomRect.size.height);
			
			// correct too far right
			if(zoomRect.origin.x + zoomRect.size.width > self.frame.size.width)
				zoomRect = CGRectMake(self.frame.size.width - zoomRect.size.width,
                                      zoomRect.origin.y,
                                      zoomRect.size.width,
                                      zoomRect.size.height);
			
			// correct too far down
			if(zoomRect.origin.y + zoomRect.size.height > self.frame.size.height)
				zoomRect = CGRectMake(zoomRect.origin.x,
                                      self.frame.size.height - zoomRect.size.height,
                                      zoomRect.size.width,
                                      zoomRect.size.height);
			
			// zoom to it.
			[self zoomToRect:zoomRect
                    animated:YES];
		}
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(event.allTouches.count == 1)
    {
		UITouch * touch = event.allTouches.anyObject;
        
		if(touch.tapCount == 1)
        {
			if(_tapTimer)
                [self stopTapTimer];
            
			[self startTapTimer];
		}
	}
}

- (void)handleTap
{
    [self.superview.viewController toggleFullscreen:self];
}

- (void)startTapTimer
{
	_tapTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:.5]
                                         interval:.5
                                           target:self
                                         selector:@selector(handleTap)
                                         userInfo:nil
                                          repeats:NO];
	[[NSRunLoop currentRunLoop] addTimer:_tapTimer forMode:NSDefaultRunLoopMode];
	
}

- (void)stopTapTimer
{
	if([_tapTimer isValid])
		[_tapTimer invalidate];
	
	_tapTimer = nil;
}

- (void)dealloc
{
	[self stopTapTimer];
}

@end

