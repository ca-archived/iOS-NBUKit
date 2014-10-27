//
//  NBULog.h
//  NBULog
//
//  Created by Ernesto Rivera on 2012/12/06.
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

#import <CocoaLumberjack/DDLog.h>

/// Extensible default contexts
#define APP_LOG_CONTEXT     0

/// By default we log with the "App" context.
/// Change this in 3rd party libraries.
#define LOG_CONTEXT         APP_LOG_CONTEXT

/// App modules
/// Define more in your Prefix.pch file if needed (max 20 modules).
/// Ex.:    #define APP_MODULE_NETWORK  1
#define APP_MODULE_DEFAULT  0

/// By default all files will be in the "Default" module.
/// Change the module of any file by redefining `LOG_MODULE` at
/// the beginning of the implementation file. Ex.:
///     #undef  LOG_MODULE
///     #define LOG_MODULE  APP_MODULE_NETWORK
#define LOG_MODULE          APP_MODULE_DEFAULT

/// Dynamic log levels
#define LOG_LEVEL                   [NBULog appLogLevelForModule:LOG_MODULE]
#define LOG_LEVEL_FOR_MODULE(mod)   [NBULog appLogLevelForModule:mod]

/// Log level used to clear modules' log levels
#define LOG_LEVEL_DEFAULT   NSUIntegerMax

/// Remove NSLog from non DEBUG builds
#ifndef DEBUG
    #define NSLog(...)
#endif

/// Async/sync logging
#define NBULOG_ASYNC_ERROR    ( NO && LOG_ASYNC_ENABLED)
#define NBULOG_ASYNC_WARN     (![NBULog forceSyncLogging] && LOG_ASYNC_ENABLED)
#define NBULOG_ASYNC_INFO     (![NBULog forceSyncLogging] && LOG_ASYNC_ENABLED)
#define NBULOG_ASYNC_DEBUG    (![NBULog forceSyncLogging] && LOG_ASYNC_ENABLED)
#define NBULOG_ASYNC_VERBOSE  (![NBULog forceSyncLogging] && LOG_ASYNC_ENABLED)

/// Log with the currently defined LOG_CONTEXT + LOG_MODULE
#define NBULogError(frmt, ...)   LOG_OBJC_MAYBE(NBULOG_ASYNC_ERROR,   LOG_LEVEL, DDLogFlagError,   LOG_CONTEXT + LOG_MODULE, frmt, ##__VA_ARGS__)
#define NBULogWarn(frmt, ...)    LOG_OBJC_MAYBE(NBULOG_ASYNC_WARN,    LOG_LEVEL, DDLogFlagWarning,    LOG_CONTEXT + LOG_MODULE, frmt, ##__VA_ARGS__)
#define NBULogInfo(frmt, ...)    LOG_OBJC_MAYBE(NBULOG_ASYNC_INFO,    LOG_LEVEL, DDLogFlagInfo,    LOG_CONTEXT + LOG_MODULE, frmt, ##__VA_ARGS__)
#define NBULogDebug(frmt, ...)   LOG_OBJC_MAYBE(NBULOG_ASYNC_DEBUG,   LOG_LEVEL, DDLogFlagDebug,   LOG_CONTEXT + LOG_MODULE, frmt, ##__VA_ARGS__)
#define NBULogVerbose(frmt, ...) LOG_OBJC_MAYBE(NBULOG_ASYNC_VERBOSE, LOG_LEVEL, DDLogFlagVerbose, LOG_CONTEXT + LOG_MODULE, frmt, ##__VA_ARGS__)
#define NBULogTrace()            NBULogDebug(@"%s", __PRETTY_FUNCTION__)

/// Log with specific module that may be different from the currently defined LOG_MODULE
#define NBULogErrorWithModule(mod, frmt, ...)   LOG_OBJC_MAYBE(NBULOG_ASYNC_ERROR,   LOG_LEVEL_FOR_MODULE(mod), DDLogFlagError,   LOG_CONTEXT + mod, frmt, ##__VA_ARGS__)
#define NBULogWarnWithModule(mod, frmt, ...)    LOG_OBJC_MAYBE(NBULOG_ASYNC_WARN,    LOG_LEVEL_FOR_MODULE(mod), DDLogFlagWarning,    LOG_CONTEXT + mod, frmt, ##__VA_ARGS__)
#define NBULogInfoWithModule(mod, frmt, ...)    LOG_OBJC_MAYBE(NBULOG_ASYNC_INFO,    LOG_LEVEL_FOR_MODULE(mod), DDLogFlagInfo,    LOG_CONTEXT + mod, frmt, ##__VA_ARGS__)
#define NBULogDebugWithModule(mod, frmt, ...)   LOG_OBJC_MAYBE(NBULOG_ASYNC_DEBUG,   LOG_LEVEL_FOR_MODULE(mod), DDLogFlagDebug,   LOG_CONTEXT + mod, frmt, ##__VA_ARGS__)
#define NBULogVerboseWithModule(mod, frmt, ...) LOG_OBJC_MAYBE(NBULOG_ASYNC_VERBOSE, LOG_LEVEL_FOR_MODULE(mod), DDLogFlagVerbose, LOG_CONTEXT + mod, frmt, ##__VA_ARGS__)
#define NBULogTraceWithModule(mod)              NBULogDebugForModule(mod, @"%@", THIS_METHOD)

// Assertions
#define NBUAssert(condition, frmt, ...) if (!(condition)) {                                                           \
                                            NSString * description = [NSString stringWithFormat:frmt, ##__VA_ARGS__]; \
                                            NBULogError(@"%@", description);                                          \
                                            NSAssert(NO, description); }
#define NBUAssertCondition(condition) NBUAssert(condition, @"Condition not satisfied: %s", #condition)

@class NBULogContextDescription;

/**
 DDLog wrapper. Use it to set/get App log levels for debug or testing builds.
 
 Default configuration (can be dynamically changed):
 
 - AppLogLevel: `DDLogLevelVerbose` for `DEBUG`, `DDLogLevelInfo` otherwise.
 - Loggers: DDTTYLogger for `DEBUG`, DDFileLogger otherwise.
 
 Manually add NBUDashboard, DDTTYLogger, DDASLLogger or DDFileLogger if desired.
 
 To register new modules just create a NBULog category.
 */
@interface NBULog : DDLog

/// @name Forcing Synchronous Logging

/// Whether logging should be forced to be synchronous. Default `NO`.
+ (BOOL)forceSyncLogging;

/// Set whether logging should be forced to be synchronous.
+ (void)setForceSyncLogging:(BOOL)yesOrNo;

/// @name Adjusting App Log Levels

/// Get the current App log level.
+ (DDLogLevel)appLogLevel;

/// Dynamically set the App log level for all modules at once.
/// @param logLevel The desired log level.
/// @note Setting this value clears all modules' levels.
+ (void)setAppLogLevel:(DDLogLevel)logLevel;

/// Get the current App log level for a given module.
/// @param APP_MODULE_XXX The target module.
+ (DDLogLevel)appLogLevelForModule:(int)APP_MODULE_XXX;

/// Dynamically set the App log level for a given module.
/// @param logLevel The desired log level.
/// @param APP_MODULE_XXX The target module.
+ (void)setAppLogLevel:(DDLogLevel)logLevel
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

/// @name Saving and Restoring Log Levels

/// Save the current log leves configuration to NSUserDefaults.
+ (void)saveLogLevels;

/// Restore log leves from NSUserDefaults.
+ (void)restoreLogLevels;

@end

