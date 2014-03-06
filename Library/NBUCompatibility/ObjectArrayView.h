//
//  ObjectArrayView.h
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

#import "ObjectView.h"

@protocol ObjectArrayViewDelegate;

/**
 Abstract class to display an array of objects.
 
 An ObjectArrayView displays objects of its objectArray creating corresponding views with its
 viewForObject: method.
 
 It can contain a mix of different kind of objects (CoreData objects, NSObjects, UIImages, UIViews, etc.)
 while trying to choose the best strategy to display each of them.
 
 Each object of the objectArray is presented thorugh the method viewForObject:, unless an
 ObjectArrayViewDelegate is used to create and/or configure views. The delegate is required to provide
 "load more objects" support.
 
 @note As it is an abstract class use on of the subclasses: ObjectGridView, ObjectTableView or ObjectSlideView.
 */
@interface ObjectArrayView : ObjectView

/// @name Managing the Array of Objects

/// The associated array of objects.
@property (strong, nonatomic, setter=setObject:, getter=object) NSArray * objectArray;

/// Add a new object.
/// @discussion The view layout will be automatically adjusted.
/// @param object The new object.
- (void)addObject:(id)object;

/// Add a new object if not already present.
/// @param object The new object.
/// @note Duplicated objects risk to share a single UIView representation resulting in empty spaces in the ObjectArrayView.
- (void)addObjectIfNotPresent:(id)object;

/// Delete an object from the objectArray.
/// @param object The object to delete.
- (void)removeObject:(id)object;

/// Insert an object to the objectArray at the given index.
/// @param object The object to insert.
/// @param index The index to where the object should be inserted.
- (void)insertObject:(id)object
             atIndex:(NSUInteger)index;

/// Insert an object to the objectArray at the given index.
/// @param index The index corresponding to the object to remove.
- (void)removeObjectAtIndex:(NSUInteger)index;

/// Replace an object of the objectArray at a given index by a new one.
/// @param index The index corresponding to the object to replace.
/// @param object The new object.
- (void)replaceObjectAtIndex:(NSUInteger)index
                  withObject:(id)object;

/// @name Show/Hide Objects' Views

/// Objects whose views should be hidden.
/// @discussion By default no objects are hidden.
@property (strong, nonatomic, readonly)     NSArray * hiddenObjects;

/// Hide/Show an object's corresponding view.
/// @param object The object whose view should be hidden/shown.
/// @param yesOrNo Whether to hide or not the corresponding view.
- (void)setObject:(id)object
           hidden:(BOOL)yesOrNo;

/// Hide/Show an object's corresponding view.
/// @param index The index of the object whose view should be hidden/shown.
/// @param yesOrNo Whether to hide or not the corresponding view.
- (void)setObjectAtIndex:(NSUInteger)index
                  hidden:(BOOL)yesOrNo;

/// @name Managing Objects' Views

/// A delegate to help load, configure and/or provide "load more objects" support.
@property (nonatomic, weak)IBOutlet         id<ObjectArrayViewDelegate> delegate;

/// When set, a delegate is no longer needed to create views.
@property (nonatomic, strong)               NSString * nibNameForViews;

/// @name "More objects" Support

/// A boolean indicating whether or not there are more objects to load.
@property (nonatomic, readonly)             BOOL hasMoreObjects;

/// A view shown when there are unloaded objects.
@property (strong, nonatomic) IBOutlet      UIView * loadMoreView;

/// Whether or not to place the loadMoreView on top.
@property (nonatomic)                       BOOL loadMoreViewOnTop;

/// Trigger loading more objects.
/// @param sender The sender object.
- (IBAction)loadMoreObjects:(id)sender;

/// @name Objects' View Setup

/// Populate the objectArray with the objectArrayView subviews.
/// @discussion You would normally call this method after loading the ObjectArrayView from a Nib by
/// overriding awakeFromNib, UIView's initWithCoder, or UIViewController's viewDidLoad methods.
- (void)populateObjectArrayWithSubviews;

/// Create a view corresponding to a given object.
/// @param object An objectArray object.
- (UIView *)viewForObject:(id)object;

/// Resize a given view to the size that best fits it if sizeToFitObjectViews is set.
/// @param view The view to be adjusted.
- (void)adjustViewSize:(UIView *)view;

/// Ask objectViews to adjust their size. Default NO.
@property (nonatomic)                       BOOL sizeToFitObjectViews;

/// Size to be applied to views. A CGSizeZero size means no resize.
@property (nonatomic)                       CGSize targetObjectViewSize;

/// The margin to separate vies from each other. Default no margin.
@property (nonatomic)                       CGSize margin;               // Desired margin in-between views. Default CGSizeZero

@end


/**
 Provides objects' views when required by the delegating ObjectArrayView.
 
 ObjectArrayViewDelegate can be used to create and/or configure views.
 
 @note The delegate is required to provide "load more objects" support.
 */
@protocol ObjectArrayViewDelegate <NSObject>

@optional

/// Provide a new not configured view for a given object.
/// @param arrayView The delegating ObjectArrayView.
/// @param object An objectArray object.
/// @note Do not configure the view here but instead implement the objectArrayView:configureView:withObject:.
- (UIView *)objectArrayView:(ObjectArrayView *)arrayView
              viewForObject:(id)object;

/// Configure an existing view for an object.
/// @param arrayView The delegating ObjectArrayView.
/// @param recycledView The view to be configured.
/// @param object An objectArray object.
/// @note If all you want to do is set the object parameter of a ObjectView you don't need to implement this function.
/// @note Make sure to reset all UI elements.
- (void)objectArrayView:(ObjectArrayView *)arrayView
          configureView:(UIView *)recycledView
             withObject:(id)object;

/// @name Provide "Load More Objects" Support

/// Check if additional objects are available.
/// @param arrayView The delegating ObjectArrayView.
- (BOOL)objectArrayViewHasMoreObjects:(ObjectArrayView *)arrayView;

/// Load more objects
/// @param arrayView The delegating ObjectArrayView.
- (void)objectArrayViewLoadMoreObjects:(ObjectArrayView *)arrayView;

@end

