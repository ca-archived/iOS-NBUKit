//
//  PTEConsoleLogger.m
//  LumberjackConsole
//
//  Created by Ernesto Rivera on 2013/05/23.
//  Copyright (c) 2013.
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

#import "PTEConsoleLogger.h"
#import "PTEDashboard.h"
#import <NBUCore/NBUCore.h>

@implementation PTEConsoleLogger
{
    NSMutableArray * _messages;         // All messages
    NSMutableArray * _filteredMessages; // Filtered messages
    
    UIFont * _font;
    CGFloat _fontSize;
    NSArray * _messagesBuffer;
    BOOL _updateScheduled;
    NSTimeInterval _minIntervalToUpdate;
    NSDate * _lastUpdate;
    
    NSString * _currentSearchText;
    NSInteger _currentLogLevel;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        // Default values
        _maxMessages = 1000;
        _fontSize = 13.0;
        _font = [UIFont systemFontOfSize:_fontSize];
        _lastUpdate = [NSDate date];
        _minIntervalToUpdate = 0.5;
        _currentLogLevel = LOG_LEVEL_VERBOSE;
        
        // Init message arrays
        _messages = [NSMutableArray arrayWithCapacity:_maxMessages];
        _filteredMessages = [NSMutableArray arrayWithCapacity:_maxMessages];
    }
    return self;
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

#pragma mark - Loggin messages

- (void)logMessage:(DDLogMessage *)logMessage
{
    @synchronized(self)
    {
        // Remove last object if needed
        BOOL removeObject = _messages.count == _maxMessages;
        if (removeObject)
        {
            [_messages removeLastObject];
        }
        
        // Insert new message
        [_messages insertObject:logMessage
                        atIndex:0];
        
        // Also update filterd messages if needed
        if ([self isFilteringEnabled] &&
            [self messagePassesFilter:logMessage])
        {
            [_filteredMessages insertObject:logMessage
                                    atIndex:0];
        }
    }
    
    // Refresh table view
    if (!_updateScheduled)
    {
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           [self setTableViewNeedsRefresh];
                       });
    }
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    NSString * string;
    if (self->formatter)
    {
        string = [self->formatter formatLogMessage:logMessage];
    }
    else
    {
        string = [NSString stringWithFormat:@"%@:%d %@",
                  logMessage.fileName,
                  logMessage->lineNumber,
                  logMessage->logMsg];
    }
    return string;
}

