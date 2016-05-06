//
//  NBULog.m
//  NBULog
//
//  Created by Ernesto Rivera on 2012/12/06.
//  Copyright (c) 2012-2015 CyberAgent Inc.
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
#if __has_include(<LumberjackConsole/PTEDashboard.h>)
    #import <LumberjackConsole/PTEDashboard.h>
#endif

#define MAX_MODULES 20

static NSMutableDictionary * _registeredContexts;
static NSMutableArray * _orderedContexts;

static BOOL _forceSyncLogging;
static DDLogLevel _appLogLevel;
static DDLogLevel _appModuleLogLevel[MAX_MODULES];

@implementation NBULog

static id<DDLogFormatter> _nbuLogFormatter;

// Configure a formatter, default levels and add default loggers
+ (void)initialize
{
    if (self == [NBULog class])
    {
        // By defeault do not foce sync logging
        [self setForceSyncLogging:NO];
        
        // Default log level
        [self setAppLogLevel:LOG_LEVEL_DEFAULT];
        
        // Register the App log context
        [NBULog registerAppContextWithModulesAndNames:nil];
        
        // Default loggers
#ifdef DEBUG
        [self addTTYLogger];
#endif
    }
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

+ (BOOL)forceSyncLogging
{
    return _forceSyncLogging;
}

+ (void)setForceSyncLogging:(BOOL)yesOrNo
{
    _forceSyncLogging = yesOrNo;
}

+ (DDLogLevel)appLogLevel
{
    return _appLogLevel;
}

+ (void)setAppLogLevel:(DDLogLevel)logLevel
{
#ifdef DEBUG
    _appLogLevel = logLevel == LOG_LEVEL_DEFAULT ? DDLogLevelVerbose : logLevel;
#else
    _appLogLevel = logLevel == LOG_LEVEL_DEFAULT ? DDLogLevelInfo : logLevel;
#endif
    
    // Reset all modules' levels
    for (int i = 0; i < MAX_MODULES; i++)
    {
        [self setAppLogLevel:LOG_LEVEL_DEFAULT
                   forModule:i];
    }
}

+ (DDLogLevel)appLogLevelForModule:(int)APP_MODULE_XXX
{
    DDLogLevel logLevel = _appModuleLogLevel[APP_MODULE_XXX];
    
    // Fallback to the default log level if necessary
    return logLevel == LOG_LEVEL_DEFAULT ? _appLogLevel : logLevel;
}

+ (void)setAppLogLevel:(DDLogLevel)logLevel
             forModule:(int)APP_MODULE_XXX
{
    _appModuleLogLevel[APP_MODULE_XXX] = logLevel;
}

#pragma mark - Adding loggers

+ (void)addDashboardLogger
{
#if __has_include(<LumberjackConsole/PTEDashboard.h>)
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      [self restoreLogLevels];
                      [PTEDashboard.sharedDashboard show];
                  });
#else
    NBULogError(@"%@ Error: LumberjackConsole is required", THIS_METHOD);
#endif
}

+ (void)addASLLogger
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      DDASLLogger * logger = [DDASLLogger sharedInstance];
                      logger.logFormatter = [self nbuLogFormater];
                      [self addLogger:logger];
                  });
}

