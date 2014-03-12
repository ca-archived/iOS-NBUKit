//
//  NBUBadgeSegmentedControl.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/04/20.
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

#import "NBUBadgeSegmentedControl.h"
#import "NBUKitPrivate.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_UI

@implementation NBUBadgeSegmentedControl
{
    NSMutableArray * _badges;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithItems:(NSArray *)items
{
    self = [super initWithItems:items];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _badges = [NSMutableArray array];
    NBUBadgeView * badge;
    for (NSUInteger i = 0; i < self.numberOfSegments; i++)
    {
        badge = [NSBundle loadNibNamed:@"NBUBadgeView"
                                 owner:nil
                               options:nil][0];
        badge.value = nil;
        [_badges addObject:badge];
    }
}

- (void)setBadge:(NSString *)badge
forSegmentAtIndex:(NSUInteger)index
{
    if (index >= self.numberOfSegments)
    {
        NBULogError(@"Tried to set a badge for segment %@ in control with only %@ segments",
                    @(index),
                    @(self.numberOfSegments));
        return;
    }
    
    // Configure
    NBUBadgeView * badgeView = _badges[index];
    badgeView.value = badge;
    
    // If empty we finished
    if (badgeView.isEmpty)
        return;
    
    // Place it
    CGRect frame = badgeView.frame;
    frame.origin = self.origin;
    frame.origin.x += (self.size.width / self.numberOfSegments) * (index + 1);          // Just outside
    frame.origin.x -= badgeView.size.width - 8.0;                                       // Pull it in
    frame.origin.x -= MAX(0.0,
                          CGRectGetMaxX(frame) - CGRectGetMaxX(self.superview.bounds)); // Not too much to the right!
    frame.origin.y -= 10.0;                                                             // Just on top
    frame.origin.y = MAX(2.0,
                         frame.origin.y);                                               // Not too high!
    badgeView.frame = frame;
    
    [self.superview addSubview:badgeView];
}

- (NSString *)getBadgeForIndex:(NSUInteger)index
{
    if (_badges.count <= index)
    {
        return nil;
    }
    
    NBUBadgeView * badgeView = _badges[index];
    
    return badgeView.value;
}

@end

