//
//  UIButton+NBUAdditions.h
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/10/15.
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
 A simple protocol to unify UIButton and UIBarButtonItem common/similar methods.
 
 - Set title, enable/disable.
 */
@protocol UIButton <NSObject>

/// The button title.
@property(nonatomic, copy)              NSString * title;

/// Whether the button should be enabled.
@property(nonatomic, getter=isEnabled)  BOOL enabled;

/// Whether the button should be hidden.
@property(nonatomic, getter=isHidden)   BOOL hidden;

// The tint color to apply to the button.
@property(nonatomic, retain)            UIColor * tintColor;

@end


/**
 Implementation of the UIButton protocol for UIButton objects.
 */
@interface UIButton (NBUAdditions) <UIButton>

@end


/**
 Implementation of the UIButton protocol for UIBarButtonItem objects.
 */
@interface UIBarButtonItem (NBUAdditions) <UIButton>

@end

