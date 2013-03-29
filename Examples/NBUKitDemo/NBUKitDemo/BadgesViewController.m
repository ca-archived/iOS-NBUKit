//
//  BadgesViewController.m
//  NBUKitDemo
//
//  Created by 利辺羅 on 2012/10/12.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import "BadgesViewController.h"

@implementation BadgesViewController

@synthesize badgeView = _badgeView;
@synthesize badgeSegmentedControl = _badgeSegmentedControl;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Programatic badge
    NBUBadgeView * badge = [NBUBadgeView badge];
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

