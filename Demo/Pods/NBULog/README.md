NBULog
======

[![Platform: iOS](https://cocoapod-badges.herokuapp.com/p/NBULog/badge.svg)](http://cocoadocs.org/docsets/NBULog/)
[![Version: 1.0.2](https://cocoapod-badges.herokuapp.com/v/NBULog/badge.png)](http://cocoadocs.org/docsets/NBULog/)
[![Build Status](https://travis-ci.org/CyberAgent/iOS-NBULog.png?branch=master)](https://travis-ci.org/CyberAgent/iOS-NBULog)

Log framework based on CocoaLumberjack. Adds dynamic log levels, modules' support and eases usage.

_Was part of [NBUCore](https://github.com/CyberAgent/iOS-NBUCore) 1.9.x._

### Installation

Add `pod 'NBULog'` to your [CocoaPods](http://cocoapods.org)' [Podfile](http://docs.cocoapods.org/podfile.html):

```ruby
platform :ios, '5.0'

pod 'NBULog'

# Optional on-device console
pod 'LumberjackConsole'
```


### Features

#### Dynamic Log Levels

Instead of handling a `ddLogLevel` variable set you app log level dynamically. Also works with third party libraries that support NBULog.

```obj-c
[NBULog setAppLogLevel:LOG_LEVEL_INFO];
[NBULog setKitLogLevel:LOG_LEVEL_WARN]; // When using NBUKit
```

#### Modules

By default all your sources to `APP_MODULE_DEFAULT` but you can define your own modules in your `prefix.pch` file.

```obj-c
// Custom log modules
#define APP_MODULE_NETWORK  1 // APP_MODULE_DEFAULT = 0
#define APP_MODULE_OTHER    2
```

Then just redefine `APP_MODULE` for the files that belong to one of your custom modules.

```obj-c
#import "MockNetworkModule.h"

// Define log module for this file
#undef  APP_MODULE
#define APP_MODULE APP_MODULE_NETWORK
```

Also you log a message for a different module than the one your file belongs to:

```obj-c
// Send an extra message for another module
NBULogInfoWithModule(APP_MODULE_OTHER, @"Log message from a APP_MODULE_OTHER");
```

Finally, you can also modify the log levels of individual modules.

```obj-c
// Only log messages from the custom APP_MODULE_NETWORK
[NBULog setAppLogLevel:LOG_LEVEL_OFF];
[NBULog setAppLogLevel:LOG_LEVEL_INFO
                 forModule:APP_MODULE_NETWORK];

[NBULog setKitLogLevel:LOG_LEVEL_WARN
             forModule:NBUKIT_MODULE_ADDITIONS]; // When using NBUKit

```

#### XcodeColors

![XcodeColors](http://cyberagent.github.io/iOS-NBULog/images/xcodecolors.png)

When installed, [XcodeColors](https://github.com/robbiehanson/XcodeColors) are automatically enabled for the Xcode console.

#### On-Device Log Console and GUI to Ajust Levels

![LumberjackConsole 1](http://ptez.github.io/LumberjackConsole/images/screenshot2.png)　![LumberjackConsole 2](http://ptez.github.io/LumberjackConsole/images/screenshot3.png)

When [LumberjackConsole](https://github.com/PTEz/LumberjackConsole) is present you can add am on-device dashboard logger and adjust log levels from the UI.

```obj-c
#ifndef MY_PRODUCTION_MACRO
    // Register custom modules before adding the dashboard
    [NBULog registerAppContextWithModulesAndNames:@{@(APP_MODULE_NETWORK)   : @"Network",
                                                    @(APP_MODULE_OTHER)     : @"Other"}];
    
    // Add dashboard only for testing builds
    [NBULog addDashboardLogger];
#endif
```

### Documentation

http://cocoadocs.org/docsets/NBULog/

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

