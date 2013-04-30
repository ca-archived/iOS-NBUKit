//
//  NBUCameraViewController.h
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/11/12.
//  Copyright (c) 2012 CyberAgent Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "NBUViewController.h"
#import "NBUCameraView.h"

/**
 An extensible UIViewController for a NBUCameraView.
 
 - Forwards properties to the underlying cameraView.
 */
@interface NBUCameraViewController : NBUViewController

/// @name NBUCameraView Properties

/// Whether a camera device is available.
/// @note There is a mock camera mode for the iPhone simulator.
+ (BOOL)isCameraAvailable;

/// Property passed to cameraView's [NBUCameraView targetResolution].
@property (nonatomic)                   CGSize targetResolution;

/// Property passed to cameraView's [NBUCameraView captureResultBlock].
@property (nonatomic, copy)             NBUCapturePictureResultBlock captureResultBlock;

/// Whether to save the pictures to the the library. Default `NO`.
@property (nonatomic)                   BOOL savePicturesToLibrary;

/// If set along savePicturesToLibrary the assets will be added to a given album.
/// @note A new album may be created if necessary.
@property (nonatomic, strong)           NSString * targetLibraryAlbumName;

/// Whether to use single picture mode. Default `NO`.
/// @discussion In this mode [NBUCameraView lastPictureImageView] will be removed.
@property (nonatomic)                   BOOL singlePictureMode;

/// Whether Volume Up and Volume Down buttons should be used to take pictures. Default `YES` for iOS5+.
@property (nonatomic)                   BOOL takesPicturesWithVolumeButtons;

/// @name Outlets

/// The camera underlying view.
@property (assign, nonatomic) IBOutlet  NBUCameraView * cameraView;

@end

