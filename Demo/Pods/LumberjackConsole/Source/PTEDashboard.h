//
//  PTEDashboard.h
//  LumberjackConsole
//
//  Created by Ernesto Rivera on 2012/12/17.
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

@class PTEConsoleLogger;

/**
 On-device Dashboard to display a PTEConsoleLogger.
 
 @discussion Just call [PTEDashboard.sharedDashboard show] or [NBULog addDashboardLogger].
 */
@interface PTEDashboard : UIWindow

/// Showing the Dashboard

/// The shared dashboard.
+ (PTEDashboard *)sharedDashboard;

/// Add the dashboard to the screen.
- (void)show;

/// @name Properties

/// Whether the dashboard is maximized.
@property (nonatomic, getter=isMaximized)   BOOL maximized;

/// Whether the dashboard is minimized.
@property (nonatomic, getter=isMinimized)   BOOL minimized;

/// @name First Responder Actions

/// Maximize/minimize the log dashboard.
/// @param sender The sender object.
- (IBAction)toggleFullscreen:(UIButton *)sender;

/// Toggle between the loggerView and the adjustLevelsView.
/// @param sender The sender object.
- (IBAction)toggleAdjustLevelsController:(id)sender;

@end

