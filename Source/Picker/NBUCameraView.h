//
//  NBUCameraView.h
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/10/15.
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

#import "ActiveView.h"
#import <AVFoundation/AVCaptureDevice.h>

@protocol UIButton;

/// NBUCameraView blocks.
typedef void (^NBUCapturePictureResultBlock)(UIImage * image,
                                             NSError * error);
typedef void (^NBUSavePictureResultBlock)(UIImage * image,
                                          NSDictionary * metadata,
                                          NSURL * url,
                                          NSError * error);
typedef void (^NBUCaptureMovieResultBlock)(NSURL * movieURL,
                                           NSError * error);
typedef void (^NBUButtonConfigurationBlock)(id<UIButton> button,
                                            NSInteger mode);

/**
 Fully customizable camera view based on AVFoundation.
 
 - Set target resolution.
 - Customizable controls/buttons and layout.
 - Supports flash, focus, exposure and white balance settings.
 - Can automatically save to device's Camera Roll/custom albums.
 - Can be used with any UIViewController, so it can be embedded in a UITabView, pushed to a UINavigationController, presented modally, etc.
 - Works with simulator.
 */
@interface NBUCameraView : ActiveView

/// @name Configurable Properties

/// The minimum desired resolution.
/// @discussion If not set full camera resolution will be used but to improve performance
/// you could set a lower resolution.
/// @note The captured image may not exactly match the targetResolution.
@property (nonatomic)                   CGSize targetResolution;

/// Programatically force the view to rotate.
/// @param orientation The desired interface orientation.
- (void)setInterfaceOrientation:(UIInterfaceOrientation)orientation;

/// @name Picture Properties

/// The block to be called immediately after capturing the picture.
@property (nonatomic, copy)             NBUCapturePictureResultBlock captureResultBlock;

/// Whether to save the pictures to the the library. Default `NO`.
@property (nonatomic)                   BOOL savePicturesToLibrary;

/// If set along savePicturesToLibrary the assets will be added to a given album.
/// @note A new album may be created if necessary.
@property (nonatomic, strong)           NSString * targetLibraryAlbumName;

/// The optional block to be called if savePicturesToLibrary is enabled.
/// @note This block has some delay over captureResultBlock.
@property (nonatomic, copy)             NBUSavePictureResultBlock saveResultBlock;

/// Whether the view should compensate device orientation changes. Default `NO`.
/// @note Set to `YES` when inside view controllers that support rotation.
@property (nonatomic)                   BOOL shouldAutoRotateView;

/// Whether front camera's pictures should be captured mirrored.
/// Default `NO` meaning that front camera pictures are not mirrored.
/// @note Front camera's preview is always mirrored.
@property(nonatomic)                    BOOL keepFrontCameraPicturesMirrored;

/// Whether the lastPictureImageView should be animated. Default `YES`.
@property(nonatomic)                    BOOL animateLastPictureImageView;

/// @name Picture Sequence Properties

@property (nonatomic)                   NSTimeInterval sequenceCaptureInterval;

@property (nonatomic, readonly,
           getter=isCapturingSequence)  BOOL capturingSequence;

/// @name Movie Properties

/// The local folder where recorded movies should be recorded.
/// @discussion If not specified movies will be saved to the application's Documents folder.
@property (nonatomic, strong)           NSURL * targetMovieFolder;

/// The block to be called after capturing a movie.
@property (nonatomic, copy)             NBUCaptureMovieResultBlock captureMovieResultBlock;

/// Whether recording is in progress.
@property (nonatomic, readonly,
           getter=isRecording)          BOOL recording;

/// @name Capture Devices and Modes

/// The available capture devices' uniqueID's (ex. Front, Back camera).
/// @see [AVCaptureDevice uniqueID].
@property (strong, nonatomic, readonly) NSArray * availableCaptureDevices;

/// The current capture device's uniqueID.
/// @discussion Changing the current device refreshes the availableFlashModes, availableFocusModes,
/// availableExposureModes and availableWhiteBalanceModes.
@property (strong, nonatomic)           NSString * currentCaptureDevice;

/// The current device's available capture presets and resolutions.
@property (nonatomic, strong)           NSDictionary * availableResolutions;

/// The current device's available AVCaptureFlashMode modes.
@property (strong, nonatomic, readonly) NSArray * availableFlashModes;

/// The current capture device's AVCaptureFlashMode.
/// @see availableFlashModes.
@property (nonatomic)                   AVCaptureFlashMode currentFlashMode;

/// The current device's available AVCaptureFocusMode modes.
@property (strong, nonatomic, readonly) NSArray * availableFocusModes;

/// The current capture device's AVCaptureFocusMode.
/// @see availableFocusModes.
@property (nonatomic)                   AVCaptureFocusMode currentFocusMode;

