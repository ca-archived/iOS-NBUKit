//
//  NBURefreshControl.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/09/11.
//  Copyright (c) 2012 CyberAgent Inc.
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

@synthesize heightToRefresh = _heightToRefresh;
@synthesize status = _status;
@synthesize visible = _visible;
@synthesize lastUpdateDate = _lastUpdateDate;
@synthesize dateFormatter = _dateFormatter;
@synthesize scrollView = _scrollView;
@synthesize statusLabel = _statusLabel;
@synthesize lastUpdateLabel = _lastUpdateLabel;
@synthesize idleView = _idleView;
@synthesize loadingView = _loadingView;

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    // Save original height as the heightToRefresh and make the view taller
    CGRect bounds = self.bounds;
    _heightToRefresh = bounds.size.height;
    bounds.size.height += 320;
    self.bounds = bounds;
}

- (void)setStatusLabel:(UILabel *)statusLabel
{
    _statusLabel = statusLabel;
    
    // Set initial status
    self.status = _status;
}

- (void)setLastUpdateLabel:(UILabel *)lastUpdateLabel
{
    _lastUpdateLabel = lastUpdateLabel;
    
    // Set last update time
    self.lastUpdateDate = _lastUpdateDate;
}

- (void)setScrollView:(UIScrollView *)scrollView
{
    if (_scrollView == scrollView)
        return;
    
    _scrollView = scrollView;

    // Adjust frame
    [self adjustFrame];
    
    // Add to scrollview if needed
    if (self.superview != scrollView)
    {
        [scrollView addSubview:self];
    }
}

#pragma mark - Key-value observing

