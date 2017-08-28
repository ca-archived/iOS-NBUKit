//
//  PTEConsoleLogger.m
//  LumberjackConsole
//
//  Created by Ernesto Rivera on 2013/05/23.
//  Copyright (c) 2013-2017 PTEz.
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
#import "PTEConsoleTableView.h"
#import "PTEDashboard.h"
#import <NBUCore/NBUCore.h>

#define LOG_LEVEL 2

#define NSLogError(frmt, ...)    do{ if(LOG_LEVEL >= 1) NSLog((frmt), ##__VA_ARGS__); } while(0)
#define NSLogWarn(frmt, ...)     do{ if(LOG_LEVEL >= 2) NSLog((frmt), ##__VA_ARGS__); } while(0)
#define NSLogInfo(frmt, ...)     do{ if(LOG_LEVEL >= 3) NSLog((frmt), ##__VA_ARGS__); } while(0)
#define NSLogDebug(frmt, ...)    do{ if(LOG_LEVEL >= 4) NSLog((frmt), ##__VA_ARGS__); } while(0)
#define NSLogVerbose(frmt, ...)  do{ if(LOG_LEVEL >= 5) NSLog((frmt), ##__VA_ARGS__); } while(0)

// Private marker message class
@interface PTEMarkerLogMessage : DDLogMessage

@end

@implementation PTEMarkerLogMessage

@end


@implementation PTEConsoleLogger
{
    // Managing incoming messages
    dispatch_queue_t _consoleQueue;
    NSMutableArray * _messages;             // All currently displayed messages
    NSMutableArray * _newMessagesBuffer;    // Messages not yet added to _messages
    
    // Scheduling table view updates
    BOOL _updateScheduled;
    NSTimeInterval _minIntervalToUpdate;
    NSDate * _lastUpdate;

    // Filtering messages
    BOOL _filteringEnabled;
    NSString * _currentSearchText;
    NSInteger _currentLogLevel;
    NSMutableArray * _filteredMessages;
    
    // Managing expanding/collapsing messages
    NSMutableSet * _expandedMessages;
    
    // UI
    UIFont * _font;
    CGFloat _fontSize;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        // Default values
        _maxMessages = 1000;
        _fontSize = 13.0;
        _font = [UIFont systemFontOfSize:_fontSize];
        _lastUpdate = NSDate.date;
        _minIntervalToUpdate = 0.3;
        _currentLogLevel = DDLogLevelVerbose;
        
        // Init queue
        _consoleQueue = dispatch_queue_create("console_queue", NULL);
        
        // Init message arrays and sets
        _messages = [NSMutableArray arrayWithCapacity:_maxMessages];
        _newMessagesBuffer = NSMutableArray.array;
        _expandedMessages = NSMutableSet.set;
        
        // Register logger
        [DDLog addLogger:self];
    }
    return self;
}

#pragma mark - Logger

- (void)logMessage:(DDLogMessage *)logMessage
{
    // The method is called from the logger queue
    dispatch_async(_consoleQueue, ^
    {
        // Add new message to buffer
        [_newMessagesBuffer insertObject:logMessage
                                 atIndex:0];

        // Trigger update
        [self updateOrScheduleTableViewUpdateInConsoleQueue];
    });
}

#pragma mark - Log formatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    if (_logFormatter)
    {
        return [_logFormatter formatLogMessage:logMessage];
    }
    else
    {
        return [NSString stringWithFormat:@"%@:%@ %@",
                logMessage.fileName,
                @(logMessage->_line),
                logMessage->_message];
    }
}

- (NSString *)formatShortLogMessage:(DDLogMessage *)logMessage
{
    if (self.shortLogFormatter)
    {
        return [self.shortLogFormatter formatLogMessage:logMessage];
    }
    else
    {
        return [[logMessage->_message
                 stringByReplacingOccurrencesOfString:@"  " withString:@""]
                stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    }
}

#pragma mark - Methods

- (void)clearConsole
{
    // The method is called from the main queue
    dispatch_async(_consoleQueue, ^
                   {
                       // Clear all messages
                       [_newMessagesBuffer removeAllObjects];
                       [_messages removeAllObjects];
                       [_filteredMessages removeAllObjects];
                       [_expandedMessages removeAllObjects];
                       
                       [self updateTableViewInConsoleQueue];
                   });
}

- (void)addMarker
{
    PTEMarkerLogMessage * marker = PTEMarkerLogMessage.new;
    marker->_message = [NSString stringWithFormat:@"Marker %@", NSDate.date];
    [self logMessage:marker];
}

#pragma mark - Handling new messages

- (void)updateOrScheduleTableViewUpdateInConsoleQueue
{
    if (_updateScheduled)
        return;
    
    // Schedule?
    NSTimeInterval timeToWaitForNextUpdate = _minIntervalToUpdate + _lastUpdate.timeIntervalSinceNow;
    NSLogVerbose(@"timeToWaitForNextUpdate: %@", @(timeToWaitForNextUpdate));
    if (timeToWaitForNextUpdate > 0)
    {
        _updateScheduled = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeToWaitForNextUpdate * NSEC_PER_SEC)), _consoleQueue, ^
                       {
                           [self updateTableViewInConsoleQueue];
                           
                           _updateScheduled = NO;
                       });
    }
    // Update directly
    else
    {
        [self updateTableViewInConsoleQueue];
    }
}

