//
//  NBUCameraViewController.h
//  NBUKit
//
//  Created by 利辺羅 on 2012/11/12.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
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
@property (nonatomic, strong)           NBUCapturePictureResultBlock captureResultBlock;

/// Whether to save the pictures to the the library. Default `NO`.
@property (nonatomic)                   BOOL savePicturesToLibrary;

/// If set along savePicturesToLibrary the assets will be added to a given album.
/// @note A new album may be created if necessary.
@property (nonatomic, strong)           NSString * targetLibraryAlbumName;

/// Whether to use single picture mode. Default `NO`.
///
/// In this mode [NBUCameraView lastPictureImageView] will be removed.
@property (nonatomic)                   BOOL singlePictureMode;

/// Whether Volume Up and Volume Down buttons should be used to take pictures. Default `YES` for iOS5+.
@property (nonatomic)                   BOOL takesPicturesWithVolumeButtons;

/// @name Outlets

/// The camera underlying view.
@property (assign, nonatomic) IBOutlet  NBUCameraView * cameraView;

@end

