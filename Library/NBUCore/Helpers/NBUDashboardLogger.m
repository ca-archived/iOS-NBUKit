//
//  NBUDashboardLogger.m
//  NBUCore
//
//  Created by Ernesto Rivera on 2012/12/17.
//  Copyright (c) 2012 CyberAgent Inc.
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

#import "NBUDashboardLogger.h"

static NBUDashboardLogger * _sharedInstance;

// Private categories and classes
@interface NBUDashboardLogger (Private) <UITableViewDelegate, UITableViewDataSource>

@end

@implementation NBUDashboardWindow

@end


@implementation NBUDashboardLogger
{
    UIWindow * _keyWindow;
    UIWindow * _logWindow;
    UIFont * _font;
    CGFloat _fontSize;
    NSMutableArray * _messages;
    NSArray * _messagesBuffer;
    BOOL _updateScheduled;
    NSTimeInterval _minIntervalToUpdate;
    NSDate * _lastUpdate;
}
@synthesize tableView = _tableView;
@synthesize maxMessages = _maxMessages;

+ (NBUDashboardLogger *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [NBUDashboardLogger new];
    });
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _maxMessages = 100;
        _messages = [NSMutableArray arrayWithCapacity:_maxMessages];
        _fontSize = 13.0;
        _font = [UIFont systemFontOfSize:_fontSize];
        _lastUpdate = [NSDate date];
        _minIntervalToUpdate = 0.5;
    }
    return self;
}

- (IBAction)toggle:(UIButton *)sender
{
    BOOL wasSelected = sender.selected;
    sender.selected = !wasSelected;
    
    if (wasSelected)
    {
        [self minimizeAnimated:YES];
        [_tableView scrollToTopAnimated:YES];
    }
    else
    {
        [self maximizeAnimated:YES];
    }
}

- (void)maximizeAnimated:(BOOL)animated
{
    [UIView animateWithDuration:animated ? 0.2 : 0.0
                     animations:^
     {
         _logWindow.frame = _keyWindow.bounds;
     }];
}

- (void)minimizeAnimated:(BOOL)animated
{
    [UIView animateWithDuration:animated ? 0.2 : 0.0
                     animations:^
     {
         _logWindow.frame = CGRectMake(0.0,
                                       0.0,
                                       _keyWindow.size.width - 30.0,
                                       20.0);
     }];
}

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

- (void)setTableViewNeedsRefresh
{
    // Create the table (and log window)?
    if (!_tableView && [UIApplication sharedApplication].keyWindow)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            _keyWindow = [UIApplication sharedApplication].keyWindow;
            _logWindow = [NSBundle loadNibNamed:@"NBUDashboardLogger"
                                          owner:self
                                        options:nil][0];
            _logWindow.windowLevel = UIWindowLevelStatusBar + 1;
            _tableView.frame = CGRectMake(20.0,
                                          0.0,
                                          _keyWindow.size.width - 20.0,
                                          _keyWindow.size.height);
            [self minimizeAnimated:NO];
            _logWindow.hidden = NO;
        });
    }
    
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
    _messagesBuffer = [NSArray arrayWithArray:_messages];
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
        @catch (NSException *exception)
        {
            NSLog(@"EXCEPTION while updating Dashboard: %@", exception.reason);
        }
    }
    
    // Full refresh needed
    [_tableView reloadData];
}

#pragma mark - TableView delegate/data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return _messagesBuffer.count;
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

- (NSString *)textForCellAtIndexPath:(NSIndexPath *)indexPath
{
    DDLogMessage * message = _messagesBuffer[indexPath.row];
    
    // Selected cell
    if (SYSTEM_VERSION_LESS_THAN(@"5.0") &&
        _tableView.indexPathForSelectedRow == indexPath)
    {
        return [self formatLogMessage:message];
    }
    if ([_tableView.indexPathsForSelectedRows containsObject:indexPath])
    {
        return [self formatLogMessage:message];
    }
    
    // Unselected cell
    return [[message->logMsg stringByReplacingOccurrencesOfString:@"  "
                                                       withString:@""] stringByReplacingOccurrencesOfString:@"\n"
                                                                                                 withString:@" "];
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Unselected cell
    if (SYSTEM_VERSION_LESS_THAN(@"5.0") &&
        _tableView.indexPathForSelectedRow != indexPath)
    {
        return 20.0;
    }
    if (![_tableView.indexPathsForSelectedRows containsObject:indexPath])
    {
        return 20.0;
    }
    
    // Selected cell
    NSString * string = [self textForCellAtIndexPath:indexPath];
    CGSize size = [string sizeWithFont:_font
                     constrainedToSize:CGSizeMake(_tableView.size.width,
                                                  _tableView.size.height)];
    return MAX(size.height, 20.0);
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView beginUpdates];
    [tableView endUpdates];
    UILabel * label = (UILabel *)[_tableView cellForRowAtIndexPath:indexPath].contentView.subviews[0];
    label.text = [self textForCellAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView
didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView beginUpdates];
    [tableView endUpdates];
    UILabel * label = (UILabel *)[_tableView cellForRowAtIndexPath:indexPath].contentView.subviews[0];
    label.text = [self textForCellAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:@"logMessage"];
    UILabel * label;
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"logMessage"];
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
    
    DDLogMessage * message = _messagesBuffer[indexPath.row];
    switch (message->logFlag)
    {
        case LOG_FLAG_ERROR : label.textColor = [UIColor redColor]; break;
        case LOG_FLAG_WARN  : label.textColor = [UIColor orangeColor]; break;
        case LOG_FLAG_INFO  : label.textColor = [UIColor greenColor]; break;
        default             : label.textColor = [UIColor whiteColor]; break;
    }
    
    label.text = [self textForCellAtIndexPath:indexPath];
    
    return cell;
}

@end

