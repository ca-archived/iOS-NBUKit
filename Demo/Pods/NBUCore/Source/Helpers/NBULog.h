//
//  NBULog.h
//  NBUCore
//
//  Created by Ernesto Rivera on 2012/12/06.
//  Copyright (c) 2012-2013 CyberAgent Inc.
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

#import <CocoaLumberjack/DDLog.h>

/// Extensible default contexts
#define APP_LOG_CONTEXT     0

/// App modules
/// Define more in your Prefix.pch file if needed (max 20 modules).
/// Ex.:    #define APP_MODULE_NETWORK  1
#define APP_MODULE_DEFAULT  0

/// By default all files will be in the "Default" module.
/// Change the module of any file by redefining `APP_MODULE` at
/// the beginning of the implementation file. Ex.:
///     #undef APP_MODULE
///     #define APP_MODULE APP_MODULE_NETWORK
#define APP_MODULE          APP_MODULE_DEFAULT

/// Dynamic levels
#define APP_LOG_LEVEL       [NBULog appLogLevelForModule:APP_MODULE]

/// Log level used to clear modules' log levels
#define LOG_LEVEL_DEFAULT   -1

/// Remove NSLog from non DEBUG builds
#ifndef DEBUG
    #define NSLog(...)
#endif

/// Log with the currently defined APP_MODULE
#define NBULogError(frmt, ...)  LOG_OBJC_MAYBE(LOG_ASYNC_ERROR,   APP_LOG_LEVEL, LOG_FLAG_ERROR,    APP_LOG_CONTEXT + APP_MODULE, frmt, ##__VA_ARGS__)
#define NBULogWarn(frmt, ...)   LOG_OBJC_MAYBE(LOG_ASYNC_WARN,    APP_LOG_LEVEL, LOG_FLAG_WARN,     APP_LOG_CONTEXT + APP_MODULE, frmt, ##__VA_ARGS__)
#define NBULogInfo(frmt, ...)   LOG_OBJC_MAYBE(LOG_ASYNC_INFO,    APP_LOG_LEVEL, LOG_FLAG_INFO,     APP_LOG_CONTEXT + APP_MODULE, frmt, ##__VA_ARGS__)
#define NBULogVerbose(frmt, ...)LOG_OBJC_MAYBE(LOG_ASYNC_VERBOSE, APP_LOG_LEVEL, LOG_FLAG_VERBOSE,  APP_LOG_CONTEXT + APP_MODULE, frmt, ##__VA_ARGS__)
#define NBULogTrace()           NBULogVerbose(@"[%p] %@", self, THIS_METHOD)

/// Log with specific module that may be different from the currently defined APP_MODULE
#define NBULogErrorForModule(mod, frmt, ...)    LOG_OBJC_MAYBE(LOG_ASYNC_ERROR,   APP_LOG_LEVEL, LOG_FLAG_ERROR,    APP_LOG_CONTEXT + mod, frmt, ##__VA_ARGS__)
#define NBULogWarnForModule(mod, frmt, ...)     LOG_OBJC_MAYBE(LOG_ASYNC_WARN,    APP_LOG_LEVEL, LOG_FLAG_WARN,     APP_LOG_CONTEXT + mod, frmt, ##__VA_ARGS__)
#define NBULogInfoForModule(mod, frmt, ...)     LOG_OBJC_MAYBE(LOG_ASYNC_INFO,    APP_LOG_LEVEL, LOG_FLAG_INFO,     APP_LOG_CONTEXT + mod, frmt, ##__VA_ARGS__)
#define NBULogVerboseForModule(mod, frmt, ...)  LOG_OBJC_MAYBE(LOG_ASYNC_VERBOSE, APP_LOG_LEVEL, LOG_FLAG_VERBOSE,  APP_LOG_CONTEXT + mod, frmt, ##__VA_ARGS__)
#define NBULogTraceForModule(mod)               NBULogVerboseForModule(mod, @"[%p] %@", self, THIS_METHOD)

/**
 DDLog wrapper. Use it to set/get App log levels for debug or testing builds.
 
 Default configuration (can be dynamically changed):
 
 - AppLogLevel: `LOG_LEVEL_VERBOSE` for `DEBUG`, `LOG_LEVEL_INFO` otherwise.
 - Loggers: DDTTYLogger for `DEBUG`, DDFileLogger otherwise.
 
 Manually add NBUDashboard, DDTTYLogger, DDASLLogger or DDFileLogger if desired.
 
 To add register new modules just create a NBULog category.
 */
@interface NBULog : DDLog

/// @name Adjusting App Log Levels

/// Get the current App log level.
+ (int)appLogLevel;

/// Dynamically set the App log level for all modules at once.
/// @param LOG_LEVEL_XXX The desired log level.
/// @note Setting this value clears all modules' levels.
+ (void)setAppLogLevel:(int)LOG_LEVEL_XXX;

/// Get the current App log level for a given module.
/// @param APP_MODULE_XXX The target module.
+ (int)appLogLevelForModule:(int)APP_MODULE_XXX;

/// Dynamically set the App log level for a given module.
/// @param LOG_LEVEL_XXX The desired log level.
/// @param APP_MODULE_XXX The target module.
+ (void)setAppLogLevel:(int)LOG_LEVEL_XXX
             forModule:(int)APP_MODULE_XXX;

/// @name Adding Loggers

/// Configure and add a NBUDashboardLogger.
/// @note To be used for testing builds only.
+ (void)addDashboardLogger;

/// Configure and add a DDASLLogger (Apple System Log). Not needed in most cases.
/// @note To be used for testing builds only.
+ (void)addASLLogger;

/// Configure and add a DDTTYLogger (Apple System Log and Xcode console). Not needed in most cases.
/// @note To be used for testing builds only.
+ (void)addTTYLogger;

/// Configure and add a DDFileLogger (log to a file).
/// @note Added by default for non debug builds.
+ (void)addFileLogger;

@end


@class NBULogContextDescription;

/**
 */
@interface NBULog (NBULogContextDescription)

+ (void)registerAppContextWithModulesAndNames:(NSDictionary *)appContextModulesAndNames;
+ (void)registerContextDescription:(NBULogContextDescription *)contextDescription;
+ (NSArray *)orderedRegisteredContexts;

@end


/**
 NBULog category used to set/get NBUCore log levels.
 
 Default configuration (can be dynamically changed):
 
 - Log level: `LOG_LEVEL_INFO` for `DEBUG`, `LOG_LEVEL_WARN` otherwise.
 
 */
@interface NBULog (NBUCore)

/// @name Adjusting NBUCore Log Levels

/// Get the current NBUCore log level.
+ (int)coreLogLevel;

/// Dynamically set the NBUCore log level for all modules at once.
/// @param LOG_LEVEL_XXX The desired log level.
+ (void)setCoreLogLevel:(int)LOG_LEVEL_XXX;

@end

