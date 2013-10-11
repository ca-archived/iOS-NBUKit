//
//  NBULog+NBUKit.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/12/12.
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

#import "NBULog+NBUKit.h"
#import "NBUKitPrivate.h"
#import <NBUCore/NBULogContextDescription.h>

#define MAX_MODULES 10

static int _kitLogLevel;
static int _kitModulesLogLevel[MAX_MODULES];

@implementation NBULog (NBUKit)

+ (void)load
{
    // Default levels
    [self setKitLogLevel:LOG_LEVEL_DEFAULT];
    
    // Register the NBUKit log context
    [NBULog registerContextDescription:[NBULogContextDescription descriptionWithName:@"NBUKit"
                                                                             context:NBUKIT_LOG_CONTEXT
                                                                     modulesAndNames:@{@(NBUKIT_MODULE_UI)              : @"UI",
                                                                                       @(NBUKIT_MODULE_CAMERA_ASSETS)   : @"Camera/Assets",
                                                                                       @(NBUKIT_MODULE_IMAGE)           : @"Image",
                                                                                       @(NBUKIT_MODULE_HELPERS)         : @"Helpers",
                                                                                       @(NBUKIT_MODULE_COMPATIBILITY)   : @"Compatibility"}
                                                                   contextLevelBlock:^{ return [NBULog kitLogLevel]; }
                                                                setContextLevelBlock:^(int level) { [NBULog setKitLogLevel:level]; }
                                                          contextLevelForModuleBlock:^(int module) { return [NBULog kitLogLevelForModule:module]; }
                                                       setContextLevelForModuleBlock:^(int module, int level) { [NBULog setKitLogLevel:level forModule:module]; }]];
}

+ (int)kitLogLevel
{
    return _kitLogLevel;
}

+ (void)setKitLogLevel:(int)LOG_LEVEL_XXX
{
#ifdef DEBUG
    _kitLogLevel = LOG_LEVEL_XXX == LOG_LEVEL_DEFAULT ? LOG_LEVEL_INFO : LOG_LEVEL_XXX;
#else
    _kitLogLevel = LOG_LEVEL_XXX == LOG_LEVEL_DEFAULT ? LOG_LEVEL_WARN : LOG_LEVEL_XXX;
#endif
    
    // Reset all modules' levels
    for (int i = 0; i < MAX_MODULES; i++)
    {
        [self setKitLogLevel:LOG_LEVEL_DEFAULT
                   forModule:i];
    }
}

+ (int)kitLogLevelForModule:(int)NBUKIT_MODULE_XXX
{
    int logLevel = _kitModulesLogLevel[NBUKIT_MODULE_XXX];
    
    // Fallback to the default log level if necessary
    return logLevel == LOG_LEVEL_DEFAULT ? _kitLogLevel : logLevel;
}

+ (void)setKitLogLevel:(int)LOG_LEVEL_XXX
             forModule:(int)NBUKIT_MODULE_XXX
{
    _kitModulesLogLevel[NBUKIT_MODULE_XXX] = LOG_LEVEL_XXX;
}

@end

