//
//  ObjectTableView.h
//  NBUBase
//
//  Created by エルネスト 利辺羅 on 12/02/29.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

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

