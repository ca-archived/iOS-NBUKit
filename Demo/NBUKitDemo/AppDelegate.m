//
//  AppDelegate.m
//  NBUKitDemo
//
//  Created by Ernesto Rivera on 12/07/24.
//  Copyright (c) 2012 CyberAgent Inc.
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

#import "AppDelegate.h"

@implementation AppDelegate
{
    NBUSplashView * _splashView;
}

@synthesize window = _window;
@synthesize cameraButton = _cameraButton;

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Configure NBULog
#if defined (DEBUG) ||  defined (TESTING)
    // Add dashboard logger
    [NBULog addDashboardLogger];
#endif

    NBULogTrace();
    
    // Prepare window
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UITabBarController * rootController = [[NSBundle mainBundle] loadNibNamed:@"MainController"
                                                                        owner:self
                                                                      options:nil][0];
    rootController.customizableViewControllers = nil;
    _cameraButton.center = CGPointMake(CGRectGetMidX(rootController.tabBar.bounds),
                                       CGRectGetMidY(rootController.tabBar.bounds) - 10.0);
    [rootController.tabBar addSubview:_cameraButton];
    _window.rootViewController = rootController;
    [_window makeKeyAndVisible];
    
    // Start splash screen
    _splashView = [NSBundle loadNibNamed:@"NBUSplashView"
                                   owner:nil
                                 options:nil][0];
    [_splashView startWithStatus:@"Launching..."
                          window:_window];
    
    // Async launch tasks
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [self mockLaunchTasks];
    });
    
    return YES;
}

// *** Do some real work here ***
- (void)mockLaunchTasks
{
    // Mock 10 tasks
    for (NSUInteger i = 1; i <= 10; i++)
    {
        // Using GCD to mock updates
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, i * 0.10 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {
                           // Update splash view
                           [_splashView updateProgress:i * 0.1
                                            withStatus:[NSString stringWithFormat:@"Mock task %d of 10", i]];
                           
                           // Finish splash view
                           if (i == 10)
                           {
                               [_splashView finishWithStatus:@"Done"
                                                    animated:YES];
                               _splashView = nil;
                           }
                       });
    }
}

@end

