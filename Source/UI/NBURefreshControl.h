//
//  NBURefreshControl.h
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/09/11.
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

/**
 @enum NBURefreshStatus
 @abstract Possible refresh statuses.
 */
typedef NS_ENUM(NSInteger, NBURefreshStatus)
{
    NBURefreshStatusIdle                = 0,
    NBURefreshStatusReleaseToRefresh    = 1,
    NBURefreshStatusLoading             = 2,
    NBURefreshStatusUpdated             = 3,
    NBURefreshStatusError               = -1,
};


/**
 A fully configurable pull-to-refresh UIControl.
 
 It gets added below the target scrollView to avoid appearing behind iOS 7's
 translucent navigation bars.
 To configure it, simply set its target scroll view.
 */
@interface NBURefreshControl : UIControl

/// @name Creating the Control

/// Load a new control and configure its target and action for the `UIControlEventValueChanged` event.
/// @param scrollView The view to which the control will be associated.
/// @param nibName An optional Nib or `nil` to load the default Nib.
/// @param target The target object.
/// @param action A selector identifying an action message.
+ (instancetype)controlForScrollView:(UIScrollView *)scrollView
                             fromNib:(NSString *)nibName
                          withTarget:(id)target
                              action:(SEL)action;

/// @name Properties

/// The necessary height to drag to trigger a refresh. By default this view's height.
@property (nonatomic)                   CGFloat heightToRefresh;

/// The current NBURefreshStatus.
/// @note Modifying the status modifies the view's UI.
@property (nonatomic)                   NBURefreshStatus status;

/// Whether or not the control should be visible in the UIScrollView.
/// @note Doesn't trigger any status change.
@property (nonatomic, getter=isVisible) BOOL visible;

/// The last updated NSDate.
/// @discussion Usually set automatically to the current date then status is modified to
/// NBURefreshStatusUpdated or updated: is called.
@property (strong, nonatomic)           NSDate * lastUpdateDate;

/// The NSDateFormatter to be used to display the lastUpdateDate.
@property (strong, nonatomic)           NSDateFormatter * dateFormatter;

/// @name Outlets

/// The UIScrollView to which the control should be attached.
@property (weak, nonatomic) IBOutlet    UIScrollView * scrollView;

/// A configurable UILabel.
@property (weak, nonatomic) IBOutlet    UILabel * statusLabel;

/// A label to show the lastUpdateDate.
@property (weak, nonatomic) IBOutlet    UILabel * lastUpdateLabel;

/// A view shown/hidden on status changes to/from NBURefreshStatusIdle.
@property (weak, nonatomic) IBOutlet    UIView * idleView;

/// A view shown/hidden on status changes to/from NBURefreshStatusLoading.
@property (weak, nonatomic) IBOutlet    UIView * loadingView;

/// @name Methods

/// Sets the status and customize the statusLabel message.
/// @param status A NBURefreshStatus.
/// @param message A custom message. Use 'nil' for default messages.
- (void)setStatus:(NBURefreshStatus)status
      withMessage:(NSString *)message;

/// @name Actions

/// Make the control visible animated without changing it's status.
/// @param sender The sender object.
- (IBAction)show:(id)sender;

/// Hide the control animated without changing it's status.
/// @param sender The sender object.
- (IBAction)hide:(id)sender;

@end

