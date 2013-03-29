//
//  NBURefreshControl.h
//  NBUKit
//
//  Created by 利辺羅 on 2012/09/11.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//


/**
 @enum NBURefreshStatus
 @abstract Possible refresh statuses.
 */
enum
{
    NBURefreshStatusIdle                = 0,
    NBURefreshStatusLoading             = 1,
    NBURefreshStatusUpdated             = 2,
    NBURefreshStatusError               = -1,
};
typedef NSInteger NBURefreshStatus;

/**
 A fully configurable pull to refresh UIControl.
 
 To configure it, simply set its target from a Nib or programatically.
 */
@interface NBURefreshControl : UIControl

/// @name Properties

/// The necessary height to drag to trigger a refresh. By default this view's height.
@property (nonatomic)                   CGFloat heightToRefresh;

/// The current NBURefreshStatus.
/// @note Modifying the status modifies the view's UI.
@property (nonatomic)                   NBURefreshStatus status;

/// Whether or not the control should be visible in the UIScrollView;
@property (nonatomic, getter=isVisible) BOOL visible;

/// The last updated NSDate.
///
/// Usually set automatically to the current date then status is modified to
/// NBURefreshStatusUpdated or updated: is called.
@property (strong, nonatomic)           NSDate * lastUpdateDate;

/// The NSDateFormatter to be used to display the lastUpdateDate.
@property (strong, nonatomic)           NSDateFormatter * dateFormatter;

/// @name Outlets

/// The UIScrollView to which the control should be attached.
@property (assign, nonatomic) IBOutlet  UIScrollView * scrollView;

/// A configurable UILabel.
@property (strong, nonatomic) IBOutlet  UILabel * statusLabel;

/// A label to show the lastUpdateDate.
@property (strong, nonatomic) IBOutlet  UILabel * lastUpdateLabel;

/// A view shown/hidden on status changes to/from NBURefreshStatusIdle.
@property (strong, nonatomic) IBOutlet  UIView * idleView;

/// A view shown/hidden on status changes to/from NBURefreshStatusLoading.
@property (strong, nonatomic) IBOutlet  UIView * loadingView;

/// @name Methods

/// Sets the status and customize the statusLabel message.
/// @param status A NBURefreshStatus.
/// @param message A custom message. Use 'nil' for default messages.
- (void)setStatus:(NBURefreshStatus)status
      withMessage:(NSString *)message;

/// @name Actions

/// Make the control visible, scroll to it and trigger a refresh.
/// @param sender The sender object.
- (IBAction)show:(id)sender;

/// Hide the control.
/// @param sender The sender object.
- (IBAction)hide:(id)sender;

/// Set the control status as NBURefreshStatusUpdated.
/// @param sender The sender object.
- (IBAction)updated:(id)sender;

/// Set the control status as NBURefreshStatusError.
/// @param sender The sender object.
- (IBAction)failedToUpdate:(id)sender;

@end

