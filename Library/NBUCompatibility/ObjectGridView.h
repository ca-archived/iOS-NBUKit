//
//  ObjectGridView.h
//  NBUBase
//
//  Created by エルネスト 利辺羅 on 12/02/06.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
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

