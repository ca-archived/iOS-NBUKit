//
//  ObjectArrayView.m
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
#import "NBUKitPrivate.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_COMPATIBILITY

@implementation ObjectArrayView
{
    NSMutableSet * _hiddenObjects;
}

@dynamic objectArray;

- (Class)expectedClass
{
    return [NSArray class];
}

- (void)commonInit
{
    [super commonInit];
    
    // Init the object array and hidden objects' array
    super.object = [NSMutableArray array];
    _hiddenObjects = [NSMutableSet set];
    
    // Observe object deletions
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(objectDeleted:)
                                                 name:ObjectDeletedNotification
                                               object:nil];
}

- (void)dealloc
{
    // Stop observing
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:ObjectDeletedNotification
                                                  object:nil];
}

- (BOOL)isEmpty
{
    return (!self.objectArray || [self.objectArray count] == 0);    // No items in the array?
//             && !self.hasMoreObjects);                                      // ...and no more objects to load?
}

- (BOOL)hasMoreObjects
{
    BOOL hasMoreObjects = ([_delegate respondsToSelector:@selector(objectArrayViewHasMoreObjects:)] &&
                           [_delegate objectArrayViewHasMoreObjects:self]);
    if (hasMoreObjects)
    {
        if (_loadMoreView)
        {
            return YES;
        }
        else
        {
            NBULogError(@"delegate %@ says it hasMoreObjects but no loadMoreView was provided.", _delegate);
        }
    }
    return NO;
}

- (IBAction)loadMoreObjects:(id)sender
{
    NBULogVerbose(@"%d",self.hasMoreObjects);
    if (self.hasMoreObjects &&
        [_delegate respondsToSelector:@selector(objectArrayViewLoadMoreObjects:)])
    {
        [_delegate objectArrayViewLoadMoreObjects:self];
    }
}

#pragma mark - Object array management (subclasses should manage the UI)

// Save a mutable copy of the array
- (void)setObject:(NSArray *)objectArray
{
    NBULogVerbose(@"%@ setObjectArray: %@ elements", self, @(objectArray.count));
    
    [super setObject:[NSMutableArray arrayWithArray:objectArray]];
}

- (void)addObject:(id)object
{
    if ([self.objectArray containsObject:object])
    {
        NBULogWarn(@"Adding already present object: %@", object);
    }
    [(NSMutableArray *)self.objectArray addObject:object];
    
    // *** Update UI in subclass ***
}

- (void)addObjectIfNotPresent:(id)object
{
    if (![self.objectArray containsObject:object])
    {
        [self addObject:object];
    }
}

- (void)removeObject:(id)object
{
    [(NSMutableArray *)self.objectArray removeObject:object];
    
    // *** Update UI in subclass ***
}

- (void)insertObject:(id)object
             atIndex:(NSUInteger)index
{
    if (index > self.objectArray.count)
    {
        NBULogError(@"insertObject ignored for index %@ as objectArray has count %@",
                   @(index), @(self.objectArray.count));
        return;
    }
    
    [(NSMutableArray *)self.objectArray insertObject:object
                                             atIndex:index];
    
    // *** Update UI in subclass ***
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    if (index >= self.objectArray.count)
    {
        NBULogError(@"removeObjectAtIndex ignored for index %@ as objectArray has count %@",
                   @(index), @(self.objectArray.count));
        return;
    }
    
    [(NSMutableArray *)self.objectArray removeObjectAtIndex:index];
    
    // *** Update UI in subclass ***
}

- (void)replaceObjectAtIndex:(NSUInteger)index
                  withObject:(id)object
{
    if (index >= self.objectArray.count)
    {
        NBULogError(@"replaceObjectAtIndex ignored for index %@ as objectArray has count %@",
                   @(index), @(self.objectArray.count));
        return;
    }
    
    ((NSMutableArray *)self.objectArray)[index] = object;
    
    // *** Update UI in subclass ***
}

#pragma mark - Show/Hide objects

- (NSArray *)hiddenObjects
{
    return [_hiddenObjects allObjects];
}

- (void)setObject:(id)object
           hidden:(BOOL)yesOrNo
{
    if (![self.objectArray containsObject:object])
    {
        NBULogWarn(@"Ignoring hide message for object not present: %@", object);
        return;
    }
    
    if (yesOrNo)
    {
        [_hiddenObjects addObject:object];
    }
    else
    {
        [_hiddenObjects removeObject:object];
    }
    
    // *** Update UI in subclass ***
}

