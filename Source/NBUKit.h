//
//  NBUKit.h
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/07/11.
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

/// NBUCore
#import <NBUCore/NBUCore.h>

/// NBULog
#ifdef COCOAPODS_POD_AVAILABLE_NBULog
    #import "NBULog+NBUKit.h"
#endif

/// Additions
#import "Lockbox+NBUAdditions.h"
#import "NSArray+NBUAdditions.h"
#import "NSBundle+NBUAdditions.h"
#import "NSFileManager+NBUAdditions.h"
#import "NSString+NBUAdditions.h"
#import "UIApplication+NBUAdditions.h"
#import "UIButton+NBUAdditions.h"
#import "UIImage+NBUAdditions.h"
#import "UIImageView+NBUAdditions.h"
#import "UINavigationController+NBUAdditions.h"
#import "UIResponder+NBUAdditions.h"
#import "UIScrollView+NBUAdditions.h"
#import "UITabBarController+NBUAdditions.h"
#import "UIView+NBUAdditions.h"
#import "UIViewController+NBUAdditions.h"
#import "UIWebView+NBUAdditions.h"

// NBUCompatibility
#import "ActiveView.h"
#import "ObjectView.h"
#import "ObjectArrayView.h"
#import "ObjectSlideView.h"
#import "ObjectGridView.h"
#import "ObjectTableView.h"
#import "ScrollViewController.h"

// UI
#import "NBUActionSheet.h"
#import "NBUAlertView.h"
#import "NBUApplicationDelegate.h"
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

/**
 NBUKit static library.
 */
@interface NBUKit : NSObject

/// The current NBUKit library version.
+ (NSString *)version;

/// The NBUKitResources NSBundle.
+ (NSBundle *)resourcesBundle;

@end

