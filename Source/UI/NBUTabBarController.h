//
//  NBUTabBarController.h
//  NBUKit
//
//  Created by 利辺羅 on 2012/09/19.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

@class NBUTabBarModel;

/**
 A customizable UITabBarController.
 
 The controller's tabBar can be set on top and/or a NBUTabBarModel can be used
 to set up tab buttons position and/or custom views.
 
 @note Should be initialized from a Nib file.
 */
@interface NBUTabBarController : UITabBarController

/// @name Configurable Properties

/// Whether or not the tabBar should be placed on top. Default `NO`.
///
/// If the tabBarModel's tag has a value different from `0` then the tabBar will be on top.
@property (nonatomic) BOOL tabBarOnTop;

/// A model UIView that if set will be used to customize the controllers tabBar.
/// @see NBUTabBarModel.
@property (strong, nonatomic) IBOutlet NBUTabBarModel * tabBarModel;

/// @name Methods

/// Force controller's view and tabBar to be adjusted using the tabBarOnTop and/or
/// tabBarModel.
/// @note Usually there is no need to call this method directly.
- (void)adjustViews;

@end

/**
 A UITabBar subclass made only to prevent the defautl `layoutSubviews` from
 being called.
 */
@interface NBUTabBar : UITabBar

@end

/**
 A UIView to be used as a model to customize a NBUTabBar:
 
 - Apply it's height to the tabBar.
 - Match tabBar buttons frames to the itemPlaceholders.
 - Add the NBUTabBarModel view itself below the first button.
 */
@interface NBUTabBarModel : UIView

/// An array of placeholders used to adjust NBUTabBar buttons.
/// @note The number of placeholders should match the number of tabbar buttons.
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray * itemPlaceholders;

@end

