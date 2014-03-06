//
//  NBUBadgeView.h
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/04/20.
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

/**
 A simple badge view similar to the UITabBar badges that can be used with any other view.
 
 - Animates when set/cleared.
 - Supports any string.
 - Sizes to fit automatically.
 - Adjusts origin's x according to its UIViewAutoresizing's flexible margins. 
 */
@interface NBUBadgeView : ObjectView

/// @name Methods

/// Get a new NBUBadgeView instance.
+ (NBUBadgeView *)badge;

/// @name Properties

/// Associated badge value. Set to `nil` or `@""` to hide.
@property (strong, nonatomic, setter=setObject:,
                              getter=object)        NSString * value;

/// @name Outlets

/// The display label.
@property (strong, nonatomic) IBOutlet              UILabel * label;

@end

