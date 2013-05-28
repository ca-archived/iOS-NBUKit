NBUKit
======

_Latest version 1.9.0_

[![Build Status](https://travis-ci.org/CyberAgent/iOS-NBUKit.png?branch=master)](https://travis-ci.org/CyberAgent/iOS-NBUKit)

[Customizable](https://github.com/CyberAgent/iOS-NBUKit/wiki/NBUKit-Customization) camera, assets,
image editing, gallery, picker and UIKit subclasses.

_Uses [NBUCore](https://github.com/CyberAgent/iOS-NBUCore)._

![NBUKit](https://raw.github.com/wiki/CyberAgent/iOS-NBUKit/images/NBUKit.png)

Components
----------

### NBUCameraView

Customizable AVFoundation-based camera view.

Can be embeded in any superview, custom UIViewController or used along NBUCameraViewController and even takes
mock pictures on the iOS simulator!

![NBUCamera](https://raw.github.com/wiki/CyberAgent/iOS-NBUKit/Camera1.png)
![NBUCamera](https://raw.github.com/wiki/CyberAgent/iOS-NBUKit/Camera2.png)

### NBUAssets

Multiple classes of all three MVC categories to ease access to AssetsLibrary listening to
change notifications to stay always in valid.

Also support for _local assets_: Images in folders that are handled just like regular library assets.

![NBUAssets](https://raw.github.com/wiki/CyberAgent/iOS-NBUKit/Assets1.png)
![NBUAssets](https://raw.github.com/wiki/CyberAgent/iOS-NBUKit/Assets2.png)

### Cropping/Filters

Customizable views and controllers to modify images (filters and cropping).

Filters from CoreImage and [GPUImage](https://github.com/BradLarson/GPUImage) but could be extended to
other libraries as well.

![NBUEdit](https://raw.github.com/wiki/CyberAgent/iOS-NBUKit/Edit2.png)
![NBUEdit](https://raw.github.com/wiki/CyberAgent/iOS-NBUKit/Edit3.png)

### NBUGallery

Image slideshow in development inspired by [FGallery](https://github.com/gdavis/FGallery-iPhone).

![NBUGallery](https://raw.github.com/wiki/CyberAgent/iOS-NBUKit/Gallery1.png)

### NBUImagePickerController

Block-based image picker that combines all modules mentioned above.

![NBUPicker](https://raw.github.com/wiki/CyberAgent/iOS-NBUKit/Picker1.png)

Customization
-------------

The main goal of NBUKit is to be fully [customizable](https://github.com/CyberAgent/iOS-NBUKit/wiki/NBUKit-Customization) and easy to extend.

Installation
------------

### Cocoapods (1.9.x+)

1. Install [Cocoapods](http://cocoapods.org) if not already done.
2. Add `pod 'NBUKit'` to your Podfile.

_If you have a problem try `gem update cocoapods` first._

### Manual (up to 1.8.x)

[NBUKit Installation](https://github.com/CyberAgent/iOS-NBUKit/wiki/NBUKit-Installation).

Documentation
-------------

NBUKit + NBUCore

* HTML: http://cyberagent.github.io/iOS-NBUKit/html/
* Xcode DocSet: `http://cyberagent.github.io/iOS-NBUKit/publish/NBUKit.atom`

NBUKit only

* HTML: http://cocoadocs.org/docsets/NBUKit/
* Xcode DocSet: `http://cocoadocs.org/docsets/NBUKit/xcode-docset.atom`

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

