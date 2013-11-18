//
//  NBUKitPrivate.h
//  NBUKit
//
//  Created by 利辺羅 on 2013/04/24.
//  Copyright (c) 2013年 CyberAgent Inc. All rights reserved.
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

// Default module
#define NBUKIT_MODULE       NBUKIT_MODULE_GENERAL

// Custom log macros
#define NBUKIT_LOG_LEVEL    [NBULog kitLogLevelForModule:NBUKIT_MODULE]
#undef NBULogError
#define NBULogError(frmt, ...)  LOG_OBJC_MAYBE(LOG_ASYNC_ERROR,   NBUKIT_LOG_LEVEL, LOG_FLAG_ERROR,     NBUKIT_LOG_CONTEXT + NBUKIT_MODULE, frmt, ##__VA_ARGS__)
#undef NBULogWarn
#define NBULogWarn(frmt, ...)   LOG_OBJC_MAYBE(LOG_ASYNC_WARN,    NBUKIT_LOG_LEVEL, LOG_FLAG_WARN,      NBUKIT_LOG_CONTEXT + NBUKIT_MODULE, frmt, ##__VA_ARGS__)
#undef NBULogInfo
#define NBULogInfo(frmt, ...)   LOG_OBJC_MAYBE(LOG_ASYNC_INFO,    NBUKIT_LOG_LEVEL, LOG_FLAG_INFO,      NBUKIT_LOG_CONTEXT + NBUKIT_MODULE, frmt, ##__VA_ARGS__)
#undef NBULogVerbose
#define NBULogVerbose(frmt, ...)LOG_OBJC_MAYBE(LOG_ASYNC_VERBOSE, NBUKIT_LOG_LEVEL, LOG_FLAG_VERBOSE,   NBUKIT_LOG_CONTEXT + NBUKIT_MODULE, frmt, ##__VA_ARGS__)

#else

#define LOG_LEVEL 2

// NSLog macros
#define NBULogError(frmt, ...)      do{ if(LOG_LEVEL >= 1) NSLog((frmt), ##__VA_ARGS__); } while(0)
#define NBULogWarn(frmt, ...)       do{ if(LOG_LEVEL >= 2) NSLog((frmt), ##__VA_ARGS__); } while(0)
#define NBULogInfo(frmt, ...)       do{ if(LOG_LEVEL >= 3) NSLog((frmt), ##__VA_ARGS__); } while(0)
#define NBULogDebug(frmt, ...)      do{ if(LOG_LEVEL >= 4) NSLog((frmt), ##__VA_ARGS__); } while(0)
#define NBULogVerbose(frmt, ...)    do{ if(LOG_LEVEL >= 5) NSLog((frmt), ##__VA_ARGS__); } while(0)

#endif

