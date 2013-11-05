NBUCore
=======

[![Platform: iOS](https://cocoapod-badges.herokuapp.com/p/NBUCore/badge.svg)](http://cocoadocs.org/docsets/NBUCore/)
[![Version: 1.9.5](https://cocoapod-badges.herokuapp.com/v/NBUCore/badge.png)](http://cocoadocs.org/docsets/NBUCore/)
[![Build Status](https://travis-ci.org/CyberAgent/iOS-NBUCore.png?branch=master)](https://travis-ci.org/CyberAgent/iOS-NBUCore)

Convenience extensions, macros and on-device console for iOS projects. [[日本語](README.jp.md)]

![NBUCore](https://github.com/CyberAgent/iOS-NBUCore/wiki/images/NBUCore.png)

Components
----------

### .xcconfig Files

Add these files to your target's build settings if you want to have some default settings
to configure your Debug, Testing and Production configurations.

### NBUUtil

Commonly needed macros, functions, etc.

### NBULog

A very useful replacement for NSLog wich is also bad for performance.  
Easy to use and easy to extend. Based on [Cocoa Lumberjack](https://github.com/robbiehanson/CocoaLumberjack).

### NBUAdditions

Many useful UIKit and NSFoundation categories that could be useful for many applications.
Import them all or just the ones you need.

### NBUDashboard

On-device log console that supports:

* Different colors for log levels.
* Expands and collapses text on tap.
* Can be filtered according to log levels or custom strings.
* Can be minimized, maximized or used in any size in between.

![Dashboard](https://raw.github.com/wiki/CyberAgent/iOS-NBUCore/images/Dashboard.png "On-device log console")
![Dashboard minimized](https://raw.github.com/wiki/CyberAgent/iOS-NBUCore/images/Dashboard_filter.png "Filter log messages")

Installation
------------

### Cocoapods (Recomended)

1. Install [Cocoapods](http://cocoapods.org) if not already done.
2. Add `pod 'NBUCore'` to your Podfile.

_If you have a problem try `gem update cocoapods` first._

### Manual

1. Checkout `git@github.com:CyberAgent/iOS-NBUCore.git` or [download](https://github.com/CyberAgent/iOS-NBUCore/tags)
the NBUCore sources to your project directory.
2. Import `NBUCore.h` or only the files that you need.
3. Optionally add the [configuration files](#nbucore_xcconfig-files) to your target.

_Keychain access requires to link `Security.framework`._

Documentation
-------------

* HTML: http://cocoadocs.org/docsets/NBUCore/
* Xcode DocSet: `http://cocoadocs.org/docsets/NBUCore/xcode-docset.atom`

License
-------

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License. 
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

