//
//  NBUObjectView.h
//  NBUKit
//
//  Created by 利辺羅 on 2012/11/15.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

/// Underlying object's update notification.
extern NSString * const NBUObjectUpdatedNotification;

extern NSString * const NBUObjectUpdatedTypeKey;
extern NSString * const NBUObjectUpdatedTypeNewObject;
extern NSString * const NBUObjectUpdatedOldObjectKey;

/**
 Superclass for views that update their UI according to a model object.
 
 - Update your UI in a single objectUpdated: method which will be called
 automatically when needed.
 */
@interface NBUObjectView : ObjectView

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

