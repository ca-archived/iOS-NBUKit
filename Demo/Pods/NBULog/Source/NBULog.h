//
//  NBULog.h
//  NBULog
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
///     #undef  APP_MODULE
///     #define APP_MODULE  APP_MODULE_NETWORK
#define APP_MODULE          APP_MODULE_DEFAULT

/// Dynamic levels
#define APP_LOG_LEVEL                   [NBULog appLogLevelForModule:APP_MODULE]
#define APP_LOG_LEVEL_FOR_MODULE(mod)   [NBULog appLogLevelForModule:mod]

/// Log level used to clear modules' log levels
#define LOG_LEVEL_DEFAULT   -1

/// Remove NSLog from non DEBUG builds
#ifndef DEBUG
    #define NSLog(...)
#endif

/// Log with the currently defined APP_MODULE
#define NBULogError(frmt, ...)  LOG_OBJC_MAYBE(LOG_ASYNC_ERROR,     APP_LOG_LEVEL, LOG_FLAG_ERROR,      APP_LOG_CONTEXT + APP_MODULE, frmt, ##__VA_ARGS__)
#define NBULogWarn(frmt, ...)   LOG_OBJC_MAYBE(LOG_ASYNC_WARN,      APP_LOG_LEVEL, LOG_FLAG_WARN,       APP_LOG_CONTEXT + APP_MODULE, frmt, ##__VA_ARGS__)
#define NBULogInfo(frmt, ...)   LOG_OBJC_MAYBE(LOG_ASYNC_INFO,      APP_LOG_LEVEL, LOG_FLAG_INFO,       APP_LOG_CONTEXT + APP_MODULE, frmt, ##__VA_ARGS__)
#define NBULogDebug(frmt, ...)  LOG_OBJC_MAYBE(LOG_ASYNC_DEBUG,     APP_LOG_LEVEL, LOG_FLAG_DEBUG,      APP_LOG_CONTEXT + APP_MODULE, frmt, ##__VA_ARGS__)
#define NBULogVerbose(frmt, ...)LOG_OBJC_MAYBE(LOG_ASYNC_VERBOSE,   APP_LOG_LEVEL, LOG_FLAG_VERBOSE,    APP_LOG_CONTEXT + APP_MODULE, frmt, ##__VA_ARGS__)
#define NBULogTrace()           NBULogDebug(@"%@", THIS_METHOD)

/// Log with specific module that may be different from the currently defined APP_MODULE
#define NBULogErrorWithModule(mod, frmt, ...)   LOG_OBJC_MAYBE(LOG_ASYNC_ERROR,     APP_LOG_LEVEL_FOR_MODULE(mod), LOG_FLAG_ERROR,      APP_LOG_CONTEXT + mod, frmt, ##__VA_ARGS__)
#define NBULogWarnWithModule(mod, frmt, ...)    LOG_OBJC_MAYBE(LOG_ASYNC_WARN,      APP_LOG_LEVEL_FOR_MODULE(mod), LOG_FLAG_WARN,       APP_LOG_CONTEXT + mod, frmt, ##__VA_ARGS__)
#define NBULogInfoWithModule(mod, frmt, ...)    LOG_OBJC_MAYBE(LOG_ASYNC_INFO,      APP_LOG_LEVEL_FOR_MODULE(mod), LOG_FLAG_INFO,       APP_LOG_CONTEXT + mod, frmt, ##__VA_ARGS__)
#define NBULogDebugWithModule(mod, frmt, ...)   LOG_OBJC_MAYBE(LOG_ASYNC_DEBUG,     APP_LOG_LEVEL_FOR_MODULE(mod), LOG_FLAG_DEBUG,      APP_LOG_CONTEXT + mod, frmt, ##__VA_ARGS__)
#define NBULogVerboseWithModule(mod, frmt, ...) LOG_OBJC_MAYBE(LOG_ASYNC_VERBOSE,   APP_LOG_LEVEL_FOR_MODULE(mod), LOG_FLAG_VERBOSE,    APP_LOG_CONTEXT + mod, frmt, ##__VA_ARGS__)
#define NBULogTraceWithModule(mod)              NBULogDebugForModule(mod, @"%@", THIS_METHOD)

@class NBULogContextDescription;

/**
 DDLog wrapper. Use it to set/get App log levels for debug or testing builds.
 
 Default configuration (can be dynamically changed):
 
 - AppLogLevel: `LOG_LEVEL_VERBOSE` for `DEBUG`, `LOG_LEVEL_INFO` otherwise.
 - Loggers: DDTTYLogger for `DEBUG`, DDFileLogger otherwise.
 
 Manually add NBUDashboard, DDTTYLogger, DDASLLogger or DDFileLogger if desired.
 
 To register new modules just create a NBULog category.
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

/// Configures and add a PTEDashboard with a console logger.
/// @note Requires LumberjackConsole and should be used for testing builds only.
+ (void)addDashboardLogger;

/// Configure and add a DDASLLogger (Apple System Log). Not needed in most cases.
/// @note To be used for testing builds only.
+ (void)addASLLogger;

/// Configure and add a DDTTYLogger (Apple System Log and Xcode console). Not needed in most cases.
/// @discussion Will enable console colors if XcodeColors is installed.
/// @note To be used for testing builds only.
+ (void)addTTYLogger;

/// Configure and add a DDFileLogger (log to a file).
/// @note Added by default for non debug builds.
+ (void)addFileLogger;

/// @name Registering Custom Log Contexts

/// Register custom App log module constants with descriptive names.
/// @param appContextModulesAndNames A dictionary of module constants and their descriptive names.
/// @discussion Sample code:
///
///     #define APP_MODULE_NETWORK  1 // APP_MODULE_DEFAULT = 0
///     #define APP_MODULE_OTHER    2
///
///     [NBULog registerAppContextWithModulesAndNames:@{@(APP_MODULE_NETWORK)   : @"Network",
///                                                     @(APP_MODULE_OTHER)     : @"Other"}];
+ (void)registerAppContextWithModulesAndNames:(NSDictionary *)appContextModulesAndNames;

/// Register a third party framwork's log context.
/// @param contextDescription The log context description.
+ (void)registerContextDescription:(NBULogContextDescription *)contextDescription;

/// An ordered array of all registered contexts.
+ (NSArray *)orderedRegisteredContexts;

@end

