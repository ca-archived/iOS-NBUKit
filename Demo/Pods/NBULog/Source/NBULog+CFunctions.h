//
//  NBULog+CFunctions.h
//  NBULog
//
//  Created by Ernesto Rivera on 2013/02/06.
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

/// Additional NBULog macros for C functions
#define NBULogCError(frmt, ...)   LOG_C_MAYBE(LOG_ASYNC_ERROR,   LOG_LEVEL, LOG_FLAG_ERROR,   LOG_CONTEXT + LOG_MODULE, frmt, ##__VA_ARGS__)
#define NBULogCWarn(frmt, ...)    LOG_C_MAYBE(LOG_ASYNC_WARN,    LOG_LEVEL, LOG_FLAG_WARN,    LOG_CONTEXT + LOG_MODULE, frmt, ##__VA_ARGS__)
#define NBULogCInfo(frmt, ...)    LOG_C_MAYBE(LOG_ASYNC_INFO,    LOG_LEVEL, LOG_FLAG_INFO,    LOG_CONTEXT + LOG_MODULE, frmt, ##__VA_ARGS__)
#define NBULogCVerbose(frmt, ...) LOG_C_MAYBE(LOG_ASYNC_VERBOSE, LOG_LEVEL, LOG_FLAG_VERBOSE, LOG_CONTEXT + LOG_MODULE, frmt, ##__VA_ARGS__)
#define NBULogCTrace()            NBULogCVerbose(@"%s", __FUNCTION__)

