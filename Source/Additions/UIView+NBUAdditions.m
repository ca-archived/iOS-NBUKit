//
//  UIView+NBUAdditions.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/08/06.
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

#import "UIView+NBUAdditions.h"
#import "NBUKitPrivate.h"

@implementation UIView (NBUAdditions)

#pragma mark - Properties

- (void)setOrigin:(CGPoint)origin
{
    CGSize size = self.size;
    self.frame = CGRectMake(origin.x,
                            origin.y,
                            size.width,
                            size.height);
}

- (CGPoint)origin
{
    return self.frame.origin;
}

- (void)setSize:(CGSize)size
{
    CGPoint origin = self.origin;
    self.frame = CGRectMake(origin.x,
                            origin.y,
                            size.width,
                            size.height);
}

- (CGSize)size
{
    return self.frame.size;
}

#pragma mark - Controllers

- (UIViewController *)viewController
{
    for (UIResponder * nextResponder = self.nextResponder;
         nextResponder;
         nextResponder = nextResponder.nextResponder)
    {
        if ([nextResponder isKindOfClass:[UIViewController class]])
            return (UIViewController *)nextResponder;
    }
    
    // Not found
    NBULogVerbose(@"%@ doesn't seem to have a viewController", self);
    return nil;
}

- (UINavigationController *)navigationController
{
    return self.viewController.navigationController;
}

- (UITabBarController *)tabBarController
{
    return self.viewController.tabBarController;
}

@end

