//
//  UINavigationController+NBUAdditions.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/10/04.
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

#import "UINavigationController+NBUAdditions.h"
#import "NBUKitPrivate.h"

@implementation UINavigationController (NBUAdditions)

#pragma mark - Properties

- (UIViewController *)rootViewController
{
    NSArray * controllers = self.viewControllers;
    return controllers.count > 0 ? controllers[0] : nil;
}

- (void)setRootViewController:(UIViewController *)rootViewController
{
    NBULogTrace();
    
    self.viewControllers = rootViewController ? @[rootViewController] : nil;
}

- (void)setTopViewController:(UIViewController *)controller
{
    NBULogTrace();
    
    NSMutableArray * viewControllers = [NSMutableArray arrayWithArray:self.viewControllers];
    if (viewControllers.count > 0)
    {
        [viewControllers removeLastObject];
    }
    [viewControllers addObject:controller];
    
    self.viewControllers = viewControllers;
}

#pragma mark - Actions

- (IBAction)popViewController:(id)sender
{
    NBULogTrace();
    
    [self popViewControllerAnimated:YES];
}

- (IBAction)popToRootViewController:(id)sender
{
    NBULogTrace();
    
    [self popToRootViewControllerAnimated:YES];
}

@end

