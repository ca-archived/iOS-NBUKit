//
//  NBURotatingViews.m
//  NBUKit
//
//  Created by 利辺羅 on 2013/02/28.
//  Copyright (c) 2013年 CyberAgent Inc. All rights reserved.
//

#import "NBURotatingViews.h"

#define kAnimationDuration 0.3

@implementation NBURotatingView

@synthesize supportedInterfaceOrientations = _supportedInterfaceOrientations;
@synthesize animated = _animated;

- (void)commonInit
{
    _animated = YES;
    _supportedInterfaceOrientations = (UIInterfaceOrientationMaskPortrait |
                                       UIInterfaceOrientationMaskLandscapeRight |
                                       UIInterfaceOrientationMaskLandscapeLeft |
                                       UIInterfaceOrientationMaskPortraitUpsideDown);
    
    // First rotation
    [self rotateToOrientation:[UIDevice currentDevice].orientation
                     animated:NO
                        force:NO];
    
    // Observe orientation changes
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (void)dealloc
{
    // Stop observing
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
}

- (void)deviceOrientationChanged:(NSNotification *)notification
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;;
    
    [self rotateToOrientation:orientation
                     animated:_animated
                        force:NO];
}

- (void)rotateToOrientation:(UIDeviceOrientation)orientation
                   animated:(BOOL)animated
                      force:(BOOL)force
{
    /*
     UIInterfaceOrientationMaskPortrait = (1 << UIInterfaceOrientationPortrait),
     UIInterfaceOrientationMaskLandscapeLeft = (1 << UIInterfaceOrientationLandscapeLeft),
     UIInterfaceOrientationMaskLandscapeRight = (1 << UIInterfaceOrientationLandscapeRight),
     UIInterfaceOrientationMaskPortraitUpsideDown = (1 << UIInterfaceOrientationPortraitUpsideDown)
     */
    
    // Skip if not supported
    if (!force &&
        !(_supportedInterfaceOrientations & (1 << orientation)))
    {
        return;
    }
    
    [UIView animateWithDuration:animated ? kAnimationDuration : 0.0
                     animations:^
     {
         switch (orientation)
         {
             case UIDeviceOrientationPortrait:
                 self.transform = CGAffineTransformIdentity;
                 break;
             case UIDeviceOrientationLandscapeRight:
                 self.transform = CGAffineTransformMakeRotation(- M_PI / 2.0);
                 break;
             case UIDeviceOrientationLandscapeLeft:
                 self.transform = CGAffineTransformMakeRotation(M_PI / 2.0);
                 break;
             case UIDeviceOrientationPortraitUpsideDown:
                 self.transform = CGAffineTransformMakeRotation(M_PI);
                 break;
             default:
                 break;
         }
     }];
}

- (void)rotateToOrientation:(UIDeviceOrientation)orientation
                   animated:(BOOL)animated
{
    [self rotateToOrientation:orientation
                     animated:animated
                        force:NO];
}

@end


@implementation NBURotatingImageView

@synthesize supportedInterfaceOrientations = _supportedInterfaceOrientations;
@synthesize animated = _animated;

- (void)commonInit
{
    _animated = YES;
    _supportedInterfaceOrientations = (UIInterfaceOrientationMaskPortrait |
                                       UIInterfaceOrientationMaskLandscapeRight |
                                       UIInterfaceOrientationMaskLandscapeLeft |
                                       UIInterfaceOrientationMaskPortraitUpsideDown);
    
    // First rotation
    [self rotateToOrientation:[UIDevice currentDevice].orientation
                     animated:NO
                        force:NO];
    
    // Observe library changes
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (void)dealloc
{
    // Stop observing
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
}

- (void)deviceOrientationChanged:(NSNotification *)notification
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;;
    
    [self rotateToOrientation:orientation
                     animated:_animated
                        force:NO];
}

