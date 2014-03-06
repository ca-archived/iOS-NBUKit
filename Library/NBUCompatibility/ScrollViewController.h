//
//  ScrollViewController.h
//  NBUCompatibility
//
//  Created by Ernesto Rivera on 2012/02/07.
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

#import "NBUViewController.h"

// Notification observed to trigger/cancel image load
extern NSString * const ScrollViewContentOffsetChangedNotification;
extern NSString * const ScrollViewDidScrollNotification;
extern NSString * const ScrollViewEndScrollNotification;

/**
 Base UIViewController with many convenience methods.

 - Manage UIScrollView contentSize on viewWillAppear.
 - Create a UIScrollView if necessary.
 - Automatically SizeToFit contentView.
 - Manage hiding the keyboard.
 - Autohide prompt messages.
 - Hide/show UINavigationBar and UITabBar on scroll.
 - Customize buck button titles.
 
 @note Can be initialized from a Nib file or programatically.
 */
@interface ScrollViewController : NBUViewController <UIScrollViewDelegate>

/// @name Outlets

/// Managed UIScrollView (may be the controller's view or a subview of that view).
@property (nonatomic, strong) IBOutlet  UIScrollView * scrollView;

/// The view that is used to adjust the scrollview contentSize.
/// @discussion If not set it will be scrollview's first subview.
@property (nonatomic, strong) IBOutlet  UIView * contentView;

/// @name Configurable Properties

/// A boolean that indicates whether the controller should animate its contentView. Default `NO`.
@property (nonatomic, getter=isAnimated) BOOL animated;

/// The currently active field.
@property (nonatomic, strong, readonly) UIView * activeField;

/// Empty or nil string will force to use the system default back button.
@property (nonatomic, strong)           NSString * customBackButtonTitle;

/// Whether to hide or not navigation and tab bars on scroll. Default `NO`.
@property (nonatomic)                   BOOL hidesBarsOnScroll;

/// @name Managing the Prompt

/// Display a short message over the UINavigationBar
/// @param prompt The NSString to be shown.
/// @param yesOrNo Whether to clear the prompt automatically after 3 seconds
- (void)setPrompt:(NSString *)prompt
        autoClear:(BOOL)yesOrNo;

/// Force to clear the prompt immediatly
- (void)clearPrompt;

/// @name Methods/Actions

/// Set a custom back button title for all ScrollViewController and subclasses instances.
/// @param title The custom title to be used.
/// @note Can be overriden per instance by setting the customBackButtonTitle to an empty string.
+ (void)setCustomBackButtonTitle:(NSString *)title;

/// Notify listeners (usually ImageLoadingView subviews) that the scrollView offset has changed
- (void)postScrollViewContentOffsetChangedNotification;

- (void)postScrollVieEndNotification;

/// Adjust contentView's size and scrollview's contentsize.
/// @param sender The sender object.
- (IBAction)sizeToFitContentView:(id)sender;

/// Force to hide the keyboard.
/// @param sender The sender object.
/// @note In most cases the controller will hide it automatically
- (IBAction)hideKeyboard:(id)sender;

- (void)keyboardWillShow:(NSNotification*)notification;
- (void)keyboardDidHide:(NSNotification*)notification;

/// Scroll scrollView to make view visible.
/// @param view The view to be scrolled to visible.
/// @param topMargin The space to be left above the view.
/// @param bottomMargin The space to be left below the view.
/// @note ActiveView instances can easily use the [ActiveView postScrollToVisibleNotification] to achieve the same result.
- (void)scrollViewToVisible:(UIView *)view
                  topMargin:(CGFloat)topMargin
               bottomMargin:(CGFloat)bottomMargin;

@end

