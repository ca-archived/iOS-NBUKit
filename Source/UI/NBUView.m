//
//  NBUView.m
//  NBUKit
//
//  Created by 利辺羅 on 2012/10/15.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
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

