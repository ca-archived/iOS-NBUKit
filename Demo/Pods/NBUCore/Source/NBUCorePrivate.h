//
//  NBUCorePrivate.h
//  NBUCore
//
//  Created by Ernesto Rivera on 2013/10/08.
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

#import "NBUCore.h"

// NBUCore log context
#define NBUCORE_LOG_CONTEXT 100

// Custom log macros
#define NBUCORE_LOG_LEVEL    [NBULog coreLogLevel]
#undef NBULogError
#define NBULogError(frmt, ...)  LOG_OBJC_MAYBE(LOG_ASYNC_ERROR,   NBUCORE_LOG_LEVEL, LOG_FLAG_ERROR,    NBUCORE_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#undef NBULogWarn
#define NBULogWarn(frmt, ...)   LOG_OBJC_MAYBE(LOG_ASYNC_WARN,    NBUCORE_LOG_LEVEL, LOG_FLAG_WARN,     NBUCORE_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#undef NBULogInfo
#define NBULogInfo(frmt, ...)   LOG_OBJC_MAYBE(LOG_ASYNC_INFO,    NBUCORE_LOG_LEVEL, LOG_FLAG_INFO,     NBUCORE_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#undef NBULogVerbose
#define NBULogVerbose(frmt, ...)LOG_OBJC_MAYBE(LOG_ASYNC_VERBOSE, NBUCORE_LOG_LEVEL, LOG_FLAG_VERBOSE,  NBUCORE_LOG_CONTEXT, frmt, ##__VA_ARGS__)

