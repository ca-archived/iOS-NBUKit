//
//  ObjectSlideView.h
//  NBUBase
//
//  Created by エルネスト 利辺羅 on 11/12/27.
//  Copyright (c) 2011年 CyberAgent Inc. All rights reserved.
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
///
/// Default `YES`.
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
