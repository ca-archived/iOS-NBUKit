//
//  PTEAdjustLevelsTableView.m
//  LumberjackConsole
//
//  Created by Ernesto Rivera on 2013/10/09.
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

#if __has_include("NBULog.h")

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
    [NBULog restoreLogLevels];
    self.dataSource = self;
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
            logLevel = DDLogLevelVerbose;
            break;
        case 4:
            logLevel = DDLogLevelDebug;
            break;
        case 3:
            logLevel = DDLogLevelInfo;
            break;
        case 2:
            logLevel = DDLogLevelWarning;
            break;
        case 1:
            logLevel = DDLogLevelError;
            break;
        case 0:
        default:
            logLevel = DDLogLevelOff;
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
    [NBULog saveLogLevels];
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
                   forLevel:(DDLogLevel)level
{
    switch (level)
    {
        case DDLogLevelError:
        {
            label.text = @"Error level";
            label.textColor = [UIColor redColor];
            stepper.value = 1;
            break;
        }
        case DDLogLevelWarning:
        {
            label.text = @"Warning level";
            label.textColor = [UIColor orangeColor];
            stepper.value = 2;
            break;
        }
        case DDLogLevelInfo:
        {
            label.text = @"Info level";
            label.textColor = [UIColor greenColor];
            stepper.value = 3;
            break;
        }
        case DDLogLevelDebug:
        {
            label.text = @"Debug level";
            label.textColor = [UIColor whiteColor];
            stepper.value = 4;
            break;
        }
        case DDLogLevelVerbose:
        {
            label.text = @"Verbose level";
            label.textColor = [UIColor lightGrayColor];
            stepper.value = 5;
            break;
        }
        case DDLogLevelOff:
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

