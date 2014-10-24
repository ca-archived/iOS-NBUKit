//
//  NBULog+NBUKit.h
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/12/12.
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

#if __has_include("NBULog.h")

#import <NBULog/NBULog.h>

/// NBUKit log context
#define NBUKIT_LOG_CONTEXT          110

/// NBUKit modules
#define NBUKIT_MODULE_DEFAULT       0

/**
 NBULog category used to set/get NBUKit log levels.
 
 Default configuration (can be dynamically changed):
 
 - Log level: `DDLogLevelInfo` for `DEBUG`, `DDLogLevelWarning` otherwise.
 
 */
@interface NBULog (NBUKit)

/// @name Adjusting NBUKit Log Levels

/// The current NBUKit log level.
+ (DDLogLevel)kitLogLevel;

/// Dynamically set the NBUKit log level for all modules at once.
/// @param logLevel The desired log level.
/// @note Setting this value clears all modules' levels.
+ (void)setKitLogLevel:(DDLogLevel)logLevel;

@end

#endif

