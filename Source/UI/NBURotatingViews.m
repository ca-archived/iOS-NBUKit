//
//  NBURotatingViews.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2013/02/28.
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

#import "NBURotatingViews.h"
#import "NBUKitPrivate.h"
#import <MotionOrientation@PTEz/MotionOrientation.h>

#define kAnimationDuration 0.3

@implementation NBURotatingView

@synthesize animated = _animated;
@synthesize supportedInterfaceOrientations = _supportedInterfaceOrientations;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _animated = YES;
    _supportedInterfaceOrientations = (UIInterfaceOrientationMaskPortrait |
                                       UIInterfaceOrientationMaskLandscapeRight |
                                       UIInterfaceOrientationMaskLandscapeLeft |
                                       UIInterfaceOrientationMaskPortraitUpsideDown);
    
    // First rotation
    [MotionOrientation initialize];
    [self setDeviceOrientation:[MotionOrientation sharedInstance].deviceOrientation
                      animated:NO];
    
    // Observe orientation changes
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationChanged:)
                                                 name:MotionOrientationChangedNotification
                                               object:nil];
}

- (void)dealloc
{
    // Stop observing
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)deviceOrientationChanged:(NSNotification *)notification
{
    [self setDeviceOrientation:[MotionOrientation sharedInstance].deviceOrientation
                      animated:YES];
}

- (void)setDeviceOrientation:(UIDeviceOrientation)orientation
                    animated:(BOOL)animated
{
    if (UIDeviceOrientationIsValidInterfaceOrientation(orientation))
    {
        [self setInterfaceOrientation:UIInterfaceOrientationFromValidDeviceOrientation(orientation)
                             animated:_animated];
    }
}

- (void)setInterfaceOrientation:(UIInterfaceOrientation)orientation
                       animated:(BOOL)animated
{
    // Skip if not supported
    if (!UIInterfaceOrientationIsSupportedByInterfaceOrientationMask(orientation, _supportedInterfaceOrientations))
        return;
    
    [UIView animateWithDuration:animated ? kAnimationDuration : 0.0
                     animations:^
     {
         switch (orientation)
         {
             case UIInterfaceOrientationPortrait:
                 self.transform = CGAffineTransformIdentity;
                 break;
             case UIInterfaceOrientationLandscapeLeft:
                 self.transform = CGAffineTransformMakeRotation(- M_PI / 2.0);
                 break;
             case UIInterfaceOrientationLandscapeRight:
                 self.transform = CGAffineTransformMakeRotation(M_PI / 2.0);
                 break;
             case UIInterfaceOrientationPortraitUpsideDown:
                 self.transform = CGAffineTransformMakeRotation(M_PI);
                 break;
             default:
                 break;
         }
     }];
}

@end


@implementation NBURotatingImageView

@synthesize animated = _animated;
@synthesize supportedInterfaceOrientations = _supportedInterfaceOrientations;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _animated = YES;
    _supportedInterfaceOrientations = (UIInterfaceOrientationMaskPortrait |
                                       UIInterfaceOrientationMaskLandscapeRight |
                                       UIInterfaceOrientationMaskLandscapeLeft |
                                       UIInterfaceOrientationMaskPortraitUpsideDown);
    
    // First rotation
    [MotionOrientation initialize];
    [self setDeviceOrientation:[MotionOrientation sharedInstance].deviceOrientation
                      animated:NO];
    
    // Observe orientation changes
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationChanged:)
                                                 name:MotionOrientationChangedNotification
                                               object:nil];
}

- (void)dealloc
{
    // Stop observing
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)deviceOrientationChanged:(NSNotification *)notification
{
    [self setDeviceOrientation:[MotionOrientation sharedInstance].deviceOrientation
                      animated:YES];
}

- (void)setDeviceOrientation:(UIDeviceOrientation)orientation
                    animated:(BOOL)animated
{
    if (UIDeviceOrientationIsValidInterfaceOrientation(orientation))
    {
        [self setInterfaceOrientation:UIInterfaceOrientationFromValidDeviceOrientation(orientation)
                             animated:_animated];
    }
}

- (void)setInterfaceOrientation:(UIInterfaceOrientation)orientation
                       animated:(BOOL)animated
{
    // Skip if not supported
    if (!UIInterfaceOrientationIsSupportedByInterfaceOrientationMask(orientation, _supportedInterfaceOrientations))
        return;
    
    [UIView animateWithDuration:animated ? kAnimationDuration : 0.0
                     animations:^
     {
         switch (orientation)
         {
             case UIInterfaceOrientationPortrait:
                 self.transform = CGAffineTransformIdentity;
                 break;
             case UIInterfaceOrientationLandscapeLeft:
                 self.transform = CGAffineTransformMakeRotation(- M_PI / 2.0);
                 break;
             case UIInterfaceOrientationLandscapeRight:
                 self.transform = CGAffineTransformMakeRotation(M_PI / 2.0);
                 break;
             case UIInterfaceOrientationPortraitUpsideDown:
                 self.transform = CGAffineTransformMakeRotation(M_PI);
                 break;
             default:
                 break;
         }
     }];
}

@end


@implementation NBURotatingButton

@synthesize animated = _animated;
@synthesize supportedInterfaceOrientations = _supportedInterfaceOrientations;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _animated = YES;
    _supportedInterfaceOrientations = (UIInterfaceOrientationMaskPortrait |
                                       UIInterfaceOrientationMaskLandscapeRight |
                                       UIInterfaceOrientationMaskLandscapeLeft |
                                       UIInterfaceOrientationMaskPortraitUpsideDown);
    
    // First rotation
    [MotionOrientation initialize];
    [self setDeviceOrientation:[MotionOrientation sharedInstance].deviceOrientation
                      animated:NO];
    
    // Observe orientation changes
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationChanged:)
                                                 name:MotionOrientationChangedNotification
                                               object:nil];
}

- (void)dealloc
{
    // Stop observing
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)deviceOrientationChanged:(NSNotification *)notification
{
    [self setDeviceOrientation:[MotionOrientation sharedInstance].deviceOrientation
                      animated:YES];
}

- (void)setDeviceOrientation:(UIDeviceOrientation)orientation
                    animated:(BOOL)animated
{
    if (UIDeviceOrientationIsValidInterfaceOrientation(orientation))
    {
        [self setInterfaceOrientation:UIInterfaceOrientationFromValidDeviceOrientation(orientation)
                             animated:_animated];
    }
}

- (void)setInterfaceOrientation:(UIInterfaceOrientation)orientation
                       animated:(BOOL)animated
{
    // Skip if not supported
    if (!UIInterfaceOrientationIsSupportedByInterfaceOrientationMask(orientation, _supportedInterfaceOrientations))
        return;
    
    [UIView animateWithDuration:animated ? kAnimationDuration : 0.0
                     animations:^
     {
         switch (orientation)
         {
             case UIInterfaceOrientationPortrait:
                 self.transform = CGAffineTransformIdentity;
                 break;
             case UIInterfaceOrientationLandscapeLeft:
                 self.transform = CGAffineTransformMakeRotation(- M_PI / 2.0);
                 break;
             case UIInterfaceOrientationLandscapeRight:
                 self.transform = CGAffineTransformMakeRotation(M_PI / 2.0);
                 break;
             case UIInterfaceOrientationPortraitUpsideDown:
                 self.transform = CGAffineTransformMakeRotation(M_PI);
                 break;
             default:
                 break;
         }
     }];
}

@end

