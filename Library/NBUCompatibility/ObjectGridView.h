//
//  ObjectGridView.h
//  NBUCompatibility
//
//  Created by Ernesto Rivera on 2012/02/06.
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

#import "ObjectArrayView.h"

/**
 Display an array of views corresponding to [ObjectArrayView objectArray] objects and manages the corresponding views.
 
 @note Should be initialized from a Nib file
 */
@interface ObjectGridView : ObjectArrayView

/// @name Properties

/// The currently loaded views.
/// @note Not all object views may be loaded at the same time.
@property (strong, nonatomic, readonly)     NSArray * currentViews;

/// Set to YES for performance optimizations for big number of views. Default NO.
@property (nonatomic)                       BOOL equallySizedViews;

/// @name Compatibility

/// Settting to YES forces to always use freshly loaded Nib views. Default NO.
/// @note Enabling it slows down scrolling.
@property (nonatomic)                       BOOL forceDoNotReuseViews;

/// Setting to YES forces to load all views since the beginning. Default NO.
/// @note May be faster for few objects but uses more memory.
@property (nonatomic)                       BOOL forceLoadAllViews;

/// @name Methods

/// Reset all aspects of the grid view so that it can be safely reused with new objectArray.
- (void)resetGridView;

- (void)startObservingScrollViewDidScroll;

@end

