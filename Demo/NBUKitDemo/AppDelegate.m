//
//  AppDelegate.m
//  NBUKitDemo
//
//  Created by Ernesto Rivera on 2012/07/24.
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

#import "AppDelegate.h"

@implementation AppDelegate
{
    NBUSplashView * _splashView;
}

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Configure NBULog
#if defined (DEBUG) ||  defined (TESTING)
    [NBULog addDashboardLogger];
#endif

    NBULogTrace();
    
    // Customize iOS 7 apperance
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        UIColor * tintColor = [UIColor colorWithRed:76.0/255.0
                                              green:19.0/255.0
                                               blue:136.0/255.0
                                              alpha:1.0];
        self.window.tintColor = tintColor;
        [UIButton appearance].tintColor = tintColor;
        [[UIButton appearance] setTitleColor:tintColor
                                    forState:UIControlStateNormal];
        [UISwitch appearance].tintColor = tintColor;
        [UISwitch appearance].onTintColor = tintColor;
        
        // Configure appearance
        //    [[UINavigationBar appearance] setBarTintColor:];
        //    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    }
    
    // Start splash screen
    _splashView = [NSBundle loadNibNamed:@"NBUSplashView"
                                   owner:nil
                                 options:nil][0];
    [_splashView startWithStatus:@"Launching..."
                          window:_window];
    
    // Async launch mock tasks
    dispatch_async(dispatch_get_main_queue(), ^
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
                                                withStatus:[NSString stringWithFormat:@"Mock task %@ of 10", @(i)]];
                               
                               // Finish splash view
                               if (i == 10)
                               {
                                   [_splashView finishWithStatus:@"Done"
                                                        animated:YES];
                                   _splashView = nil;
                               }
                           });
        }
    });
    
    return YES;
}

@end

