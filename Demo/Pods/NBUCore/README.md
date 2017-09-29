
NBUCore
=======

[![Platform: iOS](https://img.shields.io/cocoapods/p/NBUCore.svg?style=flat)](http://cocoadocs.org/docsets/NBUCore/)
[![Version: 2.1.0](https://img.shields.io/cocoapods/v/NBUCore.svg?style=flat)](http://cocoadocs.org/docsets/NBUCore/)
[![License: Apache 2.0](https://img.shields.io/cocoapods/l/NBUCore.svg?style=flat)](http://cocoadocs.org/docsets/NBUCore/)
[![Dependency Status](https://www.versioneye.com/objective-c/NBUCore/badge.svg?style=flat)](https://www.versioneye.com/objective-c/NBUCore)
[![Build Status](http://img.shields.io/travis/CyberAgent/iOS-NBUCore/master.svg?style=flat)](https://travis-ci.org/CyberAgent/iOS-NBUCore)

Convenience macros, functions and API availability checks for iOS projects.

_[NBULog](https://github.com/CyberAgent/NBULog) and [NBUKit](https://github.com/CyberAgent/iOS-NBUKit)'s Additions used to be part of NBUCore._

## Features

### Macros and Functions

Macros to detect system versions, device idioms, widescreen devices, etc.

Functions to handle/transform `UIInterfaceOrientation`s/`UIDeviceOrientation`s, etc.

### Availability

Temporarily make Xcode warn you when using new API calls that may crash on older devices.

```obj-c
// E.g. check for API that may crash on iOS 9.x devices.
#define __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED __IPHONE_9_0
#import <NBUCore/NBUAvailability.h>

```

## Installation

Simply add `pod 'NBUCore'` to your [CocoaPods](http://cocoapods.org)' [Podfile](http://guides.cocoapods.org/syntax/podfile.html).

## Documentation

http://cocoadocs.org/docsets/NBUCore/

## License

    Copyright (c) 2012-2017 CyberAgent Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License. 
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

