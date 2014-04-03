//
//  NBUAvailability.h
//  NBUCore
//
//  Created by Ernesto Rivera on 2013/10/01.
//  Copyright (c) 2012-2014 CyberAgent Inc.
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

#import <Availability.h>
#import <Foundation/NSObjCRuntime.h>

/**
 Availability replacement macros to check for new APIs usage that may cause a crash on older systems.
 
 Simple define your deployment target version before importing this header file in your prefix file.
 
 E.g.:
 
     #define __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED __IPHONE_5_0
 
 @note Only enable it temporarily to make sure you are properly guarding new APIs calls.
 
 Sources:
 
 - http://stackoverflow.com/questions/12632834/get-xcode-4-5-to-warn-about-new-api-calls/12633309
 - http://stackoverflow.com/questions/19111934/get-xcode-5-to-warn-about-new-api-calls
 */
#ifndef __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED
    #define __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED __IPHONE_OS_VERSION_MIN_REQUIRED
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_OS_VERSION_MIN_REQUIRED
    #error You cannot ask for a soft max version which is less than the deployment target
#endif

#define __NBU_AVAILABILITY_STARTING(version) __attribute__((deprecated("Only available in iOS " version "+"))) __attribute__((weak_import))

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_2_0
    #undef  __AVAILABILITY_INTERNAL__IPHONE_2_0
    #define __AVAILABILITY_INTERNAL__IPHONE_2_0 __NBU_AVAILABILITY_STARTING("2.0")
    #define __NBU_APICHECK_2_0(_ios)            __NBU_AVAILABILITY_STARTING("2.0")
#else
    #define __NBU_APICHECK_2_0(_ios)            CF_AVAILABLE_IOS(_ios)
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_2_1
    #undef  __AVAILABILITY_INTERNAL__IPHONE_2_1
    #define __AVAILABILITY_INTERNAL__IPHONE_2_1 __NBU_AVAILABILITY_STARTING("2.1")
    #define __NBU_APICHECK_2_1(_ios)            __NBU_AVAILABILITY_STARTING("2.1")
#else
    #define __NBU_APICHECK_2_1(_ios)            CF_AVAILABLE_IOS(_ios)
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_2_2
    #undef  __AVAILABILITY_INTERNAL__IPHONE_2_2
    #define __AVAILABILITY_INTERNAL__IPHONE_2_2 __NBU_AVAILABILITY_STARTING("2.2")
    #define __NBU_APICHECK_2_2(_ios)            __NBU_AVAILABILITY_STARTING("2.2")
#else
    #define __NBU_APICHECK_2_2(_ios)            CF_AVAILABLE_IOS(_ios)
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_3_0
    #undef  __AVAILABILITY_INTERNAL__IPHONE_3_0
    #define __AVAILABILITY_INTERNAL__IPHONE_3_0 __NBU_AVAILABILITY_STARTING("3.0")
    #define __NBU_APICHECK_3_0(_ios)            __NBU_AVAILABILITY_STARTING("3.0")
#else
    #define __NBU_APICHECK_3_0(_ios)            CF_AVAILABLE_IOS(_ios)
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_3_1
    #undef  __AVAILABILITY_INTERNAL__IPHONE_3_1
    #define __AVAILABILITY_INTERNAL__IPHONE_3_1 __NBU_AVAILABILITY_STARTING("3.1")
    #define __NBU_APICHECK_3_1(_ios)            __NBU_AVAILABILITY_STARTING("3.1")
#else
    #define __NBU_APICHECK_3_1(_ios)            CF_AVAILABLE_IOS(_ios)
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_3_2
    #undef  __AVAILABILITY_INTERNAL__IPHONE_3_2
    #define __AVAILABILITY_INTERNAL__IPHONE_3_2 __NBU_AVAILABILITY_STARTING("3.2")
    #define __NBU_APICHECK_3_2(_ios)            __NBU_AVAILABILITY_STARTING("3.2")
#else
    #define __NBU_APICHECK_3_2(_ios)            CF_AVAILABLE_IOS(_ios)
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_4_0
    #undef  __AVAILABILITY_INTERNAL__IPHONE_4_0
    #define __AVAILABILITY_INTERNAL__IPHONE_4_0 __NBU_AVAILABILITY_STARTING("4.0")
    #define __NBU_APICHECK_4_0(_ios)            __NBU_AVAILABILITY_STARTING("4.0")
#else
    #define __NBU_APICHECK_4_0(_ios)            CF_AVAILABLE_IOS(_ios)
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_4_1
    #undef  __AVAILABILITY_INTERNAL__IPHONE_4_1
    #define __AVAILABILITY_INTERNAL__IPHONE_4_1 __NBU_AVAILABILITY_STARTING("4.1")
    #define __NBU_APICHECK_4_1(_ios)            __NBU_AVAILABILITY_STARTING("4.1")
#else
    #define __NBU_APICHECK_4_1(_ios)            CF_AVAILABLE_IOS(_ios)
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_4_2
    #undef  __AVAILABILITY_INTERNAL__IPHONE_4_2
    #define __AVAILABILITY_INTERNAL__IPHONE_4_2 __NBU_AVAILABILITY_STARTING("4.2")
    #define __NBU_APICHECK_4_2(_ios)            __NBU_AVAILABILITY_STARTING("4.2")
