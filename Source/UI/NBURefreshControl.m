//
//  NBURefreshControl.m
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

#import "NBURefreshControl.h"
#import "NBUKitPrivate.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_UI

@implementation NBURefreshControl

+ (instancetype)controlForScrollView:(UIScrollView *)scrollView
                             fromNib:(NSString *)nibName
                          withTarget:(id)target
                              action:(SEL)action
{
    NBURefreshControl * control = [NSBundle loadNibNamed:nibName ? nibName : NSStringFromClass(self)
                                                   owner:nil
                                                 options:nil][0];
    control.scrollView = scrollView;
    [control addTarget:target
                action:action
      forControlEvents:UIControlEventValueChanged];
    
    if (target && ![target respondsToSelector:action])
    {
        NBULogWarn(@"Target '%@' does not respond to selector '%@'.", target, NSStringFromSelector(action));
    }
    
    return control;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Save original height as the heightToRefresh as the view will be stretched later
    CGRect bounds = self.bounds;
    self.heightToRefresh = bounds.size.height;
    
    // Set initial status
    self.status = NBURefreshStatusIdle;
    self.lastUpdateDate = nil;
}

- (void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    
    // Make sure we have a proper superview
    if (!scrollView.superview)
    {
        NBULogError(@"%@ The scrollView should have a valid superview.", THIS_METHOD);
        return;
    }
    
    // Make sure the scrollView is transparent!
    CGFloat alpha = CGColorGetAlpha(scrollView.backgroundColor.CGColor);
    if (alpha != 0.0)
    {
        NBULogWarn(@"%@ The scrollView should have a clear color background.", THIS_METHOD);
    }
    
    // Make sure the scrollView always bounces vertically
    scrollView.alwaysBounceVertical = YES;

    // Add to scrollview's superview if needed
    [scrollView.superview insertSubview:self
                           belowSubview:scrollView];
    
    // Start KVO
    [scrollView addObserver:self
                 forKeyPath:@"contentOffset"
                    options:NSKeyValueObservingOptionOld
                    context:nil];
    [scrollView addObserver:self
                 forKeyPath:@"contentInset"
                    options:0
                    context:nil];
}

