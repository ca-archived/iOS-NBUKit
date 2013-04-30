//
//  NBUDashboardLogger.h
//  NBUCore
//
//  Created by Ernesto Rivera on 2012/12/17.
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

#import "DDLog.h"

/**
 Logger to display log messages on device.
 
 - Compatible with NBULog and DDLog.
 - Supports colors for log levels.
 - Expands and collapses text.
 
 To enable simply use [NBULog addDashboardLogger].
 */
@interface NBUDashboardLogger : DDAbstractLogger

/// @name Getting the Logger

/// Get the shared logger instance.
+ (NBUDashboardLogger *)sharedInstance;

/// Set the maximum number of messages to be dispalyed in the Dashboard. Default value `100`.
@property (nonatomic)   NSUInteger maxMessages;

/// @name Outlets

/// The UITableView used to display log messages.
@property (assign, nonatomic) IBOutlet UITableView * tableView;

/// Maximize/minimize the log dashboard.
/// @param sender The sender object.
- (IBAction)toggle:(id)sender;

@end

/**
 The UIWindow containing the NBUDashboardLogger.
 */
@interface NBUDashboardWindow : UIWindow

@end