- (void)updateTableViewInConsoleQueue
{
    _lastUpdate = NSDate.date;
    
    // Add and trim block
    __block NSInteger itemsToRemoveCount;
    __block NSInteger itemsToInsertCount;
    __block NSInteger itemsToKeepCount;
    void (^addAndTrimMessages)(NSMutableArray * messages, NSArray * newItems) = ^(NSMutableArray * messages, NSArray * newItems)
    {
        NSArray * tmp = [NSArray arrayWithArray:messages];
        [messages removeAllObjects];
        [messages addObjectsFromArray:newItems];
        [messages addObjectsFromArray:tmp];
        itemsToRemoveCount = MAX(0, (NSInteger)(messages.count - _maxMessages));
        if (itemsToRemoveCount > 0)
        {
            [messages removeObjectsInRange:NSMakeRange(_maxMessages, itemsToRemoveCount)];
        }
        itemsToInsertCount = MIN(newItems.count, _maxMessages);
        itemsToKeepCount = messages.count - itemsToInsertCount;
    };
    
    // Update regular messages' array
    addAndTrimMessages(_messages, _newMessagesBuffer);
    NSLogDebug(@"Messages to add: %@ keep: %@ remove: %@", @(itemsToInsertCount), @(itemsToKeepCount), @(itemsToRemoveCount));
    
    // Handle filtering
    BOOL forceReload = NO;
    if (_filteringEnabled)
    {
        // Just swithed on filtering?
        if (!_filteredMessages)
        {
            _filteredMessages = [self filterMessages:_messages];
            forceReload = YES;
        }
        
        // Update filtered messages' array
        addAndTrimMessages(_filteredMessages, [self filterMessages:_newMessagesBuffer]);
        NSLogDebug(@"Filtered messages to add: %@ keep: %@ remove: %@", @(itemsToInsertCount), @(itemsToKeepCount), @(itemsToRemoveCount));
    }
    else
    {
        // Just turned off filtering ?
        if (_filteredMessages)
        {
            // Clear filtered messages and force table reload
            _filteredMessages = nil;
            forceReload = YES;
        }
    }
    
    // Empty buffer
    [_newMessagesBuffer removeAllObjects];
    
    // Update table view (dispatch sync to ensure the messages' arrayt doesn't get modified)
    dispatch_sync(dispatch_get_main_queue(), ^
                  {
                      // Completely update table view?
                      if (itemsToKeepCount == 0 || forceReload)
                      {
                          [self.tableView reloadData];
                          
                      }
                      // Partial only
                      else
                      {
                          [self updateTableViewRowsRemoving:itemsToRemoveCount
                                                  inserting:itemsToInsertCount];
                      }
                  });
}

