//
//  ObjectTableView.m
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

#import "ObjectTableView.h"
#import "NBUKitPrivate.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_COMPATIBILITY

// Private classes
@interface FlexibleTableView : UITableView
{
    BOOL _doNotFireSizeNotification;
}
@property (nonatomic, readonly) ObjectTableView * superview;

@end

@interface ActiveCell : UITableViewCell

@end


@implementation ObjectTableView
{
    // Private properties
    UIView * _modelView;
    NSMutableDictionary * _rowHeights;
}

@dynamic delegate;
@dynamic loadMoreView;

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        self.sizeToFitObjectViews = YES; // Default value
        
        // Init tableView
        _tableView = [[FlexibleTableView alloc] initWithFrame:self.bounds
                                                  style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                       UIViewAutoresizingFlexibleHeight);
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.bounces = NO;
        _tableView.allowsSelection = NO;
        _tableView.scrollEnabled = NO;
        
        [self addSubview:_tableView];
        
        // Init sections
        self.loadMoreViewOnTop = NO;
        
        // Init row heights
        _rowHeights = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    
    // If you set a header and/or footer in IB, hook them up here
    _tableView.tableHeaderView = self.headerView;
    _tableView.tableFooterView = self.footerView;
}

- (void)setLoadMoreViewOnTop:(BOOL)loadMoreViewOnTop
{
    // Normal (bottom)
    if (!loadMoreViewOnTop)
    {
        _objectArraySection = 0;
        _loadMoreViewSection = 1;
    }
    // Inverted
    else
    {
        _objectArraySection = 1;
        _loadMoreViewSection = 0;
    }
}

- (id)getCellContentView:(NSInteger)index
{
    NSIndexPath* path = [NSIndexPath indexPathForRow:index inSection:0];
    
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:path];
    
    if ([(cell.contentView.subviews)[0] isKindOfClass:[UIView class]])
    {
        return (cell.contentView.subviews)[0];
        
    }
    
    return nil;
}

#pragma mark - Object array management

- (void)setObject:(NSArray *)objectArray
{
    super.objectArray = objectArray;
    
    [_tableView reloadData];
    
//    [_tableView beginUpdates];
//    
//    // Remove deleted objects' views
//    id object;
//    NSMutableArray * deletedIndexPaths = [NSMutableArray array];
//    for (NSInteger i = [self.objectArray count]-1; i>=0; i--)
//    {
//        object = [self.objectArray objectAtIndex:i];
//        if (![objectArray containsObject:object])
//        {
//            [deletedIndexPaths addObject:[NSIndexPath indexPathForRow:i
//                                                            inSection:_objectArraySection]];
//            [super removeObjectAtIndex:i];
//        }
//    }
//    [_tableView deleteRowsAtIndexPaths:deletedIndexPaths
//                      withRowAnimation:self.animated ? UITableViewRowAnimationFade : UITableViewRowAnimationNone];
//    
//    // Update remaining objects and add new ones
//    NSMutableArray * insertedIndexPaths = [NSMutableArray array];
//    NSMutableArray * modifiedIndexPaths = [NSMutableArray array];
//    for (NSUInteger i = 0; i<[objectArray count]; i++)
//    {
//        object = [objectArray objectAtIndex:i];
//        
//        // Update
//        if ([self.objectArray containsObject:object])
//        {
//            // Moved?
//            if ([self.objectArray indexOfObject:object] != i)
//            {
//                [_tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:[self.objectArray indexOfObject:object]
//                                                                  inSection:_objectArraySection]
//                                   toIndexPath:[NSIndexPath indexPathForRow:i
//                                                                  inSection:_objectArraySection]];
//                [modifiedIndexPaths addObject:[NSIndexPath indexPathForRow:i
//                                                                 inSection:_objectArraySection]];
//            }
//            
//            // ToDo Update contents/reset rowHeights
//        }
//        // New
//        else
//        {
//            [insertedIndexPaths addObject:[NSIndexPath indexPathForRow:i
//                                                             inSection:_objectArraySection]];
//        }
//    }
//    super.objectArray = objectArray;
//    [_tableView insertRowsAtIndexPaths:insertedIndexPaths
//                      withRowAnimation:self.animated ? UITableViewRowAnimationFade : UITableViewRowAnimationNone];
//    [_tableView reloadRowsAtIndexPaths:modifiedIndexPaths
//                      withRowAnimation:self.animated ? UITableViewRowAnimationFade : UITableViewRowAnimationNone];
//    
//    // Also update load more view section
//    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:_loadMoreViewSection]
//              withRowAnimation:self.animated ? UITableViewRowAnimationFade : UITableViewRowAnimationNone];
//    
//    [_tableView endUpdates];
}

- (void)addObject:(id)object
{
    // Refuse our table view!
    if (object == _tableView)
        return;
    
    [super addObject:object];
    
    [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(NSInteger)[self.objectArray count] - 1
                                                                                   inSection:(NSInteger)_objectArraySection]]
                      withRowAnimation:self.animated ? UITableViewRowAnimationFade : UITableViewRowAnimationNone];
}