- (void)willMoveToSuperview:(UIView *)superview
{
    [super willMoveToSuperview:superview];
    
    // Stop KVO
    [self.superview removeObserver:self
                        forKeyPath:@"contentOffset"];
    [self.superview removeObserver:self
                        forKeyPath:@"contentSize"];
    [self.superview removeObserver:self
                        forKeyPath:@"bounds"];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    // Start KVO
    [self.superview addObserver:self
                     forKeyPath:@"contentOffset"
                        options:NSKeyValueObservingOptionOld
                        context:nil];
    [self.superview addObserver:self
                     forKeyPath:@"contentSize"
                        options:0
                        context:nil];
    [self.superview addObserver:self
                     forKeyPath:@"bounds"
                        options:0
                        context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    // Offset changed
    if ([keyPath isEqualToString:@"contentOffset"])
    {
        CGPoint oldOffset = [(NSValue *)change[NSKeyValueChangeOldKey] CGPointValue];
        
        // No changes? Do nothing
        if (_scrollView.contentOffset.y == oldOffset.y)
            return;
        
        // Enough to refresh?
        if (_scrollView.contentOffset.y < -_heightToRefresh)
        {
            self.visible = YES;
            
            // Send action
            if (_status != NBURefreshStatusLoading)
            {
                [NSObject cancelPreviousPerformRequestsWithTarget:self];
                
                NBULogVerbose(@"Pulled to refresh");
                
                self.status = NBURefreshStatusLoading;
                [self sendActionsForControlEvents:UIControlEventValueChanged];
            }
        }
    }
    
    // Bounds or content size changed
    else
    {
        [self adjustFrame];
    }
}

- (void)adjustFrame
{
    self.frame = CGRectMake(0.0,
                            0.0 - self.size.height,
                            MAX(_scrollView.contentSize.width, _scrollView.bounds.size.width),
                            self.size.height);
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
    NBULogVerbose(@"setStatus: %d withMessage: %@", status, message);
    
    _status = status;
    
    switch (_status)
    {
        case NBURefreshStatusIdle:
        {
            self.statusLabel.text = message ? message : NSLocalizedStringWithDefaultValue(@"NBURefreshControl Drag to refresh",
                                                                                          nil, nil,
                                                                                          @"Drag to refresh",
                                                                                          @"NBURefreshControl Drag to refresh");
            _idleView.hidden = NO;
            _loadingView.hidden = YES;
            break;
        }
        case NBURefreshStatusLoading:
        {
            self.statusLabel.text = message ? message : NSLocalizedStringWithDefaultValue(@"NBURefreshControl Reloading",
                                                                                          nil, nil,
                                                                                          @"Reloading...",
                                                                                          @"NBURefreshControl Reloading");
            _idleView.hidden = YES;
            _loadingView.hidden = NO;
            break;
        }
        case NBURefreshStatusUpdated:
        {
            self.statusLabel.text = message ? message : NSLocalizedStringWithDefaultValue(@"NBURefreshControl Updated",
                                                                                          nil, nil,
                                                                                          @"Updated",
                                                                                          @"NBURefreshControl Updated");
            self.lastUpdateDate = [NSDate date];
            _idleView.hidden = YES;
            _loadingView.hidden = YES;
            [self hideAfterDelay:1.5];
            break;
        }
        default:
        {
            _status = NBURefreshStatusError;
            self.statusLabel.text = message ? message : NSLocalizedStringWithDefaultValue(@"NBURefreshControl Error",
                                                                                          nil, nil,
                                                                                          @"Update error",
                                                                                          @"NBURefreshControl Error");
            _idleView.hidden = YES;
            _loadingView.hidden = YES;
            [self hideAfterDelay:2.0];
            break;
        }
    }
}

- (void)setVisible:(BOOL)visible
{
    if (_visible == visible ||
        !self.superview)
    {
        return;
    }
    
    _visible = visible;
    
    NBULogVerbose(@"setVisible: %@", NSStringFromBOOL(visible));
    
    // Make visible
    if (visible)
    {
        _scrollView.contentInset = UIEdgeInsetsMake(_heightToRefresh,
                                                    _scrollView.contentInset.left,
                                                    _scrollView.contentInset.bottom,
                                                    _scrollView.contentInset.right);
    }
    // Displace
    else
    {
        self.status = NBURefreshStatusIdle;
        _scrollView.contentInset = UIEdgeInsetsMake(0.0,
                                                    _scrollView.contentInset.left,
                                                    _scrollView.contentInset.bottom,
                                                    _scrollView.contentInset.right);
    }
}

- (void)setLastUpdateDate:(NSDate *)lastUpdateDate
{
    _lastUpdateDate = lastUpdateDate;
    if (lastUpdateDate)
    {
        _lastUpdateLabel.text = [NSString stringWithFormat:NSLocalizedStringWithDefaultValue(@"NBURefreshControl last updated",
                                                                                             nil, nil,
                                                                                             @"Last updated %@",
                                                                                             @"NBURefreshControl last updated"),
                                 [self.dateFormatter stringFromDate:lastUpdateDate]];
    }
    else
    {
        _lastUpdateLabel.text = NSLocalizedStringWithDefaultValue(@"NBURefreshControl last update unknown",
                                                                  nil, nil,
                                                                  @"Last update date unknown",
                                                                  @"NBURefreshControl last update unknown");
    }
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

- (void)show:(id)sender
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    NBULogTrace();
    NBULogVerbose(@"subviews %@", _scrollView.subviews);
    
    self.visible = YES;
    [_scrollView setContentOffset:CGPointMake(_scrollView.contentOffset.x,
                                              -_scrollView.contentInset.top)
                         animated:YES];
}

- (void)hide:(id)sender
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if (!_visible)
        return;
    
    NBULogTrace();
    
    [UIView animateWithDuration:0.3
                     animations:^{ self.visible = NO; }];
}

- (void)hideAfterDelay:(NSTimeInterval)delay
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if (!_visible)
        return;
    
    NBULogTrace();
    
    [self performSelector:@selector(hide:)
               withObject:self
               afterDelay:delay];
}

- (void)updated:(id)sender
{
    NBULogTrace();
    
    self.status = NBURefreshStatusUpdated;
}

- (void)failedToUpdate:(id)sender
{
    NBULogTrace();
    
    self.status = NBURefreshStatusError;
}

@end

