//
//  NBULog+NBUKit.m
//  NBUKit
//
//  Created by 利辺羅 on 2012/12/12.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
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