/// The current device's available AVCaptureExposureMode modes.
@property (strong, nonatomic, readonly) NSArray * availableExposureModes;

/// The current capture device's AVCaptureExposureMode.
/// @see availableExposureModes.
@property (nonatomic)                   AVCaptureExposureMode currentExposureMode;

/// The current device's available AVCaptureWhiteBalanceMode modes.
@property (strong, nonatomic, readonly) NSArray * availableWhiteBalanceModes;

/// The current capture device's AVCaptureWhiteBalanceMode.
/// @see availableWhiteBalanceModes.
@property (nonatomic)                   AVCaptureWhiteBalanceMode currentWhiteBalanceMode;

/// @name Customizing the UI Controls

/// Whether to hide disabled controls. Default `NO`.
@property (nonatomic)                   BOOL showDisabledControls;

/// The block to be used to configure the shootButton.
@property (nonatomic, copy)             NBUButtonConfigurationBlock shootButtonConfigurationBlock;

/// The block to be used to configure the toggleCameraButton.
@property (nonatomic, copy)             NBUButtonConfigurationBlock toggleCameraButtonConfigurationBlock;

/// The block to be used to configure the flashButton.
@property (nonatomic, copy)             NBUButtonConfigurationBlock flashButtonConfigurationBlock;

/// The block to be used to configure the focusButton.
@property (nonatomic, copy)             NBUButtonConfigurationBlock focusButtonConfigurationBlock;

/// The block to be used to configure the exposureButton.
@property (nonatomic, copy)             NBUButtonConfigurationBlock exposureButtonConfigurationBlock;

/// The block to be used to configure the whiteBalanceButton.
@property (nonatomic, copy)             NBUButtonConfigurationBlock whiteBalanceButtonConfigurationBlock;

/// @name Actions

/// Take a picture and execure the resultBlock.
/// @param sender The sender object.
- (IBAction)takePicture:(id)sender;

- (IBAction)startStopPictureSequence:(id)sender;

/// Start or stop video recording.
/// @param sender The sender object.
- (IBAction)startStopRecording:(id)sender;

/// Switch between front and back cameras (if available).
/// @discussion Configures toggleCameraButton using toggleCameraButtonConfigurationBlock when available.
/// @param sender The sender object.
/// @see availableCaptureDevices.
- (IBAction)toggleCamera:(id)sender;

/// Change the flash mode (if available).
/// @discussion Configures flashButton using flashButtonConfigurationBlock when available.
/// @param sender The sender object.
- (IBAction)toggleFlashMode:(id)sender;

/// Change the focus mode (if available).
/// @discussion Configures focusButton using focusButtonConfigurationBlock when available.
/// @param sender The sender object.
- (IBAction)toggleFocusMode:(id)sender;

/// Change the exposure mode (if available).
/// @discussion Configures exposureButton using exposureButtonConfigurationBlock when available.
/// @param sender The sender object.
- (IBAction)toggleExposureMode:(id)sender;

/// Change the white balance mode (if available).
/// @discussion Configures whiteBalanceButton using whiteBalanceButtonConfigurationBlock when available.
/// @param sender The sender object.
- (IBAction)toggleWhiteBalanceMode:(id)sender;

/// @name Creating UI Configuration Blocks

/// Create a NBUButtonConfigurationBlock that sets the title of a
/// button using `[NSString stringWithFormat:format, mode]`.
/// @param format A string format for a NSInteger. Ex. `@"Flash: %d"`.
- (NBUButtonConfigurationBlock)buttonConfigurationBlockWithTitleFormat:(NSString *)format;

/// Create a NBUButtonConfigurationBlock that sets the title from an array of titles
/// using the mode as index.
/// @param titles The possible titles. One for each mode.
- (NBUButtonConfigurationBlock)buttonConfigurationBlockWithTitleFrom:(NSArray *)titles;

/// @name UI Outlets

/// The button to takePicture:.
@property (assign, nonatomic) IBOutlet id<UIButton> shootButton;

/// The optional button to toggleCamera:.
@property (assign, nonatomic) IBOutlet id<UIButton> toggleCameraButton;

/// The optional button to toggleFlashMode:.
@property (assign, nonatomic) IBOutlet id<UIButton> flashButton;

/// The optional button to toggleFocusMode:.
@property (assign, nonatomic) IBOutlet id<UIButton> focusButton;

/// The optional button to toggleExposureMode:.
@property (assign, nonatomic) IBOutlet id<UIButton> exposureButton;

/// The optional button to toggleWhiteBalanceMode:.
@property (assign, nonatomic) IBOutlet id<UIButton> whiteBalanceButton;

/// The optional UIImageView to be used to display the last taken picture.
/// @note Check the NBUKitDemo project for other ways to customize displaying the last taken pictures.
@property (assign, nonatomic) IBOutlet UIImageView * lastPictureImageView;

@end
