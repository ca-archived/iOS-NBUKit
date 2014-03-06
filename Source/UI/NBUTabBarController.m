//
//  NBUTabBarController.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/09/19.
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

#import "NBUTabBarController.h"
#import "NBUKitPrivate.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_UI

@implementation NBUTabBarController
{
    BOOL _shoudlAdjustViews;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    if (_shoudlAdjustViews)
    {
        [self adjustViews];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_shoudlAdjustViews)
    {
        [self adjustViews];
    }
}

- (void)setTabBarOnTop:(BOOL)tabBarOnTop
{
    _tabBarOnTop = tabBarOnTop;
    
    _shoudlAdjustViews = YES;
}

- (void)setTabBarModel:(NBUTabBarModel *)tabBarModel
{
    _tabBarModel = tabBarModel;
    
    _tabBarOnTop = tabBarModel.tag;
    _shoudlAdjustViews = YES;
}

- (void)adjustViews
{
    NBULogTrace();
    NBULogVerbose(@"%@ %@", self.view, self.view.subviews);
    
    // Adjust other views' frame
    for (UIView * view in self.view.subviews)
    {
        if (view == self.tabBar)
            continue;
        
        view.frame = CGRectMake(view.frame.origin.x,
                                _tabBarOnTop ? _tabBarModel.size.height : 0.0,
                                view.size.width,
                                view.size.height + self.tabBar.size.height - _tabBarModel.size.height);
    }
    
    // Adjust tabBar frame
    self.tabBar.frame = CGRectMake(self.tabBar.frame.origin.x,
                                   _tabBarOnTop ? 20.0 : self.view.size.height - _tabBarModel.size.height,
                                   self.tabBar.size.width,
                                   _tabBarModel.size.height);
    
    NBULogVerbose(@"%@ %@", self.view, self.view.subviews);
    
    // Adjust tabBar subviews
//    UIView * firstButton = nil;
    UIView * placeholder;
    NSEnumerator * enumerator = [_tabBarModel.itemPlaceholders objectEnumerator];
    for (UIView * view in self.tabBar.subviews)
    {
        if (![view isKindOfClass:[UIControl class]])
            continue;
        
//        if (!firstButton)
//        {
//            firstButton = view;
//        }
        
        placeholder = [enumerator nextObject];
        view.frame = placeholder.frame;
        view.autoresizingMask = placeholder.autoresizingMask;
        [placeholder removeFromSuperview];
    }
    
    // Add extra tabBar views
//    [self.tabBar insertSubview:_tabBarModel
//                  belowSubview:firstButton];
//    [self.tabBar addSubview:_tabBarModel];
    [self.tabBar insertSubview:_tabBarModel
                       atIndex:0];
    for (UIView * view in _tabBarModel.subviews)
    {
        [self.tabBar addSubview:view];
    }
    
    // Finish configuring tabBar
    self.tabBar.clipsToBounds = _tabBarOnTop;
    
    NBULogVerbose(@"%@", self.tabBar.subviews);
    
    _shoudlAdjustViews = NO;
}

@end


@implementation NBUTabBar

- (void)layoutSubviews
{
    // Keep it empty to avoid getting the tabBar reseted
}

@end


@implementation NBUTabBarModel


@end

