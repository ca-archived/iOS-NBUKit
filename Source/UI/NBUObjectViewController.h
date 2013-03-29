//
//  NBUObjectViewController.h
//  NBUKit
//
//  Created by 利辺羅 on 2012/11/15.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import "ScrollViewController.h"

/**
 Superclass for view controllers that update their UI according to a model object.
 
 - Update your UI in a single objectUpdated: method which will be called
 automatically when both the view is loaded and the object is set.
 */
@interface NBUObjectViewController : ScrollViewController

/// The associated object.
///
/// Override in subclasses with a more concrete class and name, i.e.:
///     @property (strong, nonatomic, setter = setObject:, getter = object) UIImage * image;
/// Then make sure that you set the property dynamic:
///     @dynamic image;
@property (strong, nonatomic) id object;

/// Whether to ignore the objects' NBUObjectUpdatedNotification. Default `NO`.
@property (nonatomic) BOOL ignoresObjectUpdates;

/// Method called when the underlying object sends a NBUObjectUpdatedNotification.
/// @note You should update your object's UI overriding this method.
/// @param userInfo An optional user info dictionary that could be used to specify what has changed.
- (void)objectUpdated:(NSDictionary *)userInfo;

@end

