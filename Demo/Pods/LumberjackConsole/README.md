
LumberjackConsole
=================

[![Platform: iOS](https://img.shields.io/cocoapods/p/LumberjackConsole.svg?style=flat)](http://cocoadocs.org/docsets/LumberjackConsole/)
[![Version: 2.2.1](https://img.shields.io/cocoapods/v/LumberjackConsole.svg?style=flat)](http://cocoadocs.org/docsets/LumberjackConsole/)
[![License: Apache 2.0](https://img.shields.io/cocoapods/l/LumberjackConsole.svg?style=flat)](http://cocoadocs.org/docsets/LumberjackConsole/)
[![Dependency Status](https://www.versioneye.com/objective-c/LumberjackConsole/badge.svg?style=flat)](https://www.versioneye.com/objective-c/LumberjackConsole)
[![Build Status](http://img.shields.io/travis/PTEz/LumberjackConsole/master.svg?style=flat)](https://travis-ci.org/PTEz/LumberjackConsole)

On-device [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack) console with support for search, adjust levels, copying and more.

![Screenshot 1](http://ptez.github.io/LumberjackConsole/images/screenshot1.png)　![Screenshot 2](http://ptez.github.io/LumberjackConsole/images/screenshot2.png)

## Features

* Sypport dynamic log levels.
* Support log modules.
* Auto-enable [XcodeColors](https://github.com/robbiehanson/XcodeColors) when present.
* No need to declare `ddLogLevel`.
* Filter messages by level and text contents.
* Expand/collapse long messages.
* Long tap to copy log messages.
* Insert markers.
* Clear console.

### ToDo

* Improve rotation support.
* Read crash reports.
* Keep scrolled area when not at the top.

## Demo

There is a ConsoleDemo project included in the repository and can also be tried online [here](https://app.io/UQcR5R).

## Installation

Simply add `pod 'LumberjackConsole'` to your [CocoaPods](http://cocoapods.org)' [Podfile](http://guides.cocoapods.org/syntax/podfile.html).

```ruby
platform :ios, '5.0'

pod 'CocoaLumberjack'
pod 'LumberjackConsole'

# Optional for dynamic log levels
pod 'NBULog'
```

## Documentation

http://cocoadocs.org/docsets/LumberjackConsole/

## Usage

### a) Dashboard Logger

Import the dashboard header:
```obj-c
#import <LumberjackConsole/PTEDashboard.h>
```

Add its logger for testing builds:
```obj-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifndef PRODUCTION
        // Add the console dashboard for testing builds
        [PTEDashboard.sharedDashboard show];                // <- If not using NBULog
        // [NBULog addDashboardLogger];                     // <- If using NBULog
        
        DDLogInfo(@"Added console dashboard");
#endif
        
        // ...
}
```

### b) Embeded Console

Simply add a `PTEConsoleTableView` instance to your view hierarchy.

## More

When coupled with [NBULog](https://github.com/CyberAgent/iOS-NBULog) you can dynamically adjust log levels from within the dashboard!

![Screenshot 3](http://ptez.github.io/LumberjackConsole/images/screenshot3.png)

Your log level settings are saved to `NSUserDefaults`.

## License

    Copyright 2013-2014 Ernesto Rivera
    
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License. 
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

