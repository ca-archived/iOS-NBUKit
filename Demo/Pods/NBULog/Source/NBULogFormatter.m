//
//  NBULogFormatter.m
//  NBULog
//
//  Created by Ernesto Rivera on 2013/11/12.
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

#import "NBULogFormatter.h"

static NSString * _processName;

@implementation NBULogFormatter

+ (void)initialize
{
    _processName = [[NSProcessInfo processInfo] processName];
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    // One-charecter log level
    NSString * logLevel;
    switch (logMessage->logFlag)
    {
        case LOG_FLAG_ERROR : logLevel = @"E"; break;
        case LOG_FLAG_WARN  : logLevel = @"W"; break;
        case LOG_FLAG_INFO  : logLevel = @"I"; break;
        case LOG_FLAG_DEBUG : logLevel = @"D"; break;
        default             : logLevel = @"V"; break;
    }
    
    return [NSString stringWithFormat:@"%@ %@[%@] %@ %@:%d %@",
            [self stringFromDate:(logMessage->timestamp)],
            _processName,
            [self queueThreadLabelForLogMessage:logMessage],
            logLevel,
            logMessage.fileName,
            logMessage->lineNumber,
            logMessage->logMsg];
}

@end

