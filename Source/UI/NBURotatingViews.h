//
//  NBURotatingViews.h
//  NBUKit
//
//  Created by Ernesto Rivera on 2013/02/28.
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
 A protocol for views that listen to device orientation changes to rotate accordingly.
 
 @note Usually used only with view controllers that do not rotate by themselves.
 */
@protocol NBURotatingView <NSObject>

/// @name Configuring the View

/// Whether rotations should be animated. Default `YES`.
@property (nonatomic) BOOL animated;

/// The mask made of UIInterfaceOrientationMask's to support.
@property (nonatomic) UIInterfaceOrientationMask supportedInterfaceOrientations;

/// @name Methods

/// Programatically try rotate the view.
/// @discussion If orientation is not among the supportedInterfaceOrientations then
/// no rotation will take place.
/// @param orientation The desired interface orientation.
/// @param animated Whether the rotation should be animated.
- (void)setInterfaceOrientation:(UIInterfaceOrientation)orientation
                       animated:(BOOL)animated;

@end


/**
 A UIView that listens to device orientation changes to rotate accordingly.
 
 @note Usually used only with view controllers that do not rotate by themselves.
 */
@interface NBURotatingView : UIView <NBURotatingView>

@end


/**
 A UIImageView that listens to device orientation changes to rotate accordingly.
 
 @note Usually used only with view controllers that do not rotate by themselves.
 */
@interface NBURotatingImageView : UIImageView <NBURotatingView>

@end


/**
 A UIButton that listens to device orientation changes to rotate accordingly.
 
 @note Usually used only with view controllers that do not rotate by themselves.
 */
@interface NBURotatingButton : UIButton <NBURotatingView>

@end