- (void)removeObject:(id)object
{
    NSUInteger index = [self.objectArray indexOfObject:object];
    
    if (index == NSNotFound)
        return;
    
    [super removeObject:object];
    [_tableView endEditing:YES]; // ToDo Only if editing this cell
    [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(NSInteger)index
                                                                                   inSection:(NSInteger)_objectArraySection]]
                      withRowAnimation:self.animated ? UITableViewRowAnimationFade : UITableViewRowAnimationNone];
}

- (void)insertObject:(id)object atIndex:(NSUInteger)index
{
    [super insertObject:object atIndex:index];
    
    [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(NSInteger)index
                                                                                   inSection:(NSInteger)_objectArraySection]]
                      withRowAnimation:self.animated ? UITableViewRowAnimationFade : UITableViewRowAnimationNone];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)object
{
    [super replaceObjectAtIndex:index withObject:object];

    [_tableView endEditing:YES]; // ToDo Only if editing this cell
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(NSInteger)index
                                                                                   inSection:(NSInteger)_objectArraySection]]
                      withRowAnimation:self.animated ? UITableViewRowAnimationFade : UITableViewRowAnimationNone];
}

#pragma mark - TableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Object views
    if (section == _objectArraySection)
    {
        return (NSInteger)[self.objectArray count];
    }
    
    // Load more view
    else if (section == _loadMoreViewSection)
    {
        return self.hasMoreObjects ? 1 : 0;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Object views
    if (indexPath.section == _objectArraySection)
    {
        id object = (self.objectArray)[(NSUInteger)indexPath.row];
        
        NSString * identifier = self.nibNameForViews; // ? self.nibNameForViews : NSStringFromClass([object class]);
        
        // Reuse cell
        UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:identifier];
        UIView * view;
        if (cell)
        {
            view = [[cell.contentView subviews] lastObject];
            
            // Also ask delegate to configure it?
            if (view && [self.delegate respondsToSelector:@selector(objectArrayView:configureView:withObject:)])
            {
                [self.delegate objectArrayView:self
                                 configureView:view
                                    withObject:object];
            }
            // Configure it if it's an ObjectView
            else if ([view isKindOfClass:[ObjectView class]])
            {
                ((ObjectView *)view).object = object;
            }
        }
        
        // Or create a new cell
        else
        {
            // Load new
            cell = [[ActiveCell alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:identifier];
            cell.clipsToBounds = YES;
            view = [self viewForObject:object];
            view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
            view.frame = CGRectMake(cell.contentView.bounds.origin.x,
                                    cell.contentView.bounds.origin.y,
                                    cell.contentView.bounds.size.width,
                                    view.frame.size.height);
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.bounds = view.frame;
            [cell.contentView addSubview:view];
        }
        return cell;
    }
    
    // Load more view
    else if (indexPath.section == _loadMoreViewSection)
    {
        if (!self.loadMoreView)
        {
            NBULogError(@"loadMoreView is nil so an empty cell will be used instead");
            return [[ActiveCell alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:nil];
        }
        return self.loadMoreView;
    }
    
    // We shouldn't reach here!!!
    NBULogError(@"Cell is being asked for non-existent indexPath: %@. Will return an empty cell", indexPath);
    return [[ActiveCell alloc] initWithStyle:UITableViewCellStyleDefault
                             reuseIdentifier:nil];
}

#pragma mark - Show/Hide objects

- (void)setObject:(id)object
           hidden:(BOOL)yesOrNo
{
    [super setObject:object
              hidden:yesOrNo];
    
    [self setRowHeight:yesOrNo ? 0.0 : -1.0
             forObject:object];
}

- (void)setRowHeight:(CGFloat)height
           forObject:(id)object
{
    NSUInteger index = [self.objectArray indexOfObject:object];
    
    if (index==NSNotFound)
    {
        NBULogWarn(@"Ignoring setRowHeight for not present object: %@", object);
        return;
    }
    
    [self setRowHeight:height
               atIndex:index];
}

- (void)setRowHeight:(CGFloat)height
             atIndex:(NSUInteger)index
{
    // ToDo Ignore when possible
    
    [_rowHeights setValue:(height >= 0) ? @(height) : nil
                   forKey:[NSString stringWithFormat:@"%@", @(index)]];
    
    [self postSizeThatFitsChangedNotification];
}

- (void)toggleObjectAtIndex:(NSUInteger)index
{
    NSString * key = [NSString stringWithFormat:@"%@", @(index)];
    
    // Was already 0.0?
    if (_rowHeights[key] &&
        [(NSNumber *)[_rowHeights valueForKey:key] floatValue] == 0.0)
    {
        // Reset
        [self setObjectAtIndex:index hidden:NO];
    }
    // Else show it
    else
    {
        [self setObjectAtIndex:index hidden:YES];
    }
}

- (void)resetRowHeights
{
    [_rowHeights removeAllObjects];
}

#pragma mark - TableView delegate

- (void)setTargetObjectViewSize:(CGSize)targetObjectViewSize
{
    [super setTargetObjectViewSize:targetObjectViewSize];
    
    _tableView.rowHeight = targetObjectViewSize.height;
}

- (CGFloat)logTableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Object views
    if (indexPath.section == _objectArraySection)
    {
        // a) Overriden height?
        NSString * key = [NSString stringWithFormat:@"%@", @(indexPath.row)];
        if (_rowHeights[key])
        {
            NSNumber *num = _rowHeights[key];
            return [num floatValue];
            //                return [(NSNumber *)[_rowHeights valueForKey:key] floatValue];
        }
        
        // b) Resize to target size?
        if (!CGSizeEqualToSize(self.targetObjectViewSize, CGSizeZero))
        {
            return self.targetObjectViewSize.height;
        }
        
        // c) Objects already a view?
        id object = (self.objectArray)[(NSUInteger)indexPath.row];
        UIView * view;
        if ([object isKindOfClass:[UIView class]])
        {
            view =  (UIView *)object;
        }
        
        // d) Create/Use a model view if nibNameForViews was set
        if (!view && self.nibNameForViews)
        {
            // Create a model?
            if (!_modelView)
            {
                _modelView = [NSBundle loadNibNamed:self.nibNameForViews
                                               owner:self
                                             options:nil][0];
            }
            
            // Configure the model
            if ([self.delegate respondsToSelector:@selector(objectArrayView:configureView:withObject:)])
            {
                [self.delegate objectArrayView:self
                                 configureView:_modelView
                                    withObject:object];
            }
            else if ([_modelView isKindOfClass:[ObjectView class]])
            {
                ((ObjectView *)_modelView).object = object;
            }
            
            view = _modelView;
        }
        
        // View still not loaded?
        if (!view)
        {
            // Last try
            view = [self viewForObject:object];
        }
        
        // c) SizeToFit loded view?
        if (self.sizeToFitObjectViews)
        {
            return [view sizeThatFits:tableView.bounds.size].height;
        }
        
        // d) Loaded view's height
        NBULogVerbose(@"\nobject: %@\nview: %@\nsize: %f\n", object, view, view.bounds.size.height);
        return view.bounds.size.height;
    }
    
    // Load more view
    else if (indexPath.section == _loadMoreViewSection)
    {
        return self.loadMoreView.frame.size.height;
    }
    
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [self logTableView:tableView heightForRowAtIndexPath:indexPath];
    NBULogVerbose(@"--- %@,%@: %f", @(indexPath.section), @(indexPath.row), height);
    return height;
}

