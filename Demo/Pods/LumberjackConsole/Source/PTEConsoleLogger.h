//
//  PTEConsoleLogger.h
//  LumberjackConsole
//
//  Created by Ernesto Rivera on 2013/05/23.
//  Copyright (c) 2013-2014 PTEz.
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

#import <CocoaLumberjack/DDLog.h>

@class PTEConsoleTableView;

/**
 A DDLogger that displays log messages with a searcheable UITableView.
 
 - Supports colors for log levels.
 - Expands and collapses text.
 - Can be filtered according to log levels or text.
 - Can be minimized, maximized or used in any size in between.
 
 Simply add a PTEConsoleTableView to your view hierarchy or use
 [PTEDashboard.sharedDashboard show].
 */
@interface PTEConsoleLogger : DDAbstractLogger <DDLogFormatter,
                                                UITableViewDelegate,
                                                UITableViewDataSource,
                                                UISearchBarDelegate>

/// @name Properties

/// Set the maximum number of messages to be displayed on the Dashboard. Default `100`.
@property (nonatomic)                   NSUInteger maxMessages;

/// The UITableView used to display log messages.
@property (weak, nonatomic)             PTEConsoleTableView * tableView;

/// @name Log Formatters

/// An optional formatter to be used for shortened log messages.
@property (atomic, strong)              id<DDLogFormatter> shortLogFormatter;

/// @name Methods

/// Clear all console messages.
- (void)clearConsole;

/// Add a marker object to the console.
- (void)addMarker;

@end

