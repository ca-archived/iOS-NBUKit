//
//  HideOnScrollViewController.m
//  NBUKitDemo
//
//  Created by Ernesto Rivera on 2012/09/18.
//  Copyright (c) 2012-2016 CyberAgent Inc.
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