#pragma mark - Scroll delegate/management

- (void)scrollToRowAtIndex:(NSUInteger)index
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ScrollToVisibleNotification
                                                        object:[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(NSInteger)index
                                                                                                                    inSection:(NSInteger)_objectArraySection]]];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    if (self.isEmpty || self.doesNotResize)
    {
        NBULogVerbose(@"<<< %@ (tv originalSize)",
                   NSStringFromCGSize(CGSizeMake(size.width,
                                                 self.originalSize.height)));
        return CGSizeMake(size.width,
                          self.originalSize.height);
    }
    NBULogVerbose(@"<<< %@ to %@ (tv)",
               NSStringFromCGSize(self.bounds.size),
               NSStringFromCGSize(CGSizeMake(size.width,
                                             _tableView.contentSize.height)));

    return CGSizeMake(size.width, 
                      _tableView.contentSize.height);
}

- (void)forceRefreshTableView
{
    //    _doNotFireSizeNotification = YES;
    
    [UIView setAnimationsEnabled:NO];
    
    [_tableView beginUpdates];
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:_loadMoreViewSection]
              withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];
    
    [UIView setAnimationsEnabled:YES];
    
    //    _doNotFireSizeNotification = NO;
    //    return CGSizeMake(size.width,
    //                      self.contentSize.height);
}

@end


@implementation FlexibleTableView

@dynamic superview;

- (void)setContentSize:(CGSize)contentSize
{
//    NBULogVerbose(@"!!! %p %@", self, NSStringFromCGSize(contentSize));
    [super setContentSize:contentSize];
    
    if (_doNotFireSizeNotification ||
        (self.bounds.size.height == contentSize.height))
    {
        return;
    }
    
    // Fire notification!
    NBULogVerbose(@"! %p contentSize changed: %@ should be %@",
               self.superview,
               NSStringFromCGSize(self.bounds.size),
               NSStringFromCGSize(contentSize));
    [self.superview postSizeThatFitsChangedNotification];
}

@end


@implementation ActiveCell

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if (self.contentView.subviews.count == 0)
    {
        self.hidden = YES;
        return;
    }
    
    self.hidden = NO;

    // Resize contentView's view if frame has height > 0
    UIView * view = (self.contentView.subviews)[0];
    if (frame.size.height > 0.0)
    {
        NBULogVerbose(@"%p xxx %@ (%@)", self, NSStringFromCGRect(frame), @(self.subviews.count));
        view.hidden = NO;
        view.frame = self.bounds;
    }
    else
    {
        NBULogVerbose(@"%p xxx skipped %@ (%@)", self, NSStringFromCGRect(frame), @(self.subviews.count));
        view.hidden = YES;
    }
}

@end


