iOS NBUCore
===========  
_Latest version 1.8.0_

Convenience extensions and utilities for iOS projects [[日本語](https://github.com/CyberAgent/iOS-NBUCore/blob/master/README.jp.md)]

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

NBUDashboardLogger for an on-device log console.

### NBUAdditions

Many useful UIKit and NSFoundation categories that could be useful for many applications.
Import them all or just the ones you need.

Installation
------------

1. Checkout `git@github.com:CyberAgent/iOS-NBUCore.git` or [download](https://github.com/CyberAgent/iOS-NBUCore/tags)
the NBUCore sources to your project directory.
2. Import `NBUCore.h` or only the files that you need.
3. Optionally add the [configuration files](#nbucore_xcconfig-files) to your target.

_Keychain access requires to link `Security.framework`._

Documentation
-------------

* HTML: http://cyberagent.github.io/iOS-NBUCore/html/
* Xcode DocSet: `http://cyberagent.github.io/iOS-NBUCore/publish/NBUCore.atom`

Screenshots
-----------
 
![Dashboard](https://github.com/CyberAgent/iOS-NBUCore/wiki/images/Dashboard.png "On-device log console")
![Dashboard minimized](https://github.com/CyberAgent/iOS-NBUCore/wiki/images/Dashboard_minimized.png "Minimized log console")
 
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

