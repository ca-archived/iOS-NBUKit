//
//  UITabBarController+NBUAdditions.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/09/18.
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

#import "UITabBarController+NBUAdditions.h"
#import "NBUKitPrivate.h"

@implementation UITabBarController (NBUAdditions)

- (BOOL)isTabBarHidden
{
    return CGRectGetMaxY([UIScreen mainScreen].applicationFrame) < CGRectGetMaxY(self.view.frame);
}

- (void)setTabBarHidden:(BOOL)tabBarHidden
{
    [self setTabBarHidden:tabBarHidden
                 animated:NO];
}

- (void)setTabBarHidden:(BOOL)hidden
               animated:(BOOL)animated
{
    NBULogVerbose(@"setTabBarHidden: %@", NBUStringFromBOOL(hidden));
    
    [UIView animateWithDuration:animated ? UINavigationControllerHideShowBarDuration : 0.0
                          delay:0.0
                        options:(UIViewAnimationOptionAllowUserInteraction |
                                 UIViewAnimationOptionLayoutSubviews |
                                 UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         
                         CGRect frame = [UIScreen mainScreen].applicationFrame;
                         if (hidden)
                         {
                             frame.size.height += self.tabBar.size.height;
                         }
                         self.view.frame = frame;
                     }
                     completion:NULL];
}

@end
