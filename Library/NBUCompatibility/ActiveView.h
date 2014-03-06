//
//  ActiveView.h
//  NBUCompatibility
//
//  Created by Ernesto Rivera on 2012/03/05.
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

#import "NBUView.h"

/// @name Notifications

/// Notification that is posted when the view's preferred size changes
extern NSString * const SizeThatFitsChangedNotification;
extern NSString * const ScrollToVisibleNotification;

/// Gesture notifications.
extern NSString * const ActiveViewTappedNotification;
extern NSString * const ActiveViewDoubledTappedNotification;
extern NSString * const ActiveViewSwipedNotification;

/**
 Superclass of most NBUBase views (i.e. ObjectView, ObjectArrayView).
 
 Provides:
 
 - Dynamic resizing.
 - Send SizeThatFitsChangedNotification notifications when its size needs to be adjusted.
 - A noContentsView placeholder shown automatically when the view is empty.
 - Simple tap and swipe recognition with recognizeTap and recognizeSwipe parameters.
 
 @note Some ActiveView subclasses are designed to be initialized from Nib files.
 */
@interface ActiveView : NBUView <UIGestureRecognizerDelegate>

/// @name Outlets

/// These subviews used to calculate the view's sizeThatFits
/// @note It is recommended to use only one subview
@property (strong, nonatomic) IBOutletCollection(UIView) NSMutableArray * dynamicHeightSubviews;

/// Subview to be shown/hidden automatically when empty
@property (strong, nonatomic) IBOutlet              UIView * noContentsView;

- (void)setNoContentsViewText:(NSString *)text;

/// @name Properties

/// A boolean to indicated whether the view is "empty" or not
/// When empty noContentsView will be automatically shown
@property (nonatomic, getter=isEmpty)             BOOL empty;

/// The view's original size as loaded from its Nib file.
/// @discussion This is the minimum size that to be returned by the view for sizeThatFits:.
@property (nonatomic, readonly)                     CGSize originalSize;

/// A boolean that indicates whether the view should animate its changes.
/// The default value is NO.
@property (nonatomic, getter=isAnimated)          BOOL animated;

/// A boolean to indicate whether the view should recognize single taps.
/// When set to YES a UITapGestureRecognizer that triggers the tapped: method will be set up.
/// The default value is NO.
@property (nonatomic)                               BOOL recognizeTap;

/// A boolean to indicate whether the view should recognize double taps.
/// When set to YES a UITapGestureRecognizer that triggers the doubleTapped: method will be set up.
/// The default value is NO.
@property (nonatomic)                               BOOL recognizeDoubleTap;

/// A boolean to indicate whether the view should recognize swipes.
/// When set to YES a UISwipeGestureRecognizer that triggers the swiped: method will be set up.
/// The default value is NO.
@property (nonatomic)                               BOOL recognizeSwipe;

/// A boolean to indicate whether the view should intercept touches made to its subviews.
/// The default value is NO.
@property (nonatomic)                               BOOL receiveSubviewTouches;

/// @name Highlight Mask

/// A boolean to indicate whether the view should not be highlighted when tapped.
/// The default value is NO.
@property (nonatomic)                               BOOL doNotHighlightOnTap;

/// The mask's highlight color. Default Black 30% opaque.
@property (nonatomic, strong)                       UIColor * highlightColor;

/// The mask's corner radious. Default 4.0
@property (nonatomic)                               CGFloat highlightCornerRadius;

/// Show the highlight mask.
- (void)showHighlightMask;

/// Hide the highlight mask.
- (void)hideHighlightMask;

/// Briefly show the highlight mask.
- (void)flashHighlightMask;

/// @name Methods/Actions

/// Called when recognizeTap is enabled.
/// @discussion Subclasses should override this method and call super at the beginning.
/// @param sender Will usually an internal UITapGestureRecognizer.
- (IBAction)tapped:(id)sender;

/// Called when recognizeDoubleTap is enabled.
/// @discussion Subclasses should override this method and call super at the beginning.
/// @param sender Will usually an internal UITapGestureRecognizer.
- (IBAction)doubleTapped:(id)sender;

/// Called when swipes are enabled.
/// @discussion By default a white mask and a delete button will be shown.
/// Subclasses should override this method and call super at the beginning if needed.
/// @param sender Will usually an internal UIGestureRecognizer.
- (IBAction)swiped:(id)sender;

/// Send notification asking trigger view's resize.
/// @discussion Observers (usually a ScrollViewController) should trigger sizeToFit messsages.
- (void)postSizeThatFitsChangedNotification;

/// Send notification asking to scroll to make this view visible.
/// @discussion Observers (usually a ScrollViewController) should scroll to this view.
- (void)postScrollToVisibleNotification;

@end

/**
 A UILabelView that keeps its original size to better respond to the sizeThatFits: message.
 
 @note ActiveLabel and its subclasses are designed to be initialized from Nib files.
 */
@interface ActiveLabel : UILabel

/// The view's original size as loaded from its Nib file.
/// @discussion This is the minimum size that to be returned by the view for sizeThatFits:.
@property (nonatomic, readonly)                     CGSize originalSize;

/// The maximum size that this view should get
/// @discussion The default value is (CGFLOAT_MAX, CGFLOAT_MAX).
@property (nonatomic)                               CGSize maxSize;

@end



