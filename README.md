iOS NBUKit
==========  

_Latest version 1.8.0_

All-native static framework to create custom AVFoundation camera UI, interact with AssetLibrary and visually crop/apply filters to images.  
__*Includes [NBUCore](https://github.com/CyberAgent/iOS-NBUCore).*__

![NBUKit](https://github.com/CyberAgent/iOS-NBUKit/wiki/images/NBUKit.png)

Components
----------

### NBUImagePickerController

Customizable picker based AVFoundation and AssetsLibrary.
Supports image cropping, filters and subclassing.

### NBUCameraView

Customizable AVFoundation-based camera view.
Can be embeded in any superview, custom UIViewController or used through NBUCameraViewController.

### NBUAssets

Multiple classes of all three MVC categories to ease access to AssetsLibrary.

#### Model

NBUAssetsLibrary, NBUAssetsGroup and NBUAsset that listen to AssetsLibrary notifications to stay always valid.

#### Views

Customizable views to present groups and assets including selection.

#### Controllers

Use/subclass these controllers directly to customize your AssetsLibrary access.

### Cropping/Filters

Customizable views that allow to edit images with gestures.
Filters use CoreImage or [GPUImage](https://github.com/BradLarson/GPUImage).

Installation
------------

### Cocoapods

In progress on the [cocoapod branch](https://github.com/CyberAgent/iOS-NBUKit/tree/cocapods).

### Manual

[NBUKit Installation](https://github.com/CyberAgent/iOS-NBUKit/wiki/NBUKit-Installation).

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

