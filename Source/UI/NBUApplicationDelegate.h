//
//  NBUApplicationDelegate.h
//  NBUKit
//
//  Created by 利辺羅 on 2012/09/28.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

/**
 Base Application Delegate class to handle common taks.
 
 - Register for remote notifications.
 */
@interface NBUApplicationDelegate : UIResponder <UIApplicationDelegate>

/// @name Properties

/// The current remote notifications token.
@property (nonatomic, readonly) NSString * notificationsToken;

/// @name Methods

/// Call from subclass to register for remote notifications.
- (void)registerForRemoteNotifications;

@end

