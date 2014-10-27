//
//  NBUKit.h
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/07/11.
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

/// NBUCore
#import <NBUCore/NBUCore.h>

/// NBULog
#if __has_include("NBULog+NBUKit.h")
    #import "NBULog+NBUKit.h"
#endif

/// Additions
#if __has_include("NBUAdditions.h")
    #import "NBUAdditions.h"
#endif

/// Compatibility
#if __has_include("NBUCompatibility.h")
    #import "NBUCompatibility.h"
#endif

/// UI
#if __has_include("NBUActionSheet.h")
    #import "NBUActionSheet.h"
    #import "NBUAlertView.h"
    #import "NBUBadgeSegmentedControl.h"
    #import "NBUBadgeView.h"
    #import "NBUMailComposeViewController.h"
    #import "NBUObjectView.h"
    #import "NBUObjectViewController.h"
    #import "NBURefreshControl.h"
    #import "NBURotatingViews.h"
    #import "NBUSplashView.h"
    #import "NBUTabBarController.h"
    #import "NBUView.h"
    #import "NBUViewController.h"
#endif

/**
 NBUKit static library.
 */
@interface NBUKit : NSObject

/// The NBUKit NSBundle.
+ (NSBundle *)bundle;

@end

