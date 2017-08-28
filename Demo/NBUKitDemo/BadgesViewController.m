//
//  BadgesViewController.m
//  NBUKitDemo
//
//  Created by Ernesto Rivera on 2012/10/12.
//  Copyright (c) 2012-2017 CyberAgent Inc.
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

#import "BadgesViewController.h"

@implementation BadgesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Programatic badge
    NBUBadgeView * badge = [NBUBadgeView badge];
    badge.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    badge.origin = CGPointMake(10.0, 100.0);
    badge.value = @"Programatic badge";
    [self.view addSubview:badge];
    
    // Nib badge
    _badgeView.value = @"From Nib";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Segmented control
    [self badgeTapped:self];
}

- (IBAction)badgeTapped:(id)sender
{
    [_badgeSegmentedControl setBadge:_badgeSegmentedControl.selectedSegmentIndex == 0 ? nil : @"2"
                   forSegmentAtIndex:0];
    [_badgeSegmentedControl setBadge:_badgeSegmentedControl.selectedSegmentIndex == 1 ? nil : @"Tap here!"
                   forSegmentAtIndex:1];
    [_badgeSegmentedControl setBadge:_badgeSegmentedControl.selectedSegmentIndex == 2 ? nil : @"1987"
                   forSegmentAtIndex:2];
}

@end

