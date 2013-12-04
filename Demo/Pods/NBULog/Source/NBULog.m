//
//  NBULog.m
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

#import "NBULog.h"
#import "NBULogFormatter.h"
#import "NBULogContextDescription.h"
#import <CocoaLumberjack/DDTTYLogger.h>
#import <CocoaLumberjack/DDFileLogger.h>
#import <CocoaLumberjack/DDASLLogger.h>
#ifdef COCOAPODS_POD_AVAILABLE_LumberjackConsole
    #import <LumberjackConsole/PTEDashboard.h>
#endif

#define MAX_MODULES 20

static NSMutableDictionary * _registeredContexts;

static int _appLogLevel;
static int _appModuleLogLevel[MAX_MODULES];

@implementation NBULog

static id<DDLogFormatter> _nbuLogFormatter;
static BOOL _ttyLoggerAdded;
static BOOL _aslLoggerAdded;
static BOOL _fileLoggerAdded;

// Configure a formatter, default levels and add default loggers
+ (void)initialize
{
    // Default log level
    [self setAppLogLevel:LOG_LEVEL_DEFAULT];
    
    // Register the App log context
    [NBULog registerAppContextWithModulesAndNames:nil];
    
    // Default loggers
#ifdef DEBUG
    [self addTTYLogger];
#endif

}

+ (id<DDLogFormatter>)nbuLogFormater
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        _nbuLogFormatter = [NBULogFormatter new];
    });
    return _nbuLogFormatter;
}

+ (int)appLogLevel
{
    return _appLogLevel;
}

+ (void)setAppLogLevel:(int)LOG_LEVEL_XXX
{
#ifdef DEBUG
    _appLogLevel = LOG_LEVEL_XXX == LOG_LEVEL_DEFAULT ? LOG_LEVEL_VERBOSE : LOG_LEVEL_XXX;
#else
    _appLogLevel = LOG_LEVEL_XXX == LOG_LEVEL_DEFAULT ? LOG_LEVEL_INFO : LOG_LEVEL_XXX;
#endif
    
    // Reset all modules' levels
    for (int i = 0; i < MAX_MODULES; i++)
    {
        [self setAppLogLevel:LOG_LEVEL_DEFAULT
                   forModule:i];
    }
}

+ (int)appLogLevelForModule:(int)APP_MODULE_XXX
{
    int logLevel = _appModuleLogLevel[APP_MODULE_XXX];
    
    // Fallback to the default log level if necessary
    return logLevel == LOG_LEVEL_DEFAULT ? _appLogLevel : logLevel;
}

+ (void)setAppLogLevel:(int)LOG_LEVEL_XXX
             forModule:(int)APP_MODULE_XXX
{
    _appModuleLogLevel[APP_MODULE_XXX] = LOG_LEVEL_XXX;
}

#pragma mark - Adding loggers

+ (void)addDashboardLogger
{
#ifdef COCOAPODS_POD_AVAILABLE_LumberjackConsole
    static BOOL _dashboardLoggerAdded = NO;
    if (_dashboardLoggerAdded)
        return;
    
    [self addLogger:[PTEDashboard sharedDashboard].logger];
    
    _dashboardLoggerAdded = YES;
#else
    NBULogError(@"%@ error: LumberjackConsole is required", THIS_METHOD);
#endif
}

+ (void)addASLLogger
{
    if (_aslLoggerAdded)
        return;
    
    DDASLLogger * logger = [DDASLLogger sharedInstance];
    logger.logFormatter = [self nbuLogFormater];
    [self addLogger:logger];
    
    _aslLoggerAdded = YES;
}

+ (void)addTTYLogger
{
    if (_ttyLoggerAdded)
        return;
    
    DDTTYLogger * ttyLogger = [DDTTYLogger sharedInstance];
    ttyLogger.logFormatter = [self nbuLogFormater];
    [self addLogger:ttyLogger];
    
    // XcodeColors installed and enabled?
    char *xcode_colors = getenv("XcodeColors");
    if (xcode_colors && (strcmp(xcode_colors, "YES") == 0))
    {
        // Set default colors
        [ttyLogger setForegroundColor:[UIColor colorWithRed:0.65
                                                      green:0.65
                                                       blue:0.65
                                                      alpha:1.0]
                      backgroundColor:nil
                              forFlag:LOG_FLAG_VERBOSE];
        [ttyLogger setForegroundColor:[UIColor colorWithRed:0.4
                                                      green:0.4
                                                       blue:0.4
                                                      alpha:1.0]
                      backgroundColor:nil
                              forFlag:LOG_FLAG_DEBUG];
        [ttyLogger setForegroundColor:[UIColor colorWithRed:26.0/255.0
                                                      green:158.0/255.0
                                                       blue:4.0/255.0
                                                      alpha:1.0]
                      backgroundColor:nil
                              forFlag:LOG_FLAG_INFO];
        [ttyLogger setForegroundColor:[UIColor colorWithRed:244.0/255.0
                                                      green:103.0/255.0
                                                       blue:8.0/255.0
                                                      alpha:1.0]
                      backgroundColor:nil
                              forFlag:LOG_FLAG_WARN];
        [ttyLogger setForegroundColor:[UIColor redColor]
                      backgroundColor:nil
                              forFlag:LOG_FLAG_ERROR];
        
        // Enable colors
        [ttyLogger setColorsEnabled:YES];
    }
    
    _ttyLoggerAdded = YES;
}

+ (void)addFileLogger
{
    if (_fileLoggerAdded)
        return;
    
    DDFileLogger * fileLogger = [DDFileLogger new];
    fileLogger.logFileManager.maximumNumberOfLogFiles = 10;
    fileLogger.logFormatter = [self nbuLogFormater];
    [self addLogger:fileLogger];
    
    _fileLoggerAdded = YES;
}

#pragma mark - Registering custom log contexts

+ (void)registerAppContextWithModulesAndNames:(NSDictionary *)appContextModulesAndNames
{
    [self registerContextDescription:[NBULogContextDescription descriptionWithName:@"App"
                                                                           context:APP_LOG_CONTEXT
                                                                   modulesAndNames:appContextModulesAndNames
                                                                 contextLevelBlock:^{ return [NBULog appLogLevel]; }
                                                              setContextLevelBlock:^(int level) { [NBULog setAppLogLevel:level]; }
                                                        contextLevelForModuleBlock:^(int module) { return [NBULog appLogLevelForModule:module]; }
                                                     setContextLevelForModuleBlock:^(int module, int level) { [NBULog setAppLogLevel:level forModule:module]; }]];
}

+ (void)registerContextDescription:(NBULogContextDescription *)contextDescription
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      _registeredContexts = [NSMutableDictionary dictionary];
                  });
    
    @synchronized(self)
    {
        [_registeredContexts setObject:contextDescription
                                forKey:@(contextDescription.logContext)]; // Can't use subscript here on iOS 5 because this method gets called from +(void)load methods
    }
}

+ (NSArray *)orderedRegisteredContexts
{
    NSMutableArray * orderedContexts = [NSMutableArray array];
    for (id key in [_registeredContexts.allKeys sortedArrayUsingSelector:@selector(compare:)])
    {
        [orderedContexts addObject:_registeredContexts[key]];
    }
    return orderedContexts;
}

@end