- (void)updateTableViewRowsRemoving:(NSInteger)itemsToRemoveCount
                          inserting:(NSInteger)itemsToInsertCount
{
    // Remove paths
    NSMutableArray * removePaths = [NSMutableArray arrayWithCapacity:itemsToRemoveCount];
    if(itemsToRemoveCount > 0)
    {
        NSUInteger tableCount = [self.tableView numberOfRowsInSection:0];
        for (NSInteger i = tableCount - itemsToRemoveCount; i < tableCount; i++)
        {
            [removePaths addObject:[NSIndexPath indexPathForRow:i
                                                     inSection:0]];
        }
    }
    
    // Insert paths
    NSMutableArray * insertPaths = [NSMutableArray arrayWithCapacity:itemsToInsertCount];
    for (NSInteger i = 0; i < itemsToInsertCount; i++)
    {
        [insertPaths addObject:[NSIndexPath indexPathForRow:i
                                                 inSection:0]];
    }
    
    // Update table view, we should never crash
    @try
    {
        [self.tableView beginUpdates];
        if (itemsToRemoveCount > 0)
        {
            [self.tableView deleteRowsAtIndexPaths:removePaths
                                  withRowAnimation:UITableViewRowAnimationFade];
            NSLogVerbose(@"deleteRowsAtIndexPaths: %@", removePaths);
        }
        if (itemsToInsertCount > 0)
        {
            [self.tableView insertRowsAtIndexPaths:insertPaths
                                  withRowAnimation:UITableViewRowAnimationFade];
        }
        NSLogVerbose(@"insertRowsAtIndexPaths: %@", insertPaths);
        [self.tableView endUpdates];
    }
    @catch (NSException * exception)
    {
        NSLogError(@"Exception when updating LumberjackConsole: %@", exception);
        
        [self.tableView reloadData];
    }
}

#pragma mark - Table's delegate/data source

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    NSLogInfo(@"numberOfRowsInSection: %@", @((_filteringEnabled ? _filteredMessages : _messages).count));
    return (_filteringEnabled ? _filteredMessages : _messages).count;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Expanded cell?
    DDLogMessage * logMessage = (_filteringEnabled ? _filteredMessages : _messages)[indexPath.row];
    if (![_expandedMessages containsObject:logMessage])
    {
        return 20.0;
    }
    
    // Collapsed cell
    NSString * string = [self textForCellWithLogMessage:logMessage];
    CGSize size;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        // Save a sample label reference
        static UILabel * labelModel;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
                      {
                          labelModel = [self labelForNewCell];
                      });
        
        labelModel.text = string;
        size = [labelModel textRectForBounds:CGRectMake(0.0, 0.0,
                                                        tableView.bounds.size.width,
                                                        CGFLOAT_MAX)
                      limitedToNumberOfLines:0].size;
    }
    else
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
        size = [string sizeWithFont:_font
                  constrainedToSize:CGSizeMake(tableView.bounds.size.width,
                                               CGFLOAT_MAX)];
#pragma clang diagnostic pop
    }
    
    return size.height + 20.0;
}

- (NSIndexPath *)tableView:(UITableView *)tableView
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLogInfo(@"willSelectRowAtIndexPath: %@ Expanded messages: %@", indexPath, _expandedMessages);
    
    // Remove/add row to expanded messages
    DDLogMessage * logMessage = (_filteringEnabled ? _filteredMessages : _messages)[indexPath.row];
    if ([_expandedMessages containsObject:logMessage])
    {
        [_expandedMessages removeObject:logMessage];
    }
    else
    {
        [_expandedMessages addObject:logMessage];
    }
    
    // Update cell's text
    UILabel * label = (UILabel *)[tableView cellForRowAtIndexPath:indexPath].contentView.subviews[0];
    label.text = [self textForCellWithLogMessage:logMessage];
    
    // The method is called from the main queue
    dispatch_async(_consoleQueue, ^
                   {
                       // Trigger row height update
                       [self updateTableViewInConsoleQueue];
                   });
    
    // Don't select the cell
    return nil;
}

- (UILabel *)labelForNewCell
{
    UILabel * label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    label.font = _font;
    label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    label.numberOfLines = 0;
    
    return label;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // A marker?
    DDLogMessage * logMessage = (_filteringEnabled ? _filteredMessages : _messages)[indexPath.row];
    BOOL marker = [logMessage isKindOfClass:[PTEMarkerLogMessage class]];
    
    // Load cell
    NSString * identifier = marker ? @"marker" : @"logMessage";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    UILabel * label;
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:identifier];
        cell.clipsToBounds = YES;
        cell.backgroundColor = UIColor.clearColor;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        label = [self labelForNewCell];
        label.frame = cell.contentView.bounds;
        [cell.contentView addSubview:label];
        
        if (marker)
        {
            label.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1.0];
            label.textAlignment = NSTextAlignmentCenter;
            cell.userInteractionEnabled = NO;
        }
    }
    else
    {
        label = (UILabel *)cell.contentView.subviews[0];
    }
    
    // Configure the label
    if (marker)
    {
        label.text = logMessage->_message;
    }
    else
    {
        switch (logMessage->_flag)
        {
            case DDLogFlagError   : label.textColor = [UIColor redColor];       break;
            case DDLogFlagWarning : label.textColor = [UIColor orangeColor];    break;
            case DDLogFlagInfo    : label.textColor = [UIColor greenColor];     break;
            case DDLogFlagDebug   : label.textColor = [UIColor whiteColor];     break;
            default               : label.textColor = [UIColor lightGrayColor]; break;
        }
        label.text = [self textForCellWithLogMessage:logMessage];
    }
    
    return cell;
}

