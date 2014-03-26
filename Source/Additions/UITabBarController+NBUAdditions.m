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
#import <objc/runtime.h>

@implementation UITabBarController (NBUAdditions)

@dynamic originalViewFrame;

- (BOOL)isTabBarHidden
{
    return CGRectGetMaxY(self.view.frame) > CGRectGetMaxY(self.originalViewFrame);
}

- (void)setTabBarHidden:(BOOL)hidden
{
    CGRect frame = self.originalViewFrame;
    if (hidden)
    {
        frame.size.height += self.tabBar.size.height;
    }
    
    NBULogDebug(@"%@ %@ %@", THIS_METHOD, NBUStringFromBOOL(hidden), NSStringFromCGRect(frame));
    self.view.frame = frame;
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
                     animations:^
     {
         self.tabBarHidden = hidden;
     }
                     completion:NULL];
}

- (CGRect)originalViewFrame
{
    NSValue * value = objc_getAssociatedObject(self,
                                               @selector(originalViewFrame));
    if (value)
    {
        return value.CGRectValue;
    }
    else
    {
        self.originalViewFrame = self.view.frame;
        return self.view.frame;
    }
}

- (void)setOriginalViewFrame:(CGRect)originalViewFrame
{
    objc_setAssociatedObject(self,
                             @selector(originalViewFrame),
                             [NSValue valueWithCGRect:originalViewFrame],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
