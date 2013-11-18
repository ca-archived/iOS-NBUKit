//
//  NBULog+NBUKit.h
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

#ifdef COCOAPODS_POD_AVAILABLE_NBULog

#import <NBULog/NBULog.h>

// NBUKit log context
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

+ (int)kitLogLevel;

/// Dynamically set the NBUKit log level for all modules at once.
/// @param LOG_LEVEL_XXX The desired log level.
/// @note Setting this value clears all modules' levels.
+ (void)setKitLogLevel:(int)LOG_LEVEL_XXX;

/// Get the current NBUKit log level for a given module.
/// @param NBUKIT_MODULE_XXX The target module.
+ (int)kitLogLevelForModule:(int)NBUKIT_MODULE_XXX;

/// Dynamically set the NBUKit log level for a given module.
/// @param LOG_LEVEL_XXX The desired log level.
/// @param NBUKIT_MODULE_XXX The target module.
+ (void)setKitLogLevel:(int)LOG_LEVEL_XXX
             forModule:(int)NBUKIT_MODULE_XXX;

@end

#endif

