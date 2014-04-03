//
//  PTEDashboard.m
//  LumberjackConsole
//
//  Created by Ernesto Rivera on 2012/12/17.
//  Copyright (c) 2013-2014 PTEz.
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

#import "PTEDashboard.h"
#import "PTEConsoleLogger.h"
#import <QuartzCore/QuartzCore.h>
#import <NBUCore/NBUCore.h>

#define kMinimumHeight 20.0

static PTEDashboard * _sharedDashboard;

@implementation PTEDashboard
{
    CGSize _screenSize;
    UIWindow * _keyWindow;
}

+ (PTEDashboard *)sharedDashboard
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      CGRect frame = [UIScreen mainScreen].bounds;
                      _sharedDashboard = [[PTEDashboard alloc] initWithFrame:frame];
                  });
    return _sharedDashboard;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.windowLevel = UIWindowLevelStatusBar + 1;
        _screenSize = [UIScreen mainScreen].bounds.size;
        
        #if XCODE_VERSION_MAJOR >= 0500
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
            {
                self.tintColor = [UIColor lightGrayColor];
            }
        #endif
        
        // Load other views and objects
        [[NSBundle mainBundle] loadNibNamed:@"PTEDashboard"
                                      owner:self
                                    options:nil];
        
        // Disable adjust levels if NBULog is not present
        #ifndef COCOAPODS_POD_AVAILABLE_NBULog
            UILabel * notice = [UILabel new];
            notice.text = @"NBULog required";
            notice.backgroundColor = [UIColor clearColor];
            notice.textColor = [UIColor whiteColor];
            [notice sizeToFit];
            [_adjustLevelsView addSubview:notice];
        #endif
        
        // Add a pan gesture recognizer for the toggle button
        UIPanGestureRecognizer * panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                         action:@selector(handlePanGesture:)];
        [_toggleButton addGestureRecognizer:panRecognizer];
        
        // Configure the window properties
        //    self.layer.anchorPoint = CGPointZero;
        //    self.windowLevel = UIWindowLevelStatusBar + 1;
        //    self.origin = CGPointZero;
        //    self.frame = [UIScreen mainScreen].bounds;
        
        // Listen to orientation changes
        //    [[NSNotificationCenter defaultCenter] addObserver:self
        //                                             selector:@selector(handleStatusBarOrientationChange:)
        //                                                 name:UIApplicationWillChangeStatusBarOrientationNotification
        //                                               object:nil];
        
        [self show];
    }
    return self;
}

