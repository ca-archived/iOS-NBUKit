//
//  NBUSplashView.h
//  NBUKit
//
//  Created by 利辺羅 on 2012/08/07.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
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
@property (assign, nonatomic) IBOutlet UIImageView * imageView;

/// An optional activity indicator.
@property (assign, nonatomic) IBOutlet UIActivityIndicatorView * activityIndicatorView;

/// An optional progress view.
@property (assign, nonatomic) IBOutlet UIProgressView * progressView;

/// An optional status label.
@property (assign, nonatomic) IBOutlet UILabel * statusLabel;

/// An optional application version label.
@property (assign, nonatomic) IBOutlet UILabel * versionLabel;

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

