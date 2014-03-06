//
//  ObjectSlideView.h
//  NBUCompatibility
//
//  Created by Ernesto Rivera on 2011/12/27.
//  Copyright (c) 2011-2014 CyberAgent Inc.
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
 Display an array of views horizontally.

 By default it uses paging, autosizes views squarely and centers them.
 It can also can change pages randomly.

 @note Should be initialized from a Nib file.
 */
@interface ObjectSlideView : ObjectArrayView <UIScrollViewDelegate>

/// The currently loaded views.
/// @note Not all object views may be loaded at the same time.
@property (strong, nonatomic, readonly)     NSArray * currentViews;

/// @name Configurable Properties

/// Change pages randomly.
@property (nonatomic) BOOL changePagesRandomly;

/// Whether or not to center views.
/// @discussion Default `YES`.
@property (nonatomic) BOOL centerViews;

/// @name Outlets

/// The UIScrollView that will control scrolling between views.
@property (strong, nonatomic) IBOutlet UIScrollView * scrollView;

/// An optional UIPageControl.
@property (strong, nonatomic) IBOutlet UIPageControl * pageControl;

/// @name Actions

/// Present the objectArray in a new controller fullscreen.
/// @param sender The sender object.
- (IBAction)presentModal:(id)sender;

/// Called by pageControl.
/// @param sender The sender object.
- (IBAction)changePage:(id)sender;

@end