- (NSString *)formatShortLogMessage:(DDLogMessage *)logMessage
{
    return [[logMessage->logMsg
             stringByReplacingOccurrencesOfString:@"  " withString:@""]
            stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
}

#pragma mark - Handling the table view

- (void)setTableView:(UITableView *)tableView
{
    _tableView = tableView;
    
    // Make sure we are the data source and delegate
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

- (void)setTableViewNeedsRefresh
{
    // Refresh table
    if (_tableView)
    {
        @synchronized(self)
        {
            // Already scheduled?
            if (_updateScheduled)
                return;
            
            // Too soon?
            if ([_lastUpdate timeIntervalSinceNow] > -_minIntervalToUpdate)
            {
                // Schedule
                _updateScheduled = YES;
                dispatch_after(-[_lastUpdate timeIntervalSinceNow], dispatch_get_main_queue(), ^(void)
                               {
                                   _updateScheduled = NO;
                                   [self refreshTableView];
                               });
            }
            
            // Update directly
            else
            {
                [self refreshTableView];
            }
        }
    }
}

- (void)refreshTableView
{
    _lastUpdate = [NSDate date];
    
    // Freeze messages in a buffer
    NSArray * lastBuffer = _messagesBuffer;
    @try
    {
        // FIXME: Crashing for some reason when maxMessages is reached
        _messagesBuffer = [NSArray arrayWithArray:[self isFilteringEnabled] ? _filteredMessages : _messages];
    }
    @catch (NSException * exception)
    {
        NSLog(@"EXCEPTION while updating Dashboard: %@", exception.reason);
        [_tableView reloadData];
    }
    
    //    NSLog(@"!!! %d", _messagesBuffer.count);
    
    // Calculate how much the buffer moved
    NSUInteger offset = NSNotFound;
    if (lastBuffer.count > 0)
        offset = [_messagesBuffer indexOfObject:lastBuffer[0]];
    
    // Partial only
    if (offset != NSNotFound)
    {
        @try
        {
            [_tableView beginUpdates];
            
            // Remove items?
            NSUInteger tableCount = [_tableView numberOfRowsInSection:0];
            //        NSLog(@"••• %d", tableCount);
            NSInteger removeCount = tableCount + offset - _maxMessages;
            if (removeCount > 0)
            {
                NSMutableArray * indexPaths = [NSMutableArray arrayWithCapacity:removeCount];
                for (NSUInteger i = tableCount - removeCount; i < tableCount; i++)
                {
                    [indexPaths addObject:[NSIndexPath indexPathForRow:i
                                                             inSection:0]];
                }
                [_tableView deleteRowsAtIndexPaths:indexPaths
                                  withRowAnimation:UITableViewRowAnimationFade];
                //            NSLog(@"--- %d", indexPaths.count);
                //            NSLog(@"--- %@", indexPaths);
            }
            
            // Insert items
            NSMutableArray * indexPaths = [NSMutableArray arrayWithCapacity:offset];
            for (NSUInteger i = 0; i < offset; i++)
            {
                [indexPaths addObject:[NSIndexPath indexPathForRow:i
                                                         inSection:0]];
            }
            [_tableView insertRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
            //        NSLog(@"+++ %d", indexPaths.count);
            //        NSLog(@"+++ %@", indexPaths);
            
            [_tableView endUpdates];
            
            return;
        }
        @catch (NSException * exception)
        {
            NSLog(@"EXCEPTION while updating Dashboard: %@", exception.reason);
        }
    }
    
    // Full refresh needed
    [_tableView reloadData];
}

#pragma mark - Table's delegate/data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return _messagesBuffer.count;
}

- (NSString *)textForCellFromTableView:(UITableView *)tableView
                           atIndexPath:(NSIndexPath *)indexPath
{
    DDLogMessage * logMessage = _messagesBuffer[indexPath.row];
    
    NSString * prefix;
    switch (logMessage->logFlag)
    {
        case LOG_FLAG_ERROR : prefix = @"Ⓔ"; break;
        case LOG_FLAG_WARN  : prefix = @"Ⓦ"; break;
        case LOG_FLAG_INFO  : prefix = @"Ⓘ"; break;
        case LOG_FLAG_DEBUG : prefix = @"Ⓓ"; break;
        default             : prefix = @"Ⓥ"; break;
    }
    
    // Selected cell?
    if ([tableView.indexPathsForSelectedRows containsObject:indexPath])
    {
        return [NSString stringWithFormat:@" %@ %@", prefix, [self formatLogMessage:logMessage]];
    }
    
    // Unselected cell
    return [NSString stringWithFormat:@" %@ %@", prefix, [self formatShortLogMessage:logMessage]];
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Unselected cell?
    if (![tableView.indexPathsForSelectedRows containsObject:indexPath])
    {
        return 20.0;
    }
    
    // Selected cell
    NSString * string = [self textForCellFromTableView:tableView
                                           atIndexPath:indexPath];
    CGSize size = [string sizeWithFont:_font
                     constrainedToSize:CGSizeMake(tableView.bounds.size.width,
                                                  tableView.bounds.size.height)];
    return MAX(size.height, 20.0);
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView beginUpdates];
    [tableView endUpdates];
    UILabel * label = (UILabel *)[tableView cellForRowAtIndexPath:indexPath].contentView.subviews[0];
    label.text = [self textForCellFromTableView:tableView
                                    atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView
didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView beginUpdates];
    [tableView endUpdates];
    UILabel * label = (UILabel *)[tableView cellForRowAtIndexPath:indexPath].contentView.subviews[0];
    label.text = [self textForCellFromTableView:tableView
                                    atIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"logMessage"];
    UILabel * label;
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"logMessage"];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        label = [UILabel new];
        label.backgroundColor = [UIColor clearColor];
        label.font = _font;
        label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        label.numberOfLines = 0;
        label.frame = cell.contentView.bounds;
        [cell.contentView addSubview:label];
    }
    else
    {
        label = (UILabel *)cell.contentView.subviews[0];
    }
    
    DDLogMessage * logMessage = _messagesBuffer[indexPath.row];
    
    // Configure the label
    switch (logMessage->logFlag)
    {
        case LOG_FLAG_ERROR : label.textColor = [UIColor redColor];         break;
        case LOG_FLAG_WARN  : label.textColor = [UIColor orangeColor];      break;
        case LOG_FLAG_INFO  : label.textColor = [UIColor greenColor];       break;
        case LOG_FLAG_DEBUG : label.textColor = [UIColor whiteColor];       break;
        default             : label.textColor = [UIColor lightGrayColor];   break;
    }
    
    label.text = [self textForCellFromTableView:tableView
                                    atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - Content filtering

- (BOOL)isFilteringEnabled
{
    return (_currentSearchText.length > 0 ||        // Some text input
            _currentLogLevel != LOG_LEVEL_VERBOSE); // Or log level != verbose
}

- (BOOL)messagePassesFilter:(DDLogMessage *)message
{
    // Check log level...
    if (message->logFlag & _currentLogLevel)
    {
        // And text...
        if (_currentSearchText.length == 0 ||
            [[self formatLogMessage:message] rangeOfString:_currentSearchText
                                                   options:(NSCaseInsensitiveSearch |
                                                            NSDiacriticInsensitiveSearch |
                                                            NSWidthInsensitiveSearch)].location != NSNotFound)
        {
            return YES;
        }
    }
    
    return NO;
}

- (void)updateFilteredMessages
{
    // Refresh the filtered messages
    [_filteredMessages removeAllObjects];
    if ([self isFilteringEnabled])
    {
        // Check every message
        for (DDLogMessage * message in _messages)
        {
            if ([self messagePassesFilter:message])
            {
                [_filteredMessages addObject:message];
            }
        }
        
        _messagesBuffer = [NSArray arrayWithArray:_filteredMessages];
    }
    else
    {
        _messagesBuffer = [NSArray arrayWithArray:_messages];
    }
    
    [_tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar
selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    switch (selectedScope)
    {
        case 0 : _currentLogLevel = LOG_LEVEL_VERBOSE;  break;
        case 1 : _currentLogLevel = LOG_LEVEL_DEBUG;    break;
        case 2 : _currentLogLevel = LOG_LEVEL_INFO;     break;
        case 3 : _currentLogLevel = LOG_LEVEL_WARN;     break;
        default: _currentLogLevel = LOG_LEVEL_ERROR;    break;
    }
    
    [self updateFilteredMessages];
}

- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText
{
    if ([_currentSearchText isEqualToString:searchText])
        return;
    
    _currentSearchText = _searchBar.text;
    [self updateFilteredMessages];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    // Make dashboard fullscreen if needed
    PTEDashboard * dashboard = [_tableView.window isKindOfClass:[PTEDashboard class]] ? (PTEDashboard *)_tableView.window : nil;
    if (dashboard && !dashboard.isMaximized)
    {
        dashboard.maximized = YES;
    }
    
    return YES;
}

@end

