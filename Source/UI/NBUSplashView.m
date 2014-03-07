//
//  NBUSplashView.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/08/07.
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

#import "NBUSplashView.h"
#import "NBUKitPrivate.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_UI

@implementation NBUSplashView

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
    self.frame = [UIScreen mainScreen].bounds;
    [window.rootViewController.view addSubview:self];
}

- (void)finishWithStatus:(NSString *)status
                animated:(BOOL)animated
{
    _statusLabel.text = status;
    
    // Finish progress
    _activityIndicatorView.hidden = YES;
    
    [_progressView setProgress:1.0
                      animated:animated];
    
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
    
    [_progressView setProgress:progress
                      animated:YES];
}

@end

