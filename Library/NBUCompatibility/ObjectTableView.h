//
//  ObjectTableView.h
//  NBUCompatibility
//
//  Created by Ernesto Rivera on 2012/02/29.
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
 A UITableView to present an array of objects.
 
 - Handle all delegate methods.
 - Use section 0 for objects and section 1 for the loadMoreView.
 - By default sizeToFitObjectViews = YES.
 - If set, only targetObjectViewSize's height is used to adjust cell's size.
 
 @note Only supports initialization from a Nib file.
 */
@interface ObjectTableView : ObjectArrayView <UITableViewDataSource, UITableViewDelegate>

/// Underlying UITableView
@property (strong, nonatomic, readonly)             UITableView * tableView;

@property (strong, nonatomic) IBOutlet              UIView *headerView;
@property (strong, nonatomic) IBOutlet              UIView *footerView;
/// "More objects" load view
@property (strong, nonatomic) IBOutlet              UITableViewCell * loadMoreView;

/// @name Other Properties

@property (nonatomic, readonly)                     NSUInteger objectArraySection;
@property (nonatomic, readonly)                     NSUInteger loadMoreViewSection;

@property (nonatomic) BOOL doesNotResize;

/// @name Managing row heights (You can also use targetObjectViewSize's height)

/// Use negative values to clear height.
- (void)setRowHeight:(CGFloat)height
           forObject:(id)object;

- (void)setRowHeight:(CGFloat)height
             atIndex:(NSUInteger)index;

/// Toggle between 0.0 and default.
- (void)toggleObjectAtIndex:(NSUInteger)index;

- (void)resetRowHeights;

- (id)getCellContentView:(NSInteger)index;

/// Managing scroll.
- (void)scrollToRowAtIndex:(NSUInteger)index;

- (void)forceRefreshTableView;

@end