- (void)setObjectAtIndex:(NSUInteger)index
                  hidden:(BOOL)yesOrNo
{
    if (index >= self.objectArray.count)
    {
        NBULogError(@"setObjectAtIndex hidden ignored for index %@ as objectArray has count %@",
                    @(index), @(self.objectArray.count));
        return;
    }
    
    [self setObject:self.objectArray[index]
             hidden:yesOrNo];
}

#pragma mark - Notification handling

- (void)objectDeleted:(NSNotification *)notification
{
    [self removeObject:notification.object];
}

#pragma mark - Object's view handling

// Add subviews as objectArray elements
- (void)populateObjectArrayWithSubviews
{
    for (UIView * view in self.subviews)
    {
        if (view != _loadMoreView &&
            view != self.noContentsView &&
            ![self.objectArray containsObject:view])
        {
            [self addObject:view];
        }
    }
}

- (UIView *)dequeueOrLoadViewFromNib
{
    // ** This class only loads from nib, implement dequeue in subclasses! **
    return [NSBundle loadNibNamed:_nibNameForViews
                             owner:self
                           options:nil][0];
}

- (UIView *)viewForObject:(id)object
{
    UIView * view;
    
    // a) Ask delegate to create it
    if ([_delegate respondsToSelector:@selector(objectArrayView:viewForObject:)])
    {
        view = [self configuredViewForObject:object
                                fromDelegate:_delegate];
        
        // Return if successful
        if (view)
            return view;
    }
    
    // b) Just use the object if it's a UIView
    if ([object isKindOfClass:[UIView class]])
    {
        view = object;
    }
    
    // c) Load view from a Nib file
    else if (_nibNameForViews)
    {
        view = [self dequeueOrLoadViewFromNib];
        
        // Also ask delegate to configure it?
        if (view && [_delegate respondsToSelector:@selector(objectArrayView:configureView:withObject:)])
        {
            [_delegate objectArrayView:self
                         configureView:view
                            withObject:object];
        }
        // Configure it if it's an ObjectView
        else if ([view isKindOfClass:[ObjectView class]])
        {
            ((ObjectView *)view).object = object;
        }
    }
    
    // d) Create a UIImageView if object is an UIImage
    else if ([object isKindOfClass:[UIImage class]])
    {
        view = [[UIImageView alloc] initWithImage:object];
        view.contentMode = UIViewContentModeScaleAspectFill;
        view.clipsToBounds = YES;
    }
    
    // e) The object conforms to the delegate protocol?
    else if ([object conformsToProtocol:@protocol(ObjectArrayViewDelegate)] &&
             [object respondsToSelector:@selector(objectArrayView:viewForObject:)])
    {
        view = [self configuredViewForObject:object
                                fromDelegate:object];
    }
    
    // ?) Add support for more kinds of objects?
    
    // View is nil?
    if (!view)
    {
        @throw [NSException exceptionWithName:@"ObjectArrayViewException"
                                       reason:[NSString stringWithFormat:@"Couldn't create view for: %@",
                                               NSStringFromClass([object class])]
                                     userInfo:nil];
    }
    
    return view;
}

- (UIView *)configuredViewForObject:(id)object
                       fromDelegate:(id<ObjectArrayViewDelegate>)delegate
{
    UIView * view = [delegate objectArrayView:self
                                viewForObject:object];
    
    // Also ask delegate to configure it?
    if (view && [delegate respondsToSelector:@selector(objectArrayView:configureView:withObject:)])
    {
        [delegate objectArrayView:self
                    configureView:view
                       withObject:object];
    }
    // Configure it if it's an ObjectView
    else if ([view isKindOfClass:[ObjectView class]])
    {
        ((ObjectView *)view).object = object;
    }
    
    return view;
}

- (void)adjustViewSize:(UIView *)view
{
    // Resize to target size?
    if (!CGSizeEqualToSize(_targetObjectViewSize, CGSizeZero))
    {
        view.frame = CGRectMake(view.frame.origin.x,
                                view.frame.origin.x,
                                _targetObjectViewSize.width,
                                _targetObjectViewSize.height);
    }
    
    // SizeToFit it?
    if (self.sizeToFitObjectViews)
    {
        [view sizeToFit];
    }
    
    // Make sure it's not wider than bounds!
    if (view.frame.size.width + (2 * _margin.width) > self.bounds.size.width)
    {
        view.frame = CGRectMake(view.frame.origin.x,
                                view.frame.origin.x,
                                self.bounds.size.width - (2 * _margin.width),
                                view.frame.size.height);
    }
}

@end

