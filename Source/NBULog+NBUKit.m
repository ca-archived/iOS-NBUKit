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

#define MAX_MODULES 10

static int _kitLogLevel[MAX_MODULES];

@implementation NBULog (NBUKit)

+ (void)load
{
    // Default levels
#ifdef DEBUG
    [self setKitLogLevel:LOG_LEVEL_INFO];
#else
    [self setKitLogLevel:LOG_LEVEL_WARN];
#endif
}

+ (void)setKitLogLevel:(int)LOG_LEVEL_XXX
{
    for (int i = 0; i < MAX_MODULES; i++)
    {
        _kitLogLevel[i] = LOG_LEVEL_XXX;
    }
}

+ (void)setKitLogLevel:(int)LOG_LEVEL_XXX
             forModule:(int)NBUKIT_MODULE_XXX
{
    _kitLogLevel[NBUKIT_MODULE_XXX] = LOG_LEVEL_XXX;
}

+ (int)kitLogLevelForModule:(int)NBUKIT_MODULE_XXX
{
    return _kitLogLevel[NBUKIT_MODULE_XXX];
}

@end

