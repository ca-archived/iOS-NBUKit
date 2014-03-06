//
//  NBUSplashView.h
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

/**
 A view to be used during launch to show the boot progress.
 
 Normally you start the NBUSplashView on UIApplicationDelegate's application:didFinishLaunchingWithOptions:.
 
 @warning Add UIWindow subviews below the splash view or set the UIWindow's rootController before
 calling startWithStatus: to prevent the splash view from being removed/hidden.
 @note Should be initialized from a Nib file.
 */
@interface NBUSplashView : UIView

/// @name Outlets

/// The background UIImageView. Normally set to the apropiate `Default.png`.
@property (weak, nonatomic) IBOutlet UIImageView * imageView;

/// An optional activity indicator.
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView * activityIndicatorView;

/// An optional progress view.
@property (weak, nonatomic) IBOutlet UIProgressView * progressView;

/// An optional status label.
@property (weak, nonatomic) IBOutlet UILabel * statusLabel;

/// An optional application version label.
@property (weak, nonatomic) IBOutlet UILabel * versionLabel;

/// @name Methods

/// Displays the splash view on top of the key UIWindow.
/// @param status The initial status message.
/// @param window The window where the splash view should be presented. If nil the splash
/// view will try to use UIApplication's keyWindow.
- (void)startWithStatus:(NSString *)status
                 window:(UIWindow *)window;

/// Set progressView to complete and remove the splash view from the UIWindow.
/// @param status The last status message to be displayed.
/// @param animated Whether to animate the removal of the splash view.
- (void)finishWithStatus:(NSString *)status
                animated:(BOOL)animated;

/// Update the progressView and status message with a single message.
/// @param progress The progress to be assigned to the progressView (ranging from 0.0 to 1.0).
/// @param status The new status message.
- (void)updateProgress:(float)progress
            withStatus:(NSString *)status;

@end

