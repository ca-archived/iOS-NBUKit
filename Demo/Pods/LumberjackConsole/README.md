
LumberjackConsole
=================

[![Platform: iOS](https://cocoapod-badges.herokuapp.com/p/LumberjackConsole/badge.svg)](http://cocoadocs.org/docsets/LumberjackConsole/)
[![Version: 1.0.0](https://cocoapod-badges.herokuapp.com/v/LumberjackConsole/badge.png)](http://cocoadocs.org/docsets/LumberjackConsole/)
[![Build Status](https://travis-ci.org/PTEz/LumberjackConsole.png?branch=master)](https://travis-ci.org/PTEz/LumberjackConsole)

On-device CocoaLumberjack console with support for search, filters and more.

![Screenshot 1](http://ptez.github.io/LumberjackConsole/images/screenshot1.png)　![Screenshot 2](http://ptez.github.io/LumberjackConsole/images/screenshot2.png)

### Installation

Simply add `pod 'LumberjackConsole'` to your [CocoaPods](http://cocoapods.org)' [Podfile](http://docs.cocoapods.org/podfile.html).

### Usage

#### a) Dashboard Logger

Import the dashboard header:
```obj-c
#import <LumberjackConsole/PTEDashboard.h>
```

Add its logger for testing builds:
```obj-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifndef MY_PRODUCTION_MACRO
        // Add the console dashboard for testing builds
        [DDLog addLogger:[PTEDashboard sharedDashboard].logger]; // <- If not using NBULog
        // [NBULog addDashboardLogger];                          // <- If using NBULog
        
        DDLogInfo(@"Added console dashboard");
#endif
        
        // ...
        
        return YES;
}
```

#### b) Embeded Console

You can also embed the console into your own `UITableView`:

```obj-c
    // Add a custom console
    _customConsoleLogger = [PTEConsoleLogger new];
    _customConsoleLogger.tableView = self.customConsoleTableView;
    [DDLog addLogger:_customConsoleLogger];
    
    DDLogInfo(@"Added a custom console logger");
```

### More

When coupled with [NBULog](https://github.com/CyberAgent/iOS-NBULog) you can dynamically adjust log levels from within the dashboard!

![Screenshot 3](http://ptez.github.io/LumberjackConsole/images/screenshot3.png)

You log level settings are saved to `NSUserDefaults`.

### Documentation

http://cocoadocs.org/docsets/LumberjackConsole/

### ToDo

* Clean up table view's data source.
* Improve rotation support.
* Clear log and message markers.
* Long tap to copy text.
* Read crash reports.

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

