iOS NBUKit
==========  
[日本語](https://github.com/icb-cost-01/iOS-NBUKit/blob/master/README.jp.md)

_Latest version 1.7.0_

All-native static framework to create custom AVFoundation camera UI, interact with AssetLibrary and visually crop/apply filters to images.  
__*Includes [NBUCore](https://github.com/icb-cost-01/iOS-NBUCore).*__

![NBUKit](https://github.com/icb-cost-01/iOS-NBUKit/wiki/images/NBUKit.png)

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

1. ToDo

Notes
-----
