//
//  NBURotatingViews.h
//  NBUKit
//
//  Created by 利辺羅 on 2013/02/28.
//  Copyright (c) 2013年 CyberAgent Inc. All rights reserved.
//

/**
 A UIView that listens to device orientation changes to retate accordingly.
 
 @note Usually used only with view controllers that do not rotate by themselves.
 */
@interface NBURotatingView : UIView

/// @name Configuring the View

/// Whether rotations should be animated. Default `YES`.
@property (nonatomic) BOOL animated;

/// The mask made of UIInterfaceOrientationMask's to support.
@property (nonatomic) UIInterfaceOrientationMask supportedInterfaceOrientations;

/// @name Methods

/// Programatically rotate the view.
/// @param orientation The desired orientation.
/// @param animated Whether the rotation should be animated.
- (void)rotateToOrientation:(UIDeviceOrientation)orientation
                   animated:(BOOL)animated;

@end


/**
 A UIImageView that listens to device orientation changes to retate accordingly.
 
 @note Usually used only with view controllers that do not rotate by themselves.
 */
@interface NBURotatingImageView : UIImageView

/// @name Configuring the View

/// Whether rotations should be animated. Default `YES`.
@property (nonatomic) BOOL animated;

/// The mask made of UIInterfaceOrientationMask's to support.
@property (nonatomic) UIInterfaceOrientationMask supportedInterfaceOrientations;

/// @name Methods

/// Programatically rotate the view.
/// @param orientation The desired orientation.
/// @param animated Whether the rotation should be animated.
- (void)rotateToOrientation:(UIDeviceOrientation)orientation
                   animated:(BOOL)animated;

@end


/**
 A UIButton that listens to device orientation changes to retate accordingly.
 
 @note Usually used only with view controllers that do not rotate by themselves.
 */
@interface NBURotatingButton : UIButton

/// @name Configuring the View

/// Whether rotations should be animated. Default `YES`.
@property (nonatomic) BOOL animated;

/// The mask made of UIInterfaceOrientationMask's to support.
@property (nonatomic) UIInterfaceOrientationMask supportedInterfaceOrientations;

/// @name Methods

/// Programatically rotate the view.
/// @param orientation The desired orientation.
/// @param animated Whether the rotation should be animated.
- (void)rotateToOrientation:(UIDeviceOrientation)orientation
                   animated:(BOOL)animated;

@end