- (NSString *)textForCellWithLogMessage:(DDLogMessage *)logMessage
{
    NSString * prefix;
    switch (logMessage->_flag)
    {
        case DDLogFlagError   : prefix = @"Ⓔ"; break;
        case DDLogFlagWarning : prefix = @"Ⓦ"; break;
        case DDLogFlagInfo    : prefix = @"Ⓘ"; break;
        case DDLogFlagDebug   : prefix = @"Ⓓ"; break;
        default               : prefix = @"Ⓥ"; break;
    }
    
    // Expanded message?
    if ([_expandedMessages containsObject:logMessage])
    {
        return [NSString stringWithFormat:@" %@ %@", prefix, [self formatLogMessage:logMessage]];
    }
    
    // Collapsed message
    return [NSString stringWithFormat:@" %@ %@", prefix, [self formatShortLogMessage:logMessage]];
}

#pragma mark - Copying text

- (BOOL)tableView:(UITableView *)tableView
shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView
 canPerformAction:(SEL)action
forRowAtIndexPath:(NSIndexPath *)indexPath
       withSender:(id)sender
{
    return action == @selector(copy:);
}

- (void)tableView:(UITableView *)tableView
    performAction:(SEL)action
forRowAtIndexPath:(NSIndexPath *)indexPath
       withSender:(id)sender
{
    if (action == @selector(copy:))
    {
        DDLogMessage * logMessage = (_filteringEnabled ? _filteredMessages : _messages)[indexPath.row];
        NSString * textToCopy = [self formatLogMessage:logMessage];
        UIPasteboard.generalPasteboard.string = textToCopy;
        
        NSLogInfo(@"Copied: %@", textToCopy);
    }
}

#pragma mark - Message filtering

- (NSMutableArray *)filterMessages:(NSArray *)messages
{
    NSMutableArray * filteredMessages = NSMutableArray.array;
    for (DDLogMessage * message in messages)
    {
        if ([self messagePassesFilter:message])
        {
            [filteredMessages addObject:message];
        }
    }
    return filteredMessages;
}

- (BOOL)messagePassesFilter:(DDLogMessage *)message
{
    // Message is a marker OR (Log flag matches AND (no search text OR contains search text))
    return ([message isKindOfClass:[PTEMarkerLogMessage class]] ||
            ((message->_flag & _currentLogLevel) &&
             (_currentSearchText.length == 0 ||
              [[self formatLogMessage:message] rangeOfString:_currentSearchText
                                                     options:(NSCaseInsensitiveSearch |
                                                              NSDiacriticInsensitiveSearch |
                                                              NSWidthInsensitiveSearch)].location != NSNotFound)));
}

#pragma mark - Search bar delegate

- (void)searchBarStateChanged
{
    // The method is called from the main queue
    dispatch_async(_consoleQueue, ^
    {
        // Filtering enabled?
        _filteringEnabled = (_currentSearchText.length > 0 ||        // Some text input
                             _currentLogLevel != DDLogLevelVerbose); // Or log level != verbose
        
        // Force reloading filtered messages
        if (_filteringEnabled)
        {
            _filteredMessages = nil;
        }
        
        // Update
        [self updateTableViewInConsoleQueue];
    });
}

- (void)searchBar:(UISearchBar *)searchBar
selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    switch (selectedScope)
    {
        case 0  : _currentLogLevel = DDLogLevelVerbose; break;
        case 1  : _currentLogLevel = DDLogLevelDebug;   break;
        case 2  : _currentLogLevel = DDLogLevelInfo;    break;
        case 3  : _currentLogLevel = DDLogLevelWarning; break;
        default : _currentLogLevel = DDLogLevelError;   break;
    }
    
    [self searchBarStateChanged];
}

- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText
{
    if ([_currentSearchText isEqualToString:searchText])
        return;
    
    _currentSearchText = searchBar.text;
    
    [self searchBarStateChanged];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    // Make dashboard fullscreen if needed
    PTEDashboard * dashboard = (PTEDashboard *)self.tableView.window;
    if ([dashboard isKindOfClass:[PTEDashboard class]])
    {
        dashboard.maximized = YES;
    }
    
    return YES;
}

@end

