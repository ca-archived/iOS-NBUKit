
NBULog
======

[![Platform: iOS](https://cocoapod-badges.herokuapp.com/p/NBULog/badge.svg)](http://cocoadocs.org/docsets/NBULog/)
[![Version: 1.0.7](https://cocoapod-badges.herokuapp.com/v/NBULog/badge.png)](http://cocoadocs.org/docsets/NBULog/)
[![Build Status](https://travis-ci.org/CyberAgent/iOS-NBULog.png?branch=master)](https://travis-ci.org/CyberAgent/iOS-NBULog)

Log framework based on [CocoaLumberjack](https://github.com/robbiehanson/CocoaLumberjack). Adds dynamic log levels, modules' support and eases usage.

_Was part of [NBUCore](https://github.com/CyberAgent/iOS-NBUCore) 1.9.x._

## Demo

There is a NBULogDemo project included in the repository and can also be tried online [here](https://app.io/Yj1WIj).

## Features

### Dynamic Log Levels

Instead of handling a `ddLogLevel` variable set you app log level dynamically. Also works with third party libraries that support NBULog.

```obj-c
[NBULog setAppLogLevel:LOG_LEVEL_INFO];
[NBULog setKitLogLevel:LOG_LEVEL_WARN]; // When using NBUKit
```

### Modules

By default all your sources to `APP_MODULE_DEFAULT` but you can define your own modules in your `prefix.pch` file.

```obj-c
// Custom log modules
#define APP_MODULE_NETWORK  1 // APP_MODULE_DEFAULT = 0
#define APP_MODULE_OTHER    2
```

Then just redefine `LOG_MODULE` for the files that belong to one of your custom modules.

```obj-c
#import "MockNetworkModule.h"

// Define log module for this file
#undef  LOG_MODULE
#define LOG_MODULE APP_MODULE_NETWORK
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

### XcodeColors

![XcodeColors](http://cyberagent.github.io/iOS-NBULog/images/xcodecolors.png)

When installed, [XcodeColors](https://github.com/robbiehanson/XcodeColors) are automatically enabled for the Xcode console.

### On-Device Log Console and GUI to Ajust Levels

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

## Installation

Add `pod 'NBULog'` to your [CocoaPods](http://cocoapods.org)' [Podfile](http://docs.cocoapods.org/podfile.html):

```ruby
platform :ios, '5.0'

pod 'NBULog'

# Optional on-device console
pod 'LumberjackConsole'
```

## Documentation

http://cocoadocs.org/docsets/NBULog/

## Usage in 3rd Party Libraries

You can easily use NBULog in your library when available without making NBULog a requirement.

### 1. Conditionally Use NBULog

...and fallback to CocoaLumberjack or NSLog otherwise.

E.g. from [NBUKit](https://github.com/CyberAgent/iOS-NBUKit)'s [`NBUKitPrivate.h`](https://github.com/CyberAgent/iOS-NBUKit/blob/master/Source/NBUKitPrivate.h):

```obj-c
//  NBUKitPrivate.h

// ...

// a) Use NBULog for logging when available
#ifdef COCOAPODS_POD_AVAILABLE_NBULog

#import "NBULog+NBUKit.h"

#undef  LOG_CONTEXT
#define LOG_CONTEXT NBUKIT_LOG_CONTEXT

#undef  LOG_MODULE
#define LOG_MODULE  NBUKIT_MODULE_DEFAULT

#undef  LOG_LEVEL
#define LOG_LEVEL   [NBULog kitLogLevel]

// b) Else try CocoaLumberjack
#elif defined(COCOAPODS_POD_AVAILABLE_CocoaLumberjack)

#ifdef DEBUG
    #define NBUKitLogLevel LOG_LEVEL_VERBOSE
#else
    #define NBUKitLogLevel LOG_LEVEL_WARN
#endif

#define LOG_LEVEL_DEF   NBUKitLogLevel
#import <CocoaLumberjack/DDLog.h>

#define NBULogError(frmt, ...)      DDLogError(frmt, ##__VA_ARGS__)
#define NBULogWarn(frmt, ...)       DDLogWarn(frmt, ##__VA_ARGS__)
#define NBULogInfo(frmt, ...)       DDLogInfo(frmt, ##__VA_ARGS__)
#define NBULogDebug(frmt, ...)      DDLogDebug(frmt, ##__VA_ARGS__)
#define NBULogVerbose(frmt, ...)    DDLogVerbose(frmt, ##__VA_ARGS__)
#define NBULogTrace()               NBULogDebug(@"%@", THIS_METHOD)

// c) Else fallback to NSLog
#else

#ifdef DEBUG
    #define LOG_LEVEL 3
#else
    #define LOG_LEVEL 2
#endif

#define THIS_METHOD                 NSStringFromSelector(_cmd)
#define NBULogError(frmt, ...)      do{ if(LOG_LEVEL >= 1) NSLog((frmt), ##__VA_ARGS__); } while(0)
#define NBULogWarn(frmt, ...)       do{ if(LOG_LEVEL >= 2) NSLog((frmt), ##__VA_ARGS__); } while(0)
#define NBULogInfo(frmt, ...)       do{ if(LOG_LEVEL >= 3) NSLog((frmt), ##__VA_ARGS__); } while(0)
#define NBULogDebug(frmt, ...)      do{ if(LOG_LEVEL >= 4) NSLog((frmt), ##__VA_ARGS__); } while(0)
#define NBULogVerbose(frmt, ...)    do{ if(LOG_LEVEL >= 5) NSLog((frmt), ##__VA_ARGS__); } while(0)
#define NBULogTrace()               NBULogDebug(@"%@", THIS_METHOD)

#endif
```

### 2. Register a Log Context and Optional Modules

```obj-c
//  NBULog+NBUKit.h

#ifdef COCOAPODS_POD_AVAILABLE_NBULog

#import <NBULog/NBULog.h>

// NBUKit log context
#define NBUKIT_LOG_CONTEXT          110

// NBUKit modules
#define NBUKIT_MODULE_DEFAULT       0

@interface NBULog (NBUKit)

// Allow to set and read the current levels.
+ (int)kitLogLevel;
+ (void)setKitLogLevel:(int)LOG_LEVEL_XXX;

@end

#endif
```

Then register your context and modules if you want them to appear in [LumberjackConsole](https://github.com/PTEz/LumberjackConsole).

```obj-c
//  NBULog+NBUKit.m

#ifdef COCOAPODS_POD_AVAILABLE_NBULog

#import "NBULog+NBUKit.h"
#import <NBULog/NBULogContextDescription.h>

@implementation NBULog (NBUKit)

+ (void)load
{
    // Register the NBUKit log context
    [NBULog registerContextDescription:[NBULogContextDescription descriptionWithName:@"NBUKit"
                                                                             context:NBUKIT_LOG_CONTEXT
                                                                     modulesAndNames:nil
                                                                   contextLevelBlock:^{ return [NBULog kitLogLevel]; }
                                                                setContextLevelBlock:^(int level) { [NBULog setKitLogLevel:level]; }
                                                          contextLevelForModuleBlock:NULL
                                                       setContextLevelForModuleBlock:NULL]];
}

+ (int)kitLogLevel
{
    // ...
}

+ (void)setKitLogLevel:(int)LOG_LEVEL_XXX
{
    // ...
}

@end

#endif

```

## License

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License. 
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

