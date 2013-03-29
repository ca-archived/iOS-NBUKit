//
//  NBUSplashView.m
//  NBUKit
//
//  Created by 利辺羅 on 2012/08/07.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import "NBUSplashView.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_UI

@implementation NBUSplashView

@synthesize imageView = _imageView;
@synthesize activityIndicatorView = _activityIndicatorView;
@synthesize progressView = _progressView;
@synthesize statusLabel = _statusLabel;
@synthesize versionLabel = _versionLabel;

#pragma mark - Methods

- (void)startWithStatus:(NSString *)status
                 window:(UIWindow *)window
{
    _statusLabel.text = status;
    
    // Prepare outlets
    if (!_imageView.image)
    {
        _imageView.image = DEVICE_IS_WIDESCREEN ? [UIImage imageNamed:@"Default-568h"] : [UIImage imageNamed:@"Default"];
    }
    [_activityIndicatorView startAnimating];
    _progressView.progress = 0.0;
    _versionLabel.text = [NSString stringWithFormat:@"%@ v%@ (%@)",
                          [UIApplication sharedApplication].applicationName,
                          [UIApplication sharedApplication].applicationVersion,
                          [UIApplication sharedApplication].applicationBuild];
    
    // Resolve the window to be used
    if (!window)
    {
        window = [UIApplication sharedApplication].keyWindow;
    }
    if (!window)
    {
        NBULogError(@"A keyWindow couldn't be found to present the splash view.");
    }
    
    // Add on top of the window
    self.frame = [[UIScreen mainScreen] bounds];
    [window addSubview:self];
}

- (void)finishWithStatus:(NSString *)status
                animated:(BOOL)animated
{
    _statusLabel.text = status;
    
    // Finish progress
    _activityIndicatorView.hidden = YES;
    
    // iOS 5+
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
    {
        [_progressView setProgress:1.0
                          animated:animated];
    }
    // iOS 4.x
    else
    {
        _progressView.progress = 1.0;
    }
    
    // Disappear and remove from keyWindow
    [UIView animateWithDuration:animated ? 0.3 : 0.0
                          delay:animated ? 0.7 : 0.0
                        options:0
                     animations:^{
                         
                         self.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         
                         [self removeFromSuperview];
                     }];
}

- (void)updateProgress:(float)progress
            withStatus:(NSString *)status
{
    _statusLabel.text = status;
    
    // iOS 5+
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
    {
        [_progressView setProgress:progress
                          animated:YES];
    }
    // iOS 4.x
    else
    {
        _progressView.progress = progress;
    }
}

@end

