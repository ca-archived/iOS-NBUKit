//
//  PTEDashboard.h
//  LumberjackConsole
//
//  Created by Ernesto Rivera on 2012/12/17.
//  Copyright (c) 2013.
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

#import "PTEConsoleLogger.h"

/**
 On-device Dashboard to display a PTEConsoleLogger.
 
 @note You don't need to use this class directly but instead use
 [DDLog addLogger:[PTEDashboard sharedDashboard].logger] or [NBULog addDashboardLogger].
 */
@interface PTEDashboard : UIWindow

/// The shared dashboard.
+ (PTEDashboard *)sharedDashboard;

/// Add the dashboard to the screen.
/// @discussion Called automatically by NBULog.
- (void)show;

/// @name Outlets

/// The logger.
@property (strong, nonatomic) IBOutlet      PTEConsoleLogger * logger;

/// A button to toggle: the dashboard size.
@property (weak, nonatomic) IBOutlet        UIButton * toggleButton;

/// Views that should be hidden when not in fullscreen mode.
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray * fullscreenOnlyViews;

/// The view that has the console.
@property (strong, nonatomic) IBOutlet      UIView * loggerView;

/// The view that has the adjust levels' controls.
@property (strong, nonatomic) IBOutlet      UIView * adjustLevelsView;

/// Maximize/minimize the log dashboard.
/// @param sender The sender object.
- (IBAction)toggleFullscreen:(id)sender;

/// Toggle between the loggerView and the adjustLevelsView.
/// @param sender The sender object.
- (IBAction)toggleAdjustLevelsView:(id)sender;

/// @name Properties

/// Whether the dashboard is maximized.
@property (nonatomic, getter=isMaximized)   BOOL maximized;

/// Whether the dashboard is minimized.
@property (nonatomic, getter=isMinimized)   BOOL minimized;

@end

