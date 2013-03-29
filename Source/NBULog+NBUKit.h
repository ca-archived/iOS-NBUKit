//
//  NBULog+NBUKit.h
//  NBUKit
//
//  Created by 利辺羅 on 2012/12/12.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import "NBULog.h"

/// NBUKit log context
#define NBUKIT_LOG_CONTEXT          110

/// NBUKit modules
#define NBUKIT_MODULE_GENERAL       0
#define NBUKIT_MODULE_UI            1
#define NBUKIT_MODULE_CAMERA_ASSETS 2
#define NBUKIT_MODULE_IMAGE         3
#define NBUKIT_MODULE_HELPERS       4
#define NBUKIT_MODULE_COMPATIBILITY 9

/**
 NBULog category used to set/get NBUKit log levels.
 
 Default configuration (can be dynamically changed):
 
 - Log level: `LOG_LEVEL_INFO` for `DEBUG`, `LOG_LEVEL_WARN` otherwise.
 
 */
@interface NBULog (NBUKit)

/// @name Adjusting NBUKit Log Levels

/// Get the current NBUKit log level for a given module.
/// @param NBUKIT_MODULE_XXX The target module.
+ (int)kitLogLevelForModule:(int)NBUKIT_MODULE_XXX;

/// Dynamically set the NBUKit log level for a given module.
/// @param LOG_LEVEL_XXX The desired log level.
/// @param NBUKIT_MODULE_XXX The target module.
+ (void)setKitLogLevel:(int)LOG_LEVEL_XXX
             forModule:(int)NBUKIT_MODULE_XXX;

/// Dynamically set the NBUKit log level for all modules at once.
/// @param LOG_LEVEL_XXX The desired log level.
+ (void)setKitLogLevel:(int)LOG_LEVEL_XXX;

@end

