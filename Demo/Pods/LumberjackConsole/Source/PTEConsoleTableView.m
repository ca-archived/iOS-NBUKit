//
//  PTEConsoleTableView.m
//  LumberjackConsole
//
//  Created by Ernesto Rivera on 2014/04/09.
//  Copyright (c) 2013-2015 PTEz.
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

#import "PTEConsoleTableView.h"
#import "PTEConsoleLogger.h"
#import <NBUCore/NBUCore.h>

@implementation PTEConsoleTableView

- (instancetype)initWithFrame:(CGRect)frame
                        style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame
                          style:style];
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

- (void)commonInit
{
    // Default settings
    self.allowsMultipleSelection = YES;
    self.rowHeight = 20.0;
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    
    // Search bar fix (http://stackoverflow.com/a/25788774/1049134)
    [_searchBar sizeToFit];
}

- (void)setLogger:(PTEConsoleLogger *)logger
{
    _logger = logger;
    
    // Set the logger's tableView
    logger.tableView = self;
    
    // Make sure the logger is also our data source and delegate
    self.dataSource = logger;
    self.delegate = logger;
    
    // And our search bar's delegate too
    self.searchBar.delegate = logger;
}

- (void)setSearchBar:(UISearchBar *)searchBar
{
    _searchBar = searchBar;
    
    // Customize searchBar keyboard's return key
    NSArray * subviewsToCheck = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? ((UIView *)_searchBar.subviews[0]).subviews :
                                                                                  _searchBar.subviews;
    for(UIView * view in subviewsToCheck)
    {
        if([view conformsToProtocol:@protocol(UITextInputTraits)])
        {
            ((UITextField *)view).returnKeyType = UIReturnKeyDone;
            ((UITextField *)view).enablesReturnKeyAutomatically = NO;
        }
    }
}

- (id<UITableViewDataSource>)dataSource
{
    // Create a logger if needed
    PTEConsoleLogger * logger = self.logger;
    if (!logger)
    {
        logger = [PTEConsoleLogger new];
        self.logger = logger;
    }
    
    return logger;
}

- (IBAction)clearConsole:(id)sender
{
    [self.logger clearConsole];
}

- (IBAction)addMarker:(id)sender
{
    [self.logger addMarker];
}

@end

