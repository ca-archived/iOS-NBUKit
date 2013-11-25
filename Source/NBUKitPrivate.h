//
//  NBUKitPrivate.h
//  NBUKit
//
//  Created by Ernesto Rivera on 2013/04/24.
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

#import "NBUKit.h"

// Localization
#undef  NSLocalizedString
#define NSLocalizedString(key, comment) \
[NSBundle localizedStringForKey:key value:nil table:@"NBUKit" backupBundle:NBUKit.resourcesBundle]
#undef NSLocalizedStringWithDefaultValue
#define NSLocalizedStringWithDefaultValue(key, tableName, bundle, defaultValue, comment) \
[NSBundle localizedStringForKey:key value:defaultValue table:@"NBUKit" backupBundle:NBUKit.resourcesBundle]


// Use NBULog for logging when available
#ifdef COCOAPODS_POD_AVAILABLE_NBULog

#import "NBULog+NBUKit.h"

#define NBUKIT_LOG_LEVEL    [NBULog kitLogLevel]

// Customize NBULog macros
#undef  NBULogError
#define NBULogError(frmt, ...)  LOG_OBJC_MAYBE(LOG_ASYNC_ERROR,   NBUKIT_LOG_LEVEL, LOG_FLAG_ERROR,   NBUKIT_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#undef  NBULogWarn
#define NBULogWarn(frmt, ...)   LOG_OBJC_MAYBE(LOG_ASYNC_WARN,    NBUKIT_LOG_LEVEL, LOG_FLAG_WARN,    NBUKIT_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#undef  NBULogInfo
#define NBULogInfo(frmt, ...)   LOG_OBJC_MAYBE(LOG_ASYNC_INFO,    NBUKIT_LOG_LEVEL, LOG_FLAG_INFO,    NBUKIT_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#undef  NBULogDebug
#define NBULogDebug(frmt, ...)  LOG_OBJC_MAYBE(LOG_ASYNC_DEBUG,   NBUKIT_LOG_LEVEL, LOG_FLAG_DEBUG,   NBUKIT_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#undef  NBULogVerbose
#define NBULogVerbose(frmt, ...)LOG_OBJC_MAYBE(LOG_ASYNC_VERBOSE, NBUKIT_LOG_LEVEL, LOG_FLAG_VERBOSE, NBUKIT_LOG_CONTEXT, frmt, ##__VA_ARGS__)

#else

#define LOG_LEVEL 2

// NSLog macros
#define NBULogError(frmt, ...)      do{ if(LOG_LEVEL >= 1) NSLog((frmt), ##__VA_ARGS__); } while(0)
#define NBULogWarn(frmt, ...)       do{ if(LOG_LEVEL >= 2) NSLog((frmt), ##__VA_ARGS__); } while(0)
#define NBULogInfo(frmt, ...)       do{ if(LOG_LEVEL >= 3) NSLog((frmt), ##__VA_ARGS__); } while(0)
#define NBULogDebug(frmt, ...)      do{ if(LOG_LEVEL >= 4) NSLog((frmt), ##__VA_ARGS__); } while(0)
#define NBULogVerbose(frmt, ...)    do{ if(LOG_LEVEL >= 5) NSLog((frmt), ##__VA_ARGS__); } while(0)

#endif

