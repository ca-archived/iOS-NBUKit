//
//  NBUView.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/10/15.
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

#import "NBUView.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_UI

@implementation NBUView

- (void)commonInit
{
    // *** Override in subclasses and call [super commonInit] ***
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (void)willMoveToWindow:(UIWindow *)window
{
    if (window)
    {
        [self viewWillAppear];
    }
    else
    {
        [self viewWillDisappear];
    }
}

- (void)didMoveToWindow
{
    if (self.window)
    {
        [self viewDidAppear];
    }
    else
    {
        [self viewDidDisappear];
    }
}

- (void)viewWillAppear
{
    // *** Override in subclasses if needed ***
}

- (void)viewDidAppear
{
    // *** Override in subclasses if needed ***
}

- (void)viewWillDisappear
{
    // *** Override in subclasses if needed ***
}

- (void)viewDidDisappear
{
    // *** Override in subclasses if needed ***
}

@end

