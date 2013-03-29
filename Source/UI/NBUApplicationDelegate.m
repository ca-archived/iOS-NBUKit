//
//  NBUApplicationDelegate.m
//  NBUKit
//
//  Created by 利辺羅 on 2012/09/28.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import "NBUApplicationDelegate.h"

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

