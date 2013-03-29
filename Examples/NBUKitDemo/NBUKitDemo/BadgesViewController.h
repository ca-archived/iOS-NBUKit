//
//  BadgesViewController.h
//  NBUKitDemo
//
//  Created by 利辺羅 on 2012/10/12.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BadgesViewController : ScrollViewController

// Outlets
@property (assign, nonatomic) IBOutlet NBUBadgeView * badgeView;
@property (assign, nonatomic) IBOutlet NBUBadgeSegmentedControl * badgeSegmentedControl;

// Actions
- (IBAction)badgeTapped:(id)sender;

@end

