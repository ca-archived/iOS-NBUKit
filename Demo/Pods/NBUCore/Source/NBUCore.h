//
//  NBUCore.h
//  NBUCore
//
//  Created by Ernesto Rivera on 2012/12/07.
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

/// @name Macros

/// Detect system versions.
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

/// Detect device idioms
#define DEVICE_IS_IPHONE_IDIOM  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define DEVICE_IS_IPAD_IDIOM    (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

/// Detect "widescreen" devices (iPhone 5 or iPod Touch 4).
#define DEVICE_IS_WIDESCREEN (fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON)

/// Print descriptive BOOL (e.g. `[NSString stringWithFormat:@"View is hidden: %@", NBUStringFromBOOL(view.hidden)]`).
#define NBUStringFromBOOL(b) ((b) ? @"YES" : @"NO")

/// @name Functions

/// Convert valid UIDeviceOrientation to UIInterfaceOrientation.
extern UIInterfaceOrientation UIInterfaceOrientationFromValidDeviceOrientation(UIDeviceOrientation orientation);

/// Check if a given UIInterfaceOrientation is supported by a UIInterfaceOrientationMask.
extern BOOL UIInterfaceOrientationIsSupportedByInterfaceOrientationMask(UIInterfaceOrientation orientation,
                                                                        UIInterfaceOrientationMask mask);

/// Whether the application is being debugged.
extern BOOL AmIBeingDebugged(void);