#else
    #define __NBU_APICHECK_4_2(_ios)            CF_AVAILABLE_IOS(_ios)
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_4_3
    #undef  __AVAILABILITY_INTERNAL__IPHONE_4_3
    #define __AVAILABILITY_INTERNAL__IPHONE_4_3 __NBU_AVAILABILITY_STARTING("4.3")
    #define __NBU_APICHECK_4_3(_ios)            __NBU_AVAILABILITY_STARTING("4.3")
#else
    #define __NBU_APICHECK_4_3(_ios)            CF_AVAILABLE_IOS(_ios)
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_4_0
    #undef  __AVAILABILITY_INTERNAL__IPHONE_4_0
    #define __AVAILABILITY_INTERNAL__IPHONE_4_0 __NBU_AVAILABILITY_STARTING("4.0")
    #define __NBU_APICHECK_4_0(_ios)            __NBU_AVAILABILITY_STARTING("4.0")
#else
    #define __NBU_APICHECK_4_0(_ios)            CF_AVAILABLE_IOS(_ios)
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_4_1
    #undef  __AVAILABILITY_INTERNAL__IPHONE_4_1
    #define __AVAILABILITY_INTERNAL__IPHONE_4_1 __NBU_AVAILABILITY_STARTING("4.1")
    #define __NBU_APICHECK_4_1(_ios)            __NBU_AVAILABILITY_STARTING("4.1")
#else
    #define __NBU_APICHECK_4_1(_ios)            CF_AVAILABLE_IOS(_ios)
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_5_0
    #undef  __AVAILABILITY_INTERNAL__IPHONE_5_0
    #define __AVAILABILITY_INTERNAL__IPHONE_5_0 __NBU_AVAILABILITY_STARTING("5.0")
    #define __NBU_APICHECK_5_0(_ios)            __NBU_AVAILABILITY_STARTING("5.0")
#else
    #define __NBU_APICHECK_5_0(_ios)            CF_AVAILABLE_IOS(_ios)
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_5_1
    #undef  __AVAILABILITY_INTERNAL__IPHONE_5_1
    #define __AVAILABILITY_INTERNAL__IPHONE_5_1 __NBU_AVAILABILITY_STARTING("5.1")
    #define __NBU_APICHECK_5_1(_ios)            __NBU_AVAILABILITY_STARTING("5.1")
#else
    #define __NBU_APICHECK_5_1(_ios)            CF_AVAILABLE_IOS(_ios)
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_6_0
    #undef  __AVAILABILITY_INTERNAL__IPHONE_6_0
    #define __AVAILABILITY_INTERNAL__IPHONE_6_0 __NBU_AVAILABILITY_STARTING("6.0")
    #define __NBU_APICHECK_6_0(_ios)            __NBU_AVAILABILITY_STARTING("6.0")
#else
    #define __NBU_APICHECK_6_0(_ios)            CF_AVAILABLE_IOS(_ios)
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_6_1
    #undef  __AVAILABILITY_INTERNAL__IPHONE_6_1
    #define __AVAILABILITY_INTERNAL__IPHONE_6_1 __NBU_AVAILABILITY_STARTING("6.1")
    #define __NBU_APICHECK_6_1(_ios)            __NBU_AVAILABILITY_STARTING("6.1")
#else
    #define __NBU_APICHECK_6_1(_ios)            CF_AVAILABLE_IOS(_ios)
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_7_0
    #undef  __AVAILABILITY_INTERNAL__IPHONE_7_0
    #define __AVAILABILITY_INTERNAL__IPHONE_7_0 __NBU_AVAILABILITY_STARTING("7.0")
    #define __NBU_APICHECK_7_0(_ios)            __NBU_AVAILABILITY_STARTING("7.0")
#else
    #define __NBU_APICHECK_7_0(_ios)            CF_AVAILABLE_IOS(_ios)
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_7_1
    #undef  __AVAILABILITY_INTERNAL__IPHONE_7_1
    #define __AVAILABILITY_INTERNAL__IPHONE_7_1 __NBU_AVAILABILITY_STARTING("7.1")
    #define __NBU_APICHECK_7_1(_ios)            __NBU_AVAILABILITY_STARTING("7.1")
#else
    #define __NBU_APICHECK_7_1(_ios)            CF_AVAILABLE_IOS(_ios)
#endif

#undef  NS_AVAILABLE_IOS
#define NS_AVAILABLE_IOS(_ios)                  __NBU_APICHECK_##_ios( _ios )

#undef  __OSX_AVAILABLE_BUT_DEPRECATED
#define __OSX_AVAILABLE_BUT_DEPRECATED(_osx, _osxDep, _ios, _iosDep)            __AVAILABILITY_INTERNAL##_ios

#undef  __OSX_AVAILABLE_BUT_DEPRECATED_MSG
#define __OSX_AVAILABLE_BUT_DEPRECATED_MSG(_osx, _osxDep, _ios, _iosDep, _msg)  __AVAILABILITY_INTERNAL##_ios