- (void)dealloc
{
    // Stop observing
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleStatusBarOrientationChange:(NSNotification *)notification
{
    UIApplication * app = [UIApplication sharedApplication];
    UIInterfaceOrientation currentOrientation = app.statusBarOrientation;
    UIInterfaceOrientation nextOrientation = [notification.userInfo[UIApplicationStatusBarOrientationUserInfoKey] integerValue];
    
    // Flip the window's height and width?
    CGRect frame = self.frame;
    if ((UIDeviceOrientationIsLandscape(currentOrientation) && UIDeviceOrientationIsPortrait(nextOrientation)) ||
        (UIDeviceOrientationIsPortrait(currentOrientation) && UIDeviceOrientationIsLandscape(nextOrientation)))
    {
        frame.size = CGSizeMake(frame.size.height,
                                frame.size.width);
    }
    
    // Calculate the transform and origin
    CGAffineTransform transform;
    switch (nextOrientation)
    {
        case UIInterfaceOrientationPortrait:
            frame.origin = CGPointZero;
            transform = CGAffineTransformIdentity;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            frame.origin = CGPointMake(0.0, _screenSize.height);
            transform = CGAffineTransformMakeRotation(- M_PI / 2.0);
            break;
        case UIInterfaceOrientationLandscapeRight:
            frame.origin = CGPointMake(_screenSize.width, 0.0);
            transform = CGAffineTransformMakeRotation(M_PI / 2.0);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            frame.origin = CGPointMake(_screenSize.width, _screenSize.height);
            transform = CGAffineTransformMakeRotation(M_PI);
            break;
        default:
            break;
    }
    
    //    NSLog(@"+++ %@ %@ -> %@ %@", NSStringFromCGRect(self.frame), NSStringFromCGAffineTransform(self.transform),
    //          NSStringFromCGRect(frame), NSStringFromCGAffineTransform(transform));
    
    // Animate
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    [UIView animateWithDuration:duration
                     animations:^
     {
         self.transform = transform;
         self.frame = frame;
     }];
}

- (void)show
{
    self.hidden = NO;
    self.minimized = YES;
}

- (IBAction)toggleFullscreen:(id)sender
{
    _toggleButton.selected = !_toggleButton.selected;
    
    [UIView animateWithDuration:0.2
                     animations:^
     {
         if (_toggleButton.selected)
         {
             self.maximized = YES;
         }
         else
         {
             self.minimized = YES;
         }
     }];
}

- (IBAction)toggleAdjustLevelsView:(id)sender
{
    // Show adjust levels view?
    if (self.rootViewController.view == _loggerView)
    {
        self.rootViewController.view = _adjustLevelsView;
    }
    
    // Set back the logger view
    else
    {
        self.rootViewController.view = _loggerView;
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    [self setWindowHeight:[gestureRecognizer locationInView:self].y];
}

- (BOOL)isMaximized
{
    return self.bounds.size.height == _screenSize.height;
}

- (void)setMaximized:(BOOL)maximized
{
    [self setWindowHeight:_screenSize.height];
}

- (BOOL)isMinimized
{
    return self.bounds.size.height == kMinimumHeight;
}

- (void)setMinimized:(BOOL)minimized
{
    [self setWindowHeight:kMinimumHeight];
}

- (void)setWindowHeight:(CGFloat)height
{
    // Validate height
    height = MAX(kMinimumHeight, height);
    if (_screenSize.height - height < kMinimumHeight * 2.0)
    {
        // Snap to bottom
        height = _screenSize.height;
    }
    
    // Adjust layout
    if (height != kMinimumHeight)
    {
        // Not minimized
        _logger.tableView.userInteractionEnabled = YES;
        _logger.tableView.frame = _logger.tableView.superview.bounds;
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                _screenSize.width,
                                height);
    }
    else
    {
        // Minimized
        _logger.tableView.userInteractionEnabled = NO;
        CGRect tableFrame = _logger.tableView.superview.bounds;
        tableFrame.origin.x += 20.0;
        tableFrame.size.width -= 20.0;
        _logger.tableView.frame = tableFrame;
        _logger.tableView.contentOffset = CGPointMake(0.0,
                                                      MAX(_logger.tableView.contentOffset.y,
                                                          _logger.tableView.tableHeaderView.bounds.size.height));
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                _screenSize.width - 40.0,
                                height);
    }
    
    // Change keyWindow to enable keyboard input
    if (height == _screenSize.height)
    {
        // Maximized
        if (!_keyWindow)
        {
            _keyWindow = [UIApplication sharedApplication].keyWindow;
            [_keyWindow resignKeyWindow];
            [self makeKeyWindow];
            //            NSLog(@"+++ %@ -> %@", _keyWindow, [UIApplication sharedApplication].keyWindow);
        }
        
        // Show fullscreen-only views
        for (UIView * view in _fullscreenOnlyViews)
        {
            view.hidden = NO;
        }
    }
    else
    {
        // Not maximized
        if (_keyWindow)
        {
            [_keyWindow makeKeyWindow];
            _keyWindow = nil;
            //            NSLog(@"+++ %@ <-", [UIApplication sharedApplication].keyWindow);
        }
        
        // Hide fullscreen-only views
        for (UIView * view in _fullscreenOnlyViews)
        {
            view.hidden = YES;
        }
    }
}

@end

