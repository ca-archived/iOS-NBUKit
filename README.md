
NBUKit
======

[![Platform: iOS](https://img.shields.io/cocoapods/p/NBUKit.svg?style=flat)](http://cocoadocs.org/docsets/NBUKit/)
[![Version: 2.4.1](https://img.shields.io/cocoapods/v/NBUKit.svg?style=flat)](http://cocoadocs.org/docsets/NBUKit/)
[![License: Apache 2.0](https://img.shields.io/cocoapods/l/NBUKit.svg?style=flat)](http://cocoadocs.org/docsets/NBUKit/)
[![Dependency Status](https://www.versioneye.com/objective-c/NBUKit/badge.svg?style=flat)](https://www.versioneye.com/objective-c/NBUKit)
[![Build Status](http://img.shields.io/travis/CyberAgent/iOS-NBUKit/master.svg?style=flat)](https://travis-ci.org/CyberAgent/iOS-NBUKit)

UIKit and NSFoundation convenience categories and subclasses.

_Uses [NBUCore](https://github.com/CyberAgent/iOS-NBUCore), supports [NBULog](https://github.com/CyberAgent/NBULog).  
Image Picker code moved to [NBUImagePicker](https://github.com/CyberAgent/iOS-NBUImagePicker)._

## Demo

A demo project is [included](Demo) in the repository.

## Features

### Additions

* Convenience methods to parse `NSArray` objets, support subbundles in `NSBundle` and handle file URLs with `NSFileManager`.
* Check properties, retrieve common application directories and save/retrieve values from `NSUserDefaults` and `Keychanin` with `UIApplication`.
* Programatically send a message through the responder chain with `UIResponder`.
* Size/origin setter/getter shortcuts, read-only properties to retrieve a `UIView`'s view, navigation or tab controller.
* `UIButton` protocol to freely switch between `UIButton` and `UIBarButtonItem` objects.
* Adjust orientation, crop, resize, flatten, write and read `UIImage` objects.
* Scroll a `UIScrollView` to any edge with/without animation.
* Retrieve/change system UserAgent, fire JavaScript events and get the HTML title from `UIWebView` objects.
* Navigation item IBOutlet and force refresh orientation method for `UIViewController`'s.
* Show/hide `UITabBarController`'s tab bar.
* Additional properties, dismiss and pop to view controller and to root controller methods for `UINavigationController` objects.

### UIKit Subclasses

* Block-based `NBUActionSheet` and `NBUAlertView`.
* `NBUBadgeView` and `NBUBadgeSegmentedControl`.
* Block-based `NBUMailComposeViewController` that can be initialized with a `mailto:` URL.
* Interface Builder-focused `NBURefreshControl`.
* `NBUTabBarController` with customizable position and `UITabBar`.
* `NBUView` with commonInit, and view controller-like view will/did appear/disappear methods.
* `NBUViewController` with commonInit and supportedInterfaceOrientations writable property.
* More...

## Installation

For now add the following to your [CocoaPods](http://cocoapods.org)' [Podfile](http://guides.cocoapods.org/syntax/podfile.html):

```ruby
platform :ios, '5.0'

pod 'NBUKit'

# Optional for dynamic logging
pod 'NBULog'

# Optional for on-device log console
pod 'LumberjackConsole'
```

## Documentation

http://cocoadocs.org/docsets/NBUKit/

##License

    Copyright 2012-2014 CyberAgent Inc.
    
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License. 
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