- (void)dealloc
{
    // Stop KVO
    [self.scrollView removeObserver:self
                         forKeyPath:@"contentOffset"];
    [self.scrollView removeObserver:self
                         forKeyPath:@"contentInset"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    NBULogVerbose(@"frame: %@ bounds: %@", NSStringFromCGRect(self.scrollView.frame), NSStringFromCGRect(self.scrollView.bounds));
    
    // Offset changed
    if ([keyPath isEqualToString:@"contentOffset"])
    {
        // Ignore if visible
        if (self.visible)
            return;
        
        // Ignore if not NBURefreshStatusReleaseToRefresh and not being dragged
        if (self.status != NBURefreshStatusReleaseToRefresh && !self.scrollView.isDragging)
            return;
        
        // Start idle
        NBURefreshStatus status = NBURefreshStatusIdle;
        
        // Dragged enough to refresh?
        if (self.scrollView.contentOffset.y <= -self.heightToRefresh - self.scrollView.contentInset.top)
        {
            // But still dragging?
            if (self.scrollView.isDragging)
            {
                status = NBURefreshStatusReleaseToRefresh;
            }
            // Go!
            else
            {
                NBULogVerbose(@"Pulled to refresh");
                status = NBURefreshStatusLoading;
            }
        }
        
        // Update status
        if (self.status != status)
            self.status = status;
    }
    
    // Insets changed
    else
    {
        // Refresh layout
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews
{
    // Ignore when we are visible
    if (self.visible)
        return;
    
    // Position below scrollview's contents
    UIEdgeInsets insets = self.scrollView.contentInset;
    CGRect frame = self.scrollView.frame;
    frame.origin.y += insets.top;
    
    // Strech it but not too much
    frame.size.height = MIN((frame.size.height - frame.origin.y) / 2.0, // Half the scrollview's height
                            self.scrollView.contentSize.height / 2.0);  // ...or half the content's height
    
    // Not too short!
    frame.size.height = MAX(frame.size.height,
                            self.heightToRefresh);
    
    NBULogVerbose(@"%@ -> %@", THIS_METHOD, NSStringFromCGRect(frame));
    
    self.frame = frame;
}

#pragma mark - Status

- (void)setStatus:(NBURefreshStatus)status
{
    [self setStatus:status
        withMessage:nil];
}

- (void)setStatus:(NBURefreshStatus)status
      withMessage:(NSString *)message
{
    NBULogDebug(@"setStatus: %@ withMessage: %@", @(status), message);
    
    _status = status;
    
    // Cancel any timed requests
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    // Update
    switch (_status)
    {
        case NBURefreshStatusIdle:
        {
            self.statusLabel.text = message ? message : NBULocalizedString(@"NBURefreshControl Drag to refresh", @"Pull to refresh");
            break;
        }
        case NBURefreshStatusReleaseToRefresh:
        {
            self.statusLabel.text = message ? message : NBULocalizedString(@"NBURefreshControl Release to refresh", @"Release to refresh");
            break;
        }
        case NBURefreshStatusLoading:
        {
            self.statusLabel.text = message ? message : NBULocalizedString(@"NBURefreshControl Reloading", @"Reloading...");
            [self show:self];
            
            // Send actions
            [self sendActionsForControlEvents:UIControlEventValueChanged];
            break;
        }
        case NBURefreshStatusUpdated:
        {
            self.statusLabel.text = message ? message : NBULocalizedString(@"NBURefreshControl Updated", @"Updated");
            self.lastUpdateDate = [NSDate date];
            [self hideAfterDelay:1.5];
            break;
        }
        default:
        {
            _status = NBURefreshStatusError;
            self.statusLabel.text = message ? message : NBULocalizedString(@"NBURefreshControl Error", @"Update error");
            [self hideAfterDelay:2.0];
            break;
        }
    }
    self.idleView.hidden = status != NBURefreshStatusIdle && status != NBURefreshStatusReleaseToRefresh;
    self.loadingView.hidden = status != NBURefreshStatusLoading;
}

- (void)setVisible:(BOOL)visible
{
    if (_visible == visible)
        return;
    
    // Cancel pending calls
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    _visible = visible;
    
    NBULogVerbose(@"setVisible: %@", NBUStringFromBOOL(visible));
    
    if (visible)
    {
        UIEdgeInsets insets = self.scrollView.contentInset;
        insets.top += self.heightToRefresh;
        self.scrollView.contentInset = insets;
    }
    else
    {
        [self.scrollView autoAdjustInsets];
        // TODO: Adjust scroll offset when user slided already scrolled
    }
}

- (void)setLastUpdateDate:(NSDate *)lastUpdateDate
{
    _lastUpdateDate = lastUpdateDate;
    
    if (!self.lastUpdateLabel)
        return;
    
    self.lastUpdateLabel.text = (lastUpdateDate ?
                                 [NSString stringWithFormat:NBULocalizedString(@"NBURefreshControl last updated", @"Last updated %@"),
                                  [self.dateFormatter stringFromDate:lastUpdateDate]] :
                                 NBULocalizedString(@"NBURefreshControl last update unknown", @"Last update date unknown"));
}

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter)
    {
        _dateFormatter = [NSDateFormatter new];
        _dateFormatter.dateStyle = NSDateFormatterShortStyle;
        _dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    }
    return _dateFormatter;
}

#pragma mark - Actions/Methods

- (IBAction)show:(id)sender
{
    [UIView animateWithDuration:0.15
                     animations:^
     {
         self.visible = YES;
     }];
}

- (IBAction)hide:(id)sender
{
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^
     {
         self.visible = NO;
     }
                     completion:NULL];
}

- (void)hideAfterDelay:(NSTimeInterval)delay
{
    if (!self.visible)
        return;
    
    NBULogTrace();
    
    [self performSelector:@selector(hide:)
               withObject:self
               afterDelay:delay];
}

@end