- (void)rotateToOrientation:(UIDeviceOrientation)orientation
                   animated:(BOOL)animated
                      force:(BOOL)force
{
    /*
     UIInterfaceOrientationMaskPortrait = (1 << UIInterfaceOrientationPortrait),
     UIInterfaceOrientationMaskLandscapeLeft = (1 << UIInterfaceOrientationLandscapeLeft),
     UIInterfaceOrientationMaskLandscapeRight = (1 << UIInterfaceOrientationLandscapeRight),
     UIInterfaceOrientationMaskPortraitUpsideDown = (1 << UIInterfaceOrientationPortraitUpsideDown)
     */
    
    // Skip if not supported
    if (!force &&
        !(_supportedInterfaceOrientations & (1 << orientation)))
    {
        return;
    }
    
    [UIView animateWithDuration:animated ? kAnimationDuration : 0.0
                     animations:^
     {
         switch (orientation)
         {
             case UIDeviceOrientationPortrait:
                 self.transform = CGAffineTransformIdentity;
                 break;
             case UIDeviceOrientationLandscapeRight:
                 self.transform = CGAffineTransformMakeRotation(- M_PI / 2.0);
                 break;
             case UIDeviceOrientationLandscapeLeft:
                 self.transform = CGAffineTransformMakeRotation(M_PI / 2.0);
                 break;
             case UIDeviceOrientationPortraitUpsideDown:
                 self.transform = CGAffineTransformMakeRotation(M_PI);
                 break;
             default:
                 break;
         }
     }];
}

- (void)rotateToOrientation:(UIDeviceOrientation)orientation
                   animated:(BOOL)animated
{
    [self rotateToOrientation:orientation
                     animated:animated
                        force:NO];
}

@end


@implementation NBURotatingButton

@synthesize supportedInterfaceOrientations = _supportedInterfaceOrientations;
@synthesize animated = _animated;

- (void)commonInit
{
    _animated = YES;
    _supportedInterfaceOrientations = (UIInterfaceOrientationMaskPortrait |
                                       UIInterfaceOrientationMaskLandscapeRight |
                                       UIInterfaceOrientationMaskLandscapeLeft |
                                       UIInterfaceOrientationMaskPortraitUpsideDown);
    
    // First rotation
    [self rotateToOrientation:[UIDevice currentDevice].orientation
                     animated:NO
                        force:NO];
    
    // Observe library changes
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (void)dealloc
{
    // Stop observing
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
}

- (void)deviceOrientationChanged:(NSNotification *)notification
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;;
    
    [self rotateToOrientation:orientation
                          animated:_animated
                             force:NO];
}

- (void)rotateToOrientation:(UIDeviceOrientation)orientation
                   animated:(BOOL)animated
                      force:(BOOL)force
{
    /*
     UIInterfaceOrientationMaskPortrait = (1 << UIInterfaceOrientationPortrait),
     UIInterfaceOrientationMaskLandscapeLeft = (1 << UIInterfaceOrientationLandscapeLeft),
     UIInterfaceOrientationMaskLandscapeRight = (1 << UIInterfaceOrientationLandscapeRight),
     UIInterfaceOrientationMaskPortraitUpsideDown = (1 << UIInterfaceOrientationPortraitUpsideDown)
     */
    
    // Skip if not supported
    if (!force &&
        !(_supportedInterfaceOrientations & (1 << orientation)))
    {
        return;
    }
    
    [UIView animateWithDuration:animated ? kAnimationDuration : 0.0
                     animations:^
     {
         switch (orientation)
         {
             case UIDeviceOrientationPortrait:
                 self.transform = CGAffineTransformIdentity;
                 break;
             case UIDeviceOrientationLandscapeRight:
                 self.transform = CGAffineTransformMakeRotation(- M_PI / 2.0);
                 break;
             case UIDeviceOrientationLandscapeLeft:
                 self.transform = CGAffineTransformMakeRotation(M_PI / 2.0);
                 break;
             case UIDeviceOrientationPortraitUpsideDown:
                 self.transform = CGAffineTransformMakeRotation(M_PI);
                 break;
             default:
                 break;
         }
     }];
}

- (void)rotateToOrientation:(UIDeviceOrientation)orientation
                   animated:(BOOL)animated
{
    [self rotateToOrientation:orientation
                     animated:animated
                        force:NO];
}

@end

