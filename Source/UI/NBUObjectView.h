//
//  NBUObjectView.h
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/11/15.
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

#import "ObjectView.h"

/// Underlying object's update notification.
extern NSString * const NBUObjectUpdatedNotification;

/// User info keys.
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
/// @discussion Override in subclasses with a more concrete class and name, i.e.:
///     @property (strong, nonatomic, setter=setObject:, getter=object) UIImage * image;
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

