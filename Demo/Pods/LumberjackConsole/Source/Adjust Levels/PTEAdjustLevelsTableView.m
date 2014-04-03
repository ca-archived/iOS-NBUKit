//
//  PTEAdjustLevelsTableView.m
//  LumberjackConsole
//
//  Created by Ernesto Rivera on 2013/10/09.
//  Copyright (c) 2013-2014 PTEz.
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

#ifdef COCOAPODS_POD_AVAILABLE_NBULog

#import "PTEAdjustLevelsTableView.h"
#import <NBULog/NBULogContextDescription.h>

// Class extension
@interface PTEAdjustLevelsTableView () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation PTEAdjustLevelsTableView
{
    NSArray * _orderedContexts;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Init
    _orderedContexts = [NBULog orderedRegisteredContexts];
    [self restoreLogLevels];
    [self registerNib:[UINib nibWithNibName:@"PTEAdjustLevelsCell"
                                     bundle:nil] forCellReuseIdentifier:@"PTEAdjustLevelsCell"];
    self.dataSource = self;
}

#pragma mark - Save/load levels

- (void)saveLogLevels
{
    NSMutableArray * contextLevels = [NSMutableArray array];
    
    // Save each context level
    NSMutableDictionary * moduleLevels;
    for (NBULogContextDescription * context in _orderedContexts)
    {
        // And each module level
        moduleLevels = [NSMutableDictionary dictionary];
        for (NSNumber * module in context.orderedModules)
        {
            moduleLevels[module.description] = @(context.contextLevelForModule(module.intValue));
        }
        
        [contextLevels addObject:@{@"context"       : @(context.logContext),
                                   @"contextLevel"  : @(context.contextLevel()),
                                   @"modules"       : moduleLevels}];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:contextLevels
                                              forKey:@"PTEAdjustLevels"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)restoreLogLevels
{
    NSArray * contextLevels = [[NSUserDefaults standardUserDefaults] objectForKey:@"PTEAdjustLevels"];
    
    // Restore each context level
    int logContext;
    NBULogContextDescription * context;
    NSDictionary * moduleLevels;
    for (NSDictionary * contextDictionary in contextLevels)
    {
        logContext = ((NSNumber *)contextDictionary[@"context"]).intValue;
        
        // Get the context description, modules and levels
        context = nil;
        for (context  in _orderedContexts)
        {
            if (context.logContext == logContext)
                break;
        }
        
        if (!context)
            continue;
        
        // Set the context level
        context.setContextLevel(((NSNumber *)contextDictionary[@"contextLevel"]).intValue);
        
        // Set each module's level
        moduleLevels = contextDictionary[@"modules"];
        for (NSString * module in moduleLevels)
        {
            context.setContextLevelForModule(module.intValue, ((NSNumber *)moduleLevels[module]).intValue);
        }
    }
}

#pragma mark - Actions

- (IBAction)stepperValueChanged:(UIStepper *)sender
{
    NSIndexPath * indexPath = [self indexPathForRowAtPoint:[self convertPoint:sender.frame.origin
                                                                     fromView:sender.superview]];
    NBULogContextDescription * context = _orderedContexts[indexPath.section];
    
    // Get the log level
    int logLevel;
    switch ((int)sender.value)
    {
        case 5:
            logLevel = LOG_LEVEL_VERBOSE;
            break;
        case 4:
            logLevel = LOG_LEVEL_DEBUG;
            break;
        case 3:
            logLevel = LOG_LEVEL_INFO;
            break;
        case 2:
            logLevel = LOG_LEVEL_WARN;
            break;
        case 1:
            logLevel = LOG_LEVEL_ERROR;
            break;
        case 0:
        default:
            logLevel = LOG_LEVEL_OFF;
            break;
    }
    
    // Context cell
    if (indexPath.row == 0)
    {
        context.setContextLevel(logLevel);
    }
    
    // Module cell
    else
    {
        NSNumber * module = context.orderedModules[indexPath.row - 1];
        context.setContextLevelForModule(module.intValue, logLevel);
    }
    
    [self reloadData];
    [self saveLogLevels];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _orderedContexts.count;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    NBULogContextDescription * context = _orderedContexts[section];
    return context.modulesAndNames.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NBULogContextDescription * context = _orderedContexts[indexPath.section];
    PTEAdjustLevelsCell * cell = [tableView dequeueReusableCellWithIdentifier:@"PTEAdjustLevelsCell"];

    // Context cell
    if (indexPath.row == 0)
    {
        cell.nameLabel.text = context.name;
        cell.nameLabel.font = [UIFont boldSystemFontOfSize:17.0];
        cell.nameLabel.frame = CGRectMake(15.0,
                                          10.0,
                                          cell.nameLabel.frame.size.width,
                                          cell.nameLabel.frame.size.height);
        [self configureLevelLabel:cell.levelLabel
                       andStepper:cell.levelStepper
                         forLevel:context.contextLevel()];
    }
    
    // Module cell
    else
    {
        NSNumber * module = context.orderedModules[indexPath.row - 1];
        
        cell.nameLabel.text = context.modulesAndNames[module];
        cell.nameLabel.font = [UIFont systemFontOfSize:17.0];
        cell.nameLabel.frame = CGRectMake(30.0,
                                          10.0,
                                          cell.nameLabel.frame.size.width,
                                          cell.nameLabel.frame.size.height);
        [self configureLevelLabel:cell.levelLabel
                       andStepper:cell.levelStepper
                         forLevel:context.contextLevelForModule(module.intValue)];
    }
    
    return cell;
}

- (void)configureLevelLabel:(UILabel *)label
                 andStepper:(UIStepper *)stepper
                   forLevel:(int)level
{
    switch (level)
    {
        case LOG_LEVEL_ERROR:
        {
            label.text = @"Error level";
            label.textColor = [UIColor redColor];
            stepper.value = 1;
            break;
        }
        case LOG_LEVEL_WARN:
        {
            label.text = @"Warning level";
            label.textColor = [UIColor orangeColor];
            stepper.value = 2;
            break;
        }
        case LOG_LEVEL_INFO:
        {
            label.text = @"Info level";
            label.textColor = [UIColor greenColor];
            stepper.value = 3;
            break;
        }
        case LOG_LEVEL_DEBUG:
        {
            label.text = @"Debug level";
            label.textColor = [UIColor whiteColor];
            stepper.value = 4;
            break;
        }
        case LOG_LEVEL_VERBOSE:
        {
            label.text = @"Verbose level";
            label.textColor = [UIColor lightGrayColor];
            stepper.value = 5;
            break;
        }
        case LOG_LEVEL_OFF:
        default:
        {
            label.text = @"Logging off";
            label.textColor = [UIColor grayColor];
            stepper.value = 0;
            break;
        }
    }
}

@end


@implementation PTEAdjustLevelsCell

@end

#endif

