//
//  UIImageView+NBUAdditions.h
//  NBUCore
//
//  Created by 利辺羅 on 2012/11/29.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

/**
 A simple protocol for UIImageView-like objects with a common `image` property.
 
 - Set/get image.
 */
@protocol UIImageView <NSObject>

/// Set/get an image.
@property(nonatomic, retain) UIImage * image;

@end

/**
 Implementation of the UIImageView protocol for UIImageView objects.
 */
@interface UIImageView (NBUAdditions) <UIImageView>

@end