+ (void)addTTYLogger
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      DDTTYLogger * ttyLogger = [DDTTYLogger sharedInstance];
                      ttyLogger.logFormatter = [self nbuLogFormater];
                      [self addLogger:ttyLogger];
                      
                      // XcodeColors installed and enabled?
                      char *xcode_colors = getenv("XcodeColors");
                      if (xcode_colors && (strcmp(xcode_colors, "YES") == 0))
                      {
                          // Set default colors
                          [ttyLogger setForegroundColor:[DDColor colorWithRed:0.65
                                                                        green:0.65
                                                                         blue:0.65
                                                                        alpha:1.0]
                                        backgroundColor:nil
                                                forFlag:DDLogFlagVerbose];
                          [ttyLogger setForegroundColor:[DDColor colorWithRed:0.4
                                                                        green:0.4
                                                                         blue:0.4
                                                                        alpha:1.0]
                                        backgroundColor:nil
                                                forFlag:DDLogFlagDebug];
                          [ttyLogger setForegroundColor:[DDColor colorWithRed:26.0/255.0
                                                                        green:158.0/255.0
                                                                         blue:4.0/255.0
                                                                        alpha:1.0]
                                        backgroundColor:nil
                                                forFlag:DDLogFlagInfo];
                          [ttyLogger setForegroundColor:[DDColor colorWithRed:244.0/255.0
                                                                        green:103.0/255.0
                                                                         blue:8.0/255.0
                                                                        alpha:1.0]
                                        backgroundColor:nil
                                                forFlag:DDLogFlagWarning];
                          [ttyLogger setForegroundColor:[DDColor redColor]
                                        backgroundColor:nil
                                                forFlag:DDLogFlagError];
                          
                          // Enable colors
                          [ttyLogger setColorsEnabled:YES];
                      }
                  });
}

+ (void)addFileLogger
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      DDFileLogger * fileLogger = [DDFileLogger new];
                      fileLogger.logFileManager.maximumNumberOfLogFiles = 10;
                      fileLogger.logFormatter = [self nbuLogFormater];
                      [self addLogger:fileLogger];
                  });
}

#pragma mark - Registering custom log contexts

+ (void)registerAppContextWithModulesAndNames:(NSDictionary *)appContextModulesAndNames
{
    [self registerContextDescription:[NBULogContextDescription descriptionWithName:@"App"
                                                                           context:APP_LOG_CONTEXT
                                                                   modulesAndNames:appContextModulesAndNames
                                                                 contextLevelBlock:^{ return [NBULog appLogLevel]; }
                                                              setContextLevelBlock:^(DDLogLevel level) { [NBULog setAppLogLevel:level]; }
                                                        contextLevelForModuleBlock:^(int module) { return [NBULog appLogLevelForModule:module]; }
                                                     setContextLevelForModuleBlock:^(int module, DDLogLevel level) { [NBULog setAppLogLevel:level forModule:module]; }]];
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
        _orderedContexts = nil;
    }
}

+ (NSArray *)orderedRegisteredContexts
{
    if (!_orderedContexts)
    {
        _orderedContexts = [NSMutableArray array];
        for (id key in [_registeredContexts.allKeys sortedArrayUsingSelector:@selector(compare:)])
        {
            [_orderedContexts addObject:_registeredContexts[key]];
        }
    }
    return _orderedContexts;
}

#pragma mark - Saving and restoring log levels

+ (void)saveLogLevels
{
    NSMutableArray * contextLevels = [NSMutableArray array];
    
    // Save each context level
    NSMutableDictionary * moduleLevels;
    for (NBULogContextDescription * context in [self orderedRegisteredContexts])
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
                                              forKey:@"NBULogSavedLevels"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)restoreLogLevels
{
    NSArray * contextLevels = [[NSUserDefaults standardUserDefaults] objectForKey:@"NBULogSavedLevels"];
    
    // Restore each context level
    int logContext;
    NBULogContextDescription * context;
    NSDictionary * moduleLevels;
    for (NSDictionary * contextDictionary in contextLevels)
    {
        logContext = ((NSNumber *)contextDictionary[@"context"]).intValue;
        
        // Get the context description, modules and levels
        context = nil;
        for (context  in [self orderedRegisteredContexts])
        {
            if (context.logContext == logContext)
                break;
        }
        
        if (!context)
            continue;
        
        // Set the context level
        context.setContextLevel(((NSNumber *)contextDictionary[@"contextLevel"]).intValue);
        
        // Set each module's level
        if (!context.setContextLevelForModule)
            continue;
        moduleLevels = contextDictionary[@"modules"];
        for (NSString * module in moduleLevels)
        {
            context.setContextLevelForModule(module.intValue, ((NSNumber *)moduleLevels[module]).intValue);
        }
    }
}

@end

