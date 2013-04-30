//
//  NBULog+CFunctions.h
//  NBUCore
//
//  Created by Ernesto Rivera on 2013/02/06.
//  Copyright (c) 2013 CyberAgent Inc.
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

/// Additional NBULog macros for C functions
#define NBULogCError(frmt, ...)  LOG_C_MAYBE(LOG_ASYNC_ERROR,   APP_LOG_LEVEL, LOG_FLAG_ERROR,    APP_LOG_CONTEXT + APP_MODULE, frmt, ##__VA_ARGS__)
#define NBULogCWarn(frmt, ...)   LOG_C_MAYBE(LOG_ASYNC_WARN,    APP_LOG_LEVEL, LOG_FLAG_WARN,     APP_LOG_CONTEXT + APP_MODULE, frmt, ##__VA_ARGS__)
#define NBULogCInfo(frmt, ...)   LOG_C_MAYBE(LOG_ASYNC_INFO,    APP_LOG_LEVEL, LOG_FLAG_INFO,     APP_LOG_CONTEXT + APP_MODULE, frmt, ##__VA_ARGS__)
#define NBULogCVerbose(frmt, ...)LOG_C_MAYBE(LOG_ASYNC_VERBOSE, APP_LOG_LEVEL, LOG_FLAG_VERBOSE,  APP_LOG_CONTEXT + APP_MODULE, frmt, ##__VA_ARGS__)
#define NBULogCTrace()           NBULogCVerbose(@"[%p] %@", self, THIS_METHOD)

