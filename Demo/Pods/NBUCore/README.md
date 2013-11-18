
NBUCore
=======

[![Platform: iOS](https://cocoapod-badges.herokuapp.com/p/NBUCore/badge.svg)](http://cocoadocs.org/docsets/NBUCore/)
[![Version: 2.0.0](https://cocoapod-badges.herokuapp.com/v/NBUCore/badge.png)](http://cocoadocs.org/docsets/NBUCore/)
[![Build Status](https://travis-ci.org/CyberAgent/iOS-NBUCore.png?branch=master)](https://travis-ci.org/CyberAgent/iOS-NBUCore)

Convenience macros, functions and API availability checks for iOS projects.

_[NBULog](https://github.com/CyberAgent/iOS-NBULog) and [NBUKit](https://github.com/CyberAgent/iOS-NBUKit)'s UIKit Additions used to be part of NBUCore_

### Macros and Functions

Macros to detect system versions, device idioms, widescreen devices, etc.

Functions to handle/transform `UIInterfaceOrientation`s/`UIDeviceOrientation`s, etc.

### Availability

Temporarily make Xcode warn you when using new API calls that may crash on older devices.

```obj-c
// E.g. check for API that may crash on iOS 5.x devices.
#define __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED __IPHONE_5_0
#import <NBUCore/NBUAvailability.h>

```

### Installation

Simply add `pod 'NBUCore'` to your [CocoaPods](http://cocoapods.org)' [Podfile](http://docs.cocoapods.org/podfile.html).

### Documentation

http://cocoadocs.org/docsets/NBUCore/

### License

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License. 
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

