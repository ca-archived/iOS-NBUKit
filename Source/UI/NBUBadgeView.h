//
//  NBUBadgeView.h
//  NBUKit
//
//  Created by エルネスト 利辺羅 on 12/04/20.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

/**
 A simple badge view similar to the UITabBar badges that can be used with any other view.
 
 - Animates when set/cleared.
 - Supports any string.
 - Sizes to fit automatically.
 */
@interface NBUBadgeView : ObjectView

/// @name Methods

/// Get a new NBUBadgeView instance.
+ (NBUBadgeView *)badge;

/// @name Properties

/// Associated badge value. Set to `nil` or `@""` to hide.
@property (strong, nonatomic, setter = setObject:, getter = object) NSString * value;

/// @name Outlets

/// The display label.
@property (strong, nonatomic) IBOutlet UILabel * label;

@end

