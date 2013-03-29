//
//  HideOnScrollViewController.m
//  NBUKitDemo
//
//  Created by 利辺羅 on 2012/09/18.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import "HideOnScrollViewController.h"

@implementation HideOnScrollViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Enable hide on scroll
    self.hidesBarsOnScroll = YES;
}

- (IBAction)hide:(id)sender
{
    [self.navigationController setNavigationBarHidden:YES
                                             animated:YES];
    [self.tabBarController setTabBarHidden:YES
                                  animated:YES];
}

- (IBAction)show:(id)sender
{
    [self.navigationController setNavigationBarHidden:NO
                                             animated:YES];
    [self.tabBarController setTabBarHidden:NO
                                  animated:YES];
}

@end
