//
//  NBUApplicationDelegate.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/09/28.
//  Copyright (c) 2012-2013 CyberAgent Inc.
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

#import "NBUApplicationDelegate.h"
#import "NBUKitPrivate.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_UI

@implementation NBUApplicationDelegate

@synthesize notificationsToken = _notificationsToken;

#pragma mark - Remote notifications

- (void)registerForRemoteNotifications
{
    // Register for all remote notifications
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                                           UIRemoteNotificationTypeSound |
                                                                           UIRemoteNotificationTypeAlert)];
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)notificationsToken
{
    _notificationsToken = [[notificationsToken.description
                            stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]
                           stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NBULogInfo(@"didRegisterForRemoteNotificationsWithDeviceToken: %@", _notificationsToken);
}

- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NBULogWarn(@"FailedToRegisterForRemoteNotificationsWithError: %@", error);
    
#ifdef DEBUG
    // Show alert only if not attached to a console
    if (!AmIBeingDebugged())
    {
        [[[UIAlertView alloc] initWithTitle:@"didFailToRegisterForRemoteNotificationsWithError"
                                    message:error.description
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
#endif
}

@end

