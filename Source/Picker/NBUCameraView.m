//
//  NBUCameraView.m
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

#import "NBUCameraView.h"
#import "NBUKitPrivate.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "RKOrderedDictionary.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_CAMERA_ASSETS

// Private categories and classes
@interface NBUCameraView (Private) <AVCaptureFileOutputRecordingDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>

@end

@interface PointOfInterestView : UIView

@end


@implementation NBUCameraView
{
    NSMutableArray * _controls;
    AVCaptureDevice * _currentDevice;
    AVCaptureSession * _captureSession;
    AVCaptureVideoPreviewLayer * _previewLayer;
    AVCaptureDeviceInput * _captureInput;
    AVCaptureStillImageOutput * _captureImageOutput;
    AVCaptureMovieFileOutput * _captureMovieOutput;
    AVCaptureVideoDataOutput * _captureVideoDataOutput;
    AVCaptureConnection * _videoConnection;
    PointOfInterestView * _poiView;
    NSDate * _lastSequenceCaptureDate;
    UIImageOrientation _sequenceCaptureOrientation;
    
#ifdef __i386__
    // Mock image for simulator
    UIImage * _mockImage;
#endif
}

@synthesize targetResolution = _targetResolution;
@synthesize captureResultBlock = _captureResultBlock;
@synthesize captureMovieResultBlock = _captureMovieResultBlock;
@synthesize saveResultBlock = _saveResultBlock;
@synthesize savePicturesToLibrary = _savePicturesToLibrary;
@synthesize targetLibraryAlbumName = _targetLibraryAlbumName;
@synthesize capturingSequence = _capturingSequence;
@synthesize sequenceCaptureInterval = _sequenceCaptureInterval;
@synthesize targetMovieFolder = _targetMovieFolder;
@synthesize shouldAutoRotateView = _shouldAutoRotateView;
@synthesize keepFrontCameraPicturesMirrored = _keepFrontCameraPicturesMirrored;
@synthesize availableCaptureDevices = _availableCaptureDevices;
@synthesize availableResolutions = _availableResolutions;
@synthesize availableFlashModes = _availableFlashModes;
@synthesize availableFocusModes = _availableFocusModes;
@synthesize availableExposureModes = _availableExposureModes;
@synthesize availableWhiteBalanceModes = _availableWhiteBalanceModes;
@synthesize showDisabledControls = _showDisabledControls;
@synthesize shootButtonConfigurationBlock = _shootButtonConfigurationBlock;
@synthesize toggleCameraButtonConfigurationBlock = _toggleCameraButtonConfigurationBlock;
@synthesize flashButtonConfigurationBlock = _flashButtonConfigurationBlock;
@synthesize focusButtonConfigurationBlock = _focusButtonConfigurationBlock;
@synthesize exposureButtonConfigurationBlock = _exposureButtonConfigurationBlock;
@synthesize whiteBalanceButtonConfigurationBlock = _whiteBalanceButtonConfigurationBlock;
@synthesize shootButton = _shootButton;
@synthesize toggleCameraButton = _toggleCameraButton;
@synthesize flashButton = _flashButton;
@synthesize focusButton = _focusButton;
@synthesize exposureButton = _exposureButton;
@synthesize whiteBalanceButton = _whiteBalanceButton;
@synthesize lastPictureImageView = _lastPictureImageView;
@synthesize animateLastPictureImageView = _animateLastPictureImageView;

- (void)commonInit
{
    [super commonInit];
    
    // Configure the view
    self.clipsToBounds = YES;
    self.recognizeTap = YES;
    self.doNotHighlightOnTap = YES;
    self.recognizeDoubleTap = YES;
    self.highlightColor = [UIColor colorWithWhite:1.0
                                            alpha:0.7];
    _animateLastPictureImageView = YES;
    
    // PoI view
    _poiView = [PointOfInterestView new];
    [self addSubview:_poiView];
    
#ifdef __i386__
    // Mock image for simulator
    _mockImage = [UIImage imageNamed:@"Default"];
    UIImageView * mockView = [[UIImageView alloc] initWithImage:_mockImage];
    mockView.contentMode = UIViewContentModeScaleAspectFill;
    mockView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    mockView.frame = self.bounds;
    [self insertSubview:mockView
                atIndex:0];
#endif
    
    // First orientation update
    [self setDeviceOrientation:[UIDevice currentDevice].orientation];
    
    // Observe orientation changes
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)dealloc
{
    // Stop observing
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    
    // Gather the available UI controls
    if (!_controls)
    {
        _controls = [NSMutableArray array];
        if (_shootButton) [_controls addObject:_shootButton];
        if (_toggleCameraButton) [_controls addObject:_toggleCameraButton];
        if (_flashButton) [_controls addObject:_flashButton];
        if (_focusButton) [_controls addObject:_focusButton];
        if (_exposureButton) [_controls addObject:_exposureButton];
        if (_whiteBalanceButton) [_controls addObject:_whiteBalanceButton];
    }
    
    // Create a capture session if needed
    if (!_captureSession)
    {
        _captureSession = [AVCaptureSession new];
    }
    
    
    // Create the preview layer
    if (!_previewLayer)
    {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _previewLayer.frame = self.layer.bounds;
        [self.layer insertSublayer:_previewLayer
                           atIndex:0];
    }
    
    // Configure output if needed
    if (!_captureImageOutput)
    {
        _captureImageOutput = [AVCaptureStillImageOutput new];
        if ([_captureSession canAddOutput:_captureImageOutput])
            [_captureSession addOutput:_captureImageOutput];
        else
        {
            NBULogError(@"Can't add output: %@ to session: %@", _captureImageOutput, _captureSession);
            return;
        }
        NBULogVerbose(@"Output: %@ settings: %@", _captureImageOutput, _captureImageOutput.outputSettings);
    }
    
    // Get a capture device if needed
    if (!_currentDevice && !_availableCaptureDevices)
    {
#ifndef __i386__
        // Real devices
        self.currentAVCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
#else
        // Simulator (iOS5 simulator reports an input device while iOS6 simulator doesn't)
        self.currentAVCaptureDevice = nil;
#endif
    }
    
    // Start session
    [_captureSession startRunning];
    _shootButton.enabled = YES;
    NBULogVerbose(@"Capture session: {\n%@} started running", _captureSession);
}

- (void)viewWillDisappear
{
    [super viewWillDisappear];
    
    // Stop session
    _shootButton.enabled = NO;
    [_captureSession stopRunning];
    NBULogVerbose(@"Capture session: {\n%@} stopped running", _captureSession);
}

#pragma mark - Handle orientation changes

- (void)setFrame:(CGRect)frame
{
    super.frame = frame;
    
    // Resize the preview layer as well
//    _previewLayer.frame = self.layer.bounds;
}

- (void)deviceOrientationChanged:(NSNotification *)notification
{
    [self setDeviceOrientation:[UIDevice currentDevice].orientation];
}

- (void)setDeviceOrientation:(UIDeviceOrientation)orientation
{
    if (UIDeviceOrientationIsValidInterfaceOrientation(orientation))
    {
        [self setInterfaceOrientation:UIInterfaceOrientationFromValidDeviceOrientation(orientation)];
    }
}

- (void)setInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    // Update video orientation
    if (_videoConnection.isVideoOrientationSupported)
    {
        _videoConnection.videoOrientation = (AVCaptureVideoOrientation)orientation;
    }
    
    // Also rotate view?
    if (_shouldAutoRotateView)
    {
        // Angle to rotate
        CGFloat angle;
        switch (orientation)
        {
            case UIInterfaceOrientationLandscapeRight:
                angle = - M_PI / 2.0;
                break;
            case UIInterfaceOrientationLandscapeLeft:
                angle = M_PI / 2.0;
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                angle = M_PI;
                break;
            case UIInterfaceOrientationPortrait:
            default:
                angle = 0;
                break;
        }
        
        // Flip height and width?
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            _previewLayer.bounds = CGRectMake(0.0,
                                              0.0,
                                              self.layer.bounds.size.height,
                                              self.layer.bounds.size.width);
        }
        // Just resize for portrait
        else
        {
            _previewLayer.bounds = CGRectMake(0.0,
                                              0.0,
                                              self.layer.bounds.size.width,
                                              self.layer.bounds.size.height);
        }
        
        // Rotate
        _previewLayer.transform = CATransform3DRotate(CATransform3DIdentity,
                                                      angle,
                                                      0.0, 0.0, 1.0);
        
        // Reposition
        _previewLayer.position = CGPointMake(self.layer.bounds.size.width / 2.0,
                                             self.layer.bounds.size.height / 2.0);
        
        NBULogVerbose(@"%@ anchorPoint: %@ position: %@ frame: %@ bounds: %@",
                      THIS_METHOD,
                      NSStringFromCGPoint(_previewLayer.anchorPoint),
                      NSStringFromCGPoint(_previewLayer.position),
                      NSStringFromCGRect(_previewLayer.frame),
                      NSStringFromCGRect(_previewLayer.bounds));
    }
}

#pragma mark - Properties

- (void)setCurrentCaptureDevice:(NSString *)currentCaptureDevice
{
    self.currentAVCaptureDevice = [AVCaptureDevice deviceWithUniqueID:currentCaptureDevice];
}

- (NSString *)currentCaptureDevice
{
    return _currentDevice.uniqueID;
}

- (void)setCurrentAVCaptureDevice:(AVCaptureDevice *)device
{
    if ([_currentDevice.uniqueID isEqualToString:device.uniqueID])
        return;
    
    NBULogVerbose(@"%@: %@", THIS_METHOD, device);
    _currentDevice = device;
    
    // Other available devices
    NSMutableArray * tmp = [NSMutableArray array];
#ifndef __i386__
    for (AVCaptureDevice * other in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo])
        [tmp addObject:other.uniqueID];
#endif
    _availableCaptureDevices = [NSArray arrayWithArray:tmp];
    NBULogVerbose(@"availableCaptureDevices: %@", _availableCaptureDevices);
    
    // Available flash modes
    [tmp removeAllObjects];
    if ([_currentDevice isFlashModeSupported:AVCaptureFlashModeOff])
        [tmp addObject:@(AVCaptureFlashModeOff)];
    if ([_currentDevice isFlashModeSupported:AVCaptureFlashModeOn])
        [tmp addObject:@(AVCaptureFlashModeOn)];
    if ([_currentDevice isFlashModeSupported:AVCaptureFlashModeAuto])
        [tmp addObject:@(AVCaptureFlashModeAuto)];
    _availableFlashModes = [NSArray arrayWithArray:tmp];
    NBULogVerbose(@"availableFlashModes: %@", _availableFlashModes);
    
    // Available focus modes
    [tmp removeAllObjects];
    if ([_currentDevice isFocusModeSupported:AVCaptureFocusModeLocked])
        [tmp addObject:@(AVCaptureFocusModeLocked)];
    if ([_currentDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus])
        [tmp addObject:@(AVCaptureFocusModeAutoFocus)];
    if ([_currentDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
        [tmp addObject:@(AVCaptureFocusModeContinuousAutoFocus)];
    _availableFocusModes = [NSArray arrayWithArray:tmp];
    NBULogVerbose(@"availableFocusModes: %@", _availableFocusModes);
    
    // Available exposure modes
    [tmp removeAllObjects];
    if ([_currentDevice isExposureModeSupported:AVCaptureExposureModeLocked])
        [tmp addObject:@(AVCaptureExposureModeLocked)];
    if ([_currentDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose])
        [tmp addObject:@(AVCaptureExposureModeAutoExpose)];
    if ([_currentDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
        [tmp addObject:@(AVCaptureExposureModeContinuousAutoExposure)];
    _availableExposureModes = [NSArray arrayWithArray:tmp];
    NBULogVerbose(@"availableExposureModes: %@", _availableExposureModes);
    
    // Available white balance modes
    [tmp removeAllObjects];
    if ([_currentDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeLocked])
        [tmp addObject:@(AVCaptureWhiteBalanceModeLocked)];
    if ([_currentDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance])
        [tmp addObject:@(AVCaptureWhiteBalanceModeAutoWhiteBalance)];
    if ([_currentDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance])
        [tmp addObject:@(AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance)];
    _availableWhiteBalanceModes = [NSArray arrayWithArray:tmp];
    NBULogVerbose(@"availableWhiteBalanceModes: %@", _availableWhiteBalanceModes);
    
    // Update UI
    [self updateUI];
    
#ifndef __i386__
    // Update capture session
    [self updateCaptureSessionInput];
#endif
}

- (void)updateUI
{
    // Enable/disable controls
    _toggleCameraButton.enabled = _availableCaptureDevices.count > 1;
    _flashButton.enabled = _availableFlashModes.count > 1;
    _focusButton.enabled = _availableFocusModes.count > 1;
    _exposureButton.enabled = _availableExposureModes.count > 1;
    _whiteBalanceButton.enabled = _availableWhiteBalanceModes.count > 1;
    
    // Hide disabled controls?
    if (!_showDisabledControls)
    {
        for (id<UIButton> button in _controls)
        {
            if ([button isKindOfClass:[UIView class]])
            {
                ((UIView *)button).hidden = !button.enabled;
            }
        }
    }
    
    // Apply configuration blocks
    if(_shootButtonConfigurationBlock)
        _shootButtonConfigurationBlock(_shootButton, 0); // TODO:
    if(_toggleCameraButtonConfigurationBlock)
        _toggleCameraButtonConfigurationBlock(_toggleCameraButton, _currentDevice.position);
    if(_flashButtonConfigurationBlock)
        _flashButtonConfigurationBlock(_flashButton, _currentDevice.flashMode);
    if(_focusButtonConfigurationBlock)
        _focusButtonConfigurationBlock(_focusButton, _currentDevice.focusMode);
    if(_exposureButtonConfigurationBlock)
        _exposureButtonConfigurationBlock(_exposureButton, _currentDevice.exposureMode);
    if(_whiteBalanceButtonConfigurationBlock)
        _whiteBalanceButtonConfigurationBlock(_whiteBalanceButton, _currentDevice.whiteBalanceMode);
}

- (NBUButtonConfigurationBlock)buttonConfigurationBlockWithTitleFormat:(NSString *)format
{
    return ^(id<UIButton> button, NSInteger mode)
    {
        button.title = [NSString stringWithFormat:format, mode];
    };
}

- (NBUButtonConfigurationBlock)buttonConfigurationBlockWithTitleFrom:(NSArray *)titles
{
    return ^(id<UIButton> button, NSInteger mode)
    {
        button.title = titles[mode];
    };
}

- (void)updateCaptureSessionInput
{
    [_captureSession beginConfiguration];
    
    // Remove previous input
    [_captureSession removeInput:_captureInput];
    
    // Create a capture input
    NSError * error;
    _captureInput = [AVCaptureDeviceInput deviceInputWithDevice:_currentDevice
                                                          error:&error];
    if (error)
    {
        NBULogError(@"Error creating an AVCaptureDeviceInput: %@", error);
    }
    
    // Add input to session
    if ([_captureSession canAddInput:_captureInput])
    {
        [_captureSession addInput:_captureInput];
        NBULogVerbose(@"Input: %@", _captureInput);
    }
    else
    {
        NBULogError(@"Can't add input: %@ to session: %@", _captureInput, _captureSession);
    }
    
    // Refresh the video connection
    _videoConnection = nil;
    for (AVCaptureConnection * connection in _captureImageOutput.connections)
    {
        for (AVCaptureInputPort * port in connection.inputPorts)
        {
            if ([port.mediaType isEqualToString:AVMediaTypeVideo])
            {
                _videoConnection = connection;
                break;
            }
        }
        if (_videoConnection)
        {
            NBULogVerbose(@"Video connection: %@", _videoConnection);
            
            // Handle fron camera video mirroring
            if (_currentDevice.position == AVCaptureDevicePositionFront &&
                _videoConnection.supportsVideoMirroring)
            {
                _videoConnection.videoMirrored = _keepFrontCameraPicturesMirrored;
            }
            
            break;
        }
    }
    if (!_videoConnection)
    {
        NBULogError(@"Couldn't create video connection for output: %@", _captureImageOutput);
    }
    
    // Choose the best suited session presset
    [_captureSession setSessionPreset:[self bestSuitedSessionPresetForResolution:_targetResolution]];
    
    [_captureSession commitConfiguration];
}

- (NSString *)bestSuitedSessionPresetForResolution:(CGSize)targetResolution
{
    // Not set?
    if (CGSizeEqualToSize(targetResolution, CGSizeZero))
    {
        NBULogInfo(@"No target resolution was set. Capturing full resolution pictures.");
        return AVCaptureSessionPresetPhoto;
    }
    
    // Make sure to have a portrait size
    CGSize target = targetResolution.width >= targetResolution.height ? targetResolution : CGSizeMake(targetResolution.height,
                                                                                                      targetResolution.width);
    // Try different resolutions
    NSString * preset;
    NSDictionary * resolutions = [self availableResolutions];
    CGSize resolution;
    for (preset in resolutions)
    {
        resolution = [(NSValue *)resolutions[preset] CGSizeValue];
        if (resolution.width >= target.width &&
            resolution.height >= target.height)
        {
            break;
        }
    }
    
    NBULogInfo(@"Best preset for target resolution %@ is '%@'",
               NSStringFromCGSize(target), preset);
    return preset;
}

#define sizeObject(width, height) [NSValue valueWithCGSize:CGSizeMake(width, height)]

- (NSDictionary *)availableResolutions
{
    // Possible resolutions
    NSArray * presets;
    NSDictionary * possibleResolutions;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
    {
        presets = @[AVCaptureSessionPresetLow,
                    AVCaptureSessionPreset352x288,
                    AVCaptureSessionPresetMedium,
                    AVCaptureSessionPreset640x480,
                    AVCaptureSessionPresetiFrame960x540,
                    AVCaptureSessionPreset1280x720,
                    AVCaptureSessionPreset1920x1080,
                    AVCaptureSessionPresetPhoto];
        possibleResolutions = @{
                                AVCaptureSessionPresetLow           : sizeObject(192.0, 144.0),             // iOS4+
                                AVCaptureSessionPreset352x288       : sizeObject(352.0, 288.0),             // iOS5+
                                AVCaptureSessionPresetMedium        : sizeObject(480.0, 360.0),             // iOS4+,
                                AVCaptureSessionPreset640x480       : sizeObject(640.0, 480.0),             // iOS4+
                                AVCaptureSessionPresetiFrame960x540 : sizeObject(960.0, 540.0),             // iOS5+
                                AVCaptureSessionPreset1280x720      : sizeObject(1280.0, 720.0),            // iOS4+
                                AVCaptureSessionPreset1920x1080     : sizeObject(1920.0, 1080.0),           // iOS5+
                                AVCaptureSessionPresetPhoto         : sizeObject(CGFLOAT_MAX, CGFLOAT_MAX)};// iOS4+, Full resolution
    }
    else
    {
        presets = @[AVCaptureSessionPresetLow,
                    AVCaptureSessionPresetMedium,
                    AVCaptureSessionPreset640x480,
                    AVCaptureSessionPreset1280x720,
                    AVCaptureSessionPresetPhoto];
        possibleResolutions = @{
                                AVCaptureSessionPresetLow           : sizeObject(192.0, 144.0),             // iOS4+
                                AVCaptureSessionPresetMedium        : sizeObject(480.0, 360.0),             // iOS4+,
                                AVCaptureSessionPreset640x480       : sizeObject(640.0, 480.0),             // iOS4+
                                AVCaptureSessionPreset1280x720      : sizeObject(1280.0, 720.0),            // iOS4+
                                AVCaptureSessionPresetPhoto         : sizeObject(CGFLOAT_MAX, CGFLOAT_MAX)};// iOS4+, Full resolution
    }
    
    // Resolutions available for the current device
    RKOrderedDictionary * availableResolutions = [RKOrderedDictionary dictionary];
    for (NSString * preset in presets)
    {
        if ([_currentDevice supportsAVCaptureSessionPreset:preset])
        {
            availableResolutions[preset] = possibleResolutions[preset];
        }
    }
    NBULogVerbose(@"Available resolutions for %@: %@", _currentDevice, availableResolutions);
    
    return availableResolutions;
}

#pragma mark - Actions

- (void)takePicture:(id)sender
{
    NBULogTrace();
    
    // Update UI
    _shootButton.enabled = NO;
    self.window.userInteractionEnabled = NO;
    [self flashHighlightMask];
    
#ifndef __i386__
    // Get the image
    [_captureImageOutput captureStillImageAsynchronouslyFromConnection:_videoConnection
                                                     completionHandler:^(CMSampleBufferRef imageDataSampleBuffer,
                                                                         NSError * error)
     {
         if (error)
         {
             NBULogError(@"Error: %@", error);
             _shootButton.enabled = YES;
             self.window.userInteractionEnabled = YES;
             
             // Execute result blocks
             if (_captureResultBlock) _captureResultBlock(nil, error);
             if (_savePicturesToLibrary && _saveResultBlock) _saveResultBlock(nil, nil, nil, error);
             
             return;
         }
         else
         {
             UIImage * image = [UIImage imageWithData:
                                [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer]];
             
             NBULogInfo(@"Captured jpeg image: %@ of size: %@ orientation: %d",
                        image, NSStringFromCGSize(image.size), image.imageOrientation);
#else
             // Mock simulator
             UIImage * image = _mockImage;
             NBULogInfo(@"Captured mock image: %@ of size: %@",
                        image, NSStringFromCGSize(_mockImage.size));
#endif     
             // Update last picture view
             if (_lastPictureImageView)
             {
                 if (_animateLastPictureImageView)
                 {
                     static UIImageView * preview;
                     static dispatch_once_t onceToken;
                     dispatch_once(&onceToken, ^
                                   {
                                       preview = [[NBURotatingImageView alloc] initWithImage:image];
                                       preview.contentMode = UIViewContentModeScaleAspectFill;
                                       preview.clipsToBounds = YES;
                                       [self.viewController.view addSubview:preview];
                                   });
                     preview.frame = [self.viewController.view convertRect:self.bounds
                                                                  fromView:self];
                     preview.hidden = NO;
                     
                     // Update UI
                     [UIView animateWithDuration:0.2
                                           delay:0.0
                                         options:UIViewAnimationOptionCurveEaseIn
                                      animations:^
                      {
                          preview.frame = [self.viewController.view convertRect:_lastPictureImageView.bounds
                                                                       fromView:_lastPictureImageView];
                      }
                                      completion:^(BOOL finished)
                      {
                          //_lastPictureImageView.image = [image thumbnailWithSize:_lastPictureImageView.size];
                          _lastPictureImageView.image = image;
                          preview.hidden = YES;
                          
                          _shootButton.enabled = YES;
                          self.window.userInteractionEnabled = YES;
                      }];
                 }
                 else
                 {
                     //_lastPictureImageView.image = [image thumbnailWithSize:_lastPictureImageView.size];
                     _lastPictureImageView.image = image;
                     
                     _shootButton.enabled = YES;
                     self.window.userInteractionEnabled = YES;
                 }
             }
             else
             {
                 _shootButton.enabled = YES;
                 self.window.userInteractionEnabled = YES;
             }
             
             // Execute capture block
             dispatch_async(dispatch_get_main_queue(),
                            ^{
                                if (_captureResultBlock) _captureResultBlock(image, nil);
                            });
             
             // No need to save image?
             if (!_savePicturesToLibrary)
                 return;
             
             // Retrieve the metadata
             NSDictionary * metadata;
#ifndef __i386__
             metadata = (__bridge_transfer NSDictionary *)CMCopyDictionaryOfAttachments(kCFAllocatorDefault,
                                                                                        imageDataSampleBuffer,
                                                                                        kCMAttachmentMode_ShouldPropagate);
             NBULogInfo(@"Image metadata: %@", metadata);
#endif
             
             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^
                            {
                                // Read metadata
                                
                                // Save to the Camera Roll
                                [[NBUAssetsLibrary sharedLibrary] saveImageToCameraRoll:image
                                                                               metadata:metadata
                                                               addToAssetsGroupWithName:_targetLibraryAlbumName
                                                                            resultBlock:^(NSURL * assetURL,
                                                                                          NSError * saveError)
                                 {
                                     // Execute result block
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         if (_saveResultBlock) _saveResultBlock(image,
                                                                                metadata,
                                                                                assetURL,
                                                                                saveError);
                                     });
                                 }];
                            });
#ifndef __i386__
         }
     }];
#endif
}

- (IBAction)startStopPictureSequence:(id)sender
{
    if (!_capturingSequence)
    {
        if (!_captureVideoDataOutput)
        {
            _captureVideoDataOutput = [AVCaptureVideoDataOutput new];
            _captureVideoDataOutput.videoSettings = @{(NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
            [_captureVideoDataOutput setSampleBufferDelegate:self
                                                       queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)];
            if (_sequenceCaptureInterval == 0)
            {
                _sequenceCaptureInterval = 0.25;
            }
        }
        
        if ([_captureSession canAddOutput:_captureVideoDataOutput])
        {
            [_captureSession addOutput:_captureVideoDataOutput];
            _lastSequenceCaptureDate = [NSDate date]; // Skip the first image which looks to dark for some reason
            _sequenceCaptureOrientation = (_currentDevice.position == AVCaptureDevicePositionFront ? // Set the output orientation only once per sequence
                                           UIImageOrientationLeftMirrored :
                                           UIImageOrientationRight);
            _capturingSequence = YES;
        }
        else
        {
            NBULogError(@"Can't capture picture sequences here!");
            return;
        }
    }
    else
    {
        [_captureSession removeOutput:_captureVideoDataOutput];
        _capturingSequence = NO;
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    // Skip capture?
    if ([[NSDate date] timeIntervalSinceDate:_lastSequenceCaptureDate] < _sequenceCaptureInterval)
        return;
    
    _lastSequenceCaptureDate = [NSDate date];
    
    UIImage * image = [self imageFromSampleBuffer:sampleBuffer];
    NBULogInfo(@"Captured image: %@ of size: %@ orientation: %d",
               image, NSStringFromCGSize(image.size), image.imageOrientation);
    
    // Execute capture block
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       if (_captureResultBlock) _captureResultBlock(image, nil);
                   });
}

- (BOOL)isRecording
{
    return _captureMovieOutput.recording;
}

- (IBAction)startStopRecording:(id)sender
{
    if (!self.recording)
    {
        if (!_captureMovieOutput)
        {
            _captureMovieOutput = [AVCaptureMovieFileOutput new];
        }
        
        if ([_captureSession canAddOutput:_captureMovieOutput])
        {
            [_captureSession addOutput:_captureMovieOutput];
        }
        else
        {
            NBULogError(@"Can't record movies here!");
            return;
        }
        
        if (!_targetMovieFolder)
        {
            _targetMovieFolder = [UIApplication sharedApplication].documentsDirectory;
        }
        NSURL * movieOutputURL = [NSFileManager URLForNewFileAtDirectory:_targetMovieFolder
                                                      fileNameWithFormat:@"movie%02d.mov"];
        
        [_captureMovieOutput startRecordingToOutputFileURL:movieOutputURL
                                         recordingDelegate:self];
    }
    else
    {
        [_captureMovieOutput stopRecording];
    }
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
      fromConnections:(NSArray *)connections
                error:(NSError *)error
{
    if (!error)
    {
        NBULogInfo(@"Finished capturing movie to %@", outputFileURL);
    }
    else
    {
        NBULogError(@"Error capturing movie: %@", error);
    }
    
    [_captureSession removeOutput:_captureMovieOutput];
    if (_captureMovieResultBlock) _captureMovieResultBlock(outputFileURL, error);
}

- (void)toggleCamera:(id)sender
{
    NBULogTrace();
    
    self.currentCaptureDevice = [_availableCaptureDevices objectAfter:_currentDevice.uniqueID
                                                                 wrap:YES];
}

- (void)updateDeviceConfigurationWithBlock:(void (^)(void))block
{
    NSError * error;
    if (![_currentDevice lockForConfiguration:&error])
    {
        NBULogError(@"Error: %@", error);
        return;
    }
    block();
    [_currentDevice unlockForConfiguration];
    
    [self updateUI];
}

- (AVCaptureFlashMode)currentFlashMode
{
    return _currentDevice.flashMode;
}

- (void)setCurrentFlashMode:(AVCaptureFlashMode)currentFlashMode
{
    NBULogInfo(@"%@: %d", THIS_METHOD, currentFlashMode);
    
    [self updateDeviceConfigurationWithBlock:^{
        _currentDevice.flashMode = currentFlashMode;
    }];
}

- (void)toggleFlashMode:(id)sender
{
    self.currentFlashMode = [[_availableFlashModes objectAfter:@(self.currentFlashMode)
                                                          wrap:YES] integerValue];
}

- (AVCaptureFocusMode)currentFocusMode
{
    return _currentDevice.focusMode;
}

- (void)setCurrentFocusMode:(AVCaptureFocusMode)currentFocusMode
{
    NBULogInfo(@"%@: %d", THIS_METHOD, currentFocusMode);
    
    [self updateDeviceConfigurationWithBlock:^{
        _currentDevice.focusMode = currentFocusMode;
    }];
}

- (void)toggleFocusMode:(id)sender
{
    self.currentFocusMode = [[_availableFocusModes objectAfter:@(self.currentFocusMode)
                                                          wrap:YES] integerValue];
}

- (AVCaptureExposureMode)currentExposureMode
{
    return _currentDevice.exposureMode;
}

- (void)setCurrentExposureMode:(AVCaptureExposureMode)currentExposureMode
{
    NBULogInfo(@"%@: %d", THIS_METHOD, currentExposureMode);
    
    [self updateDeviceConfigurationWithBlock:^{
        _currentDevice.exposureMode = currentExposureMode;
    }];
}

- (void)toggleExposureMode:(id)sender
{
    self.currentExposureMode = [[_availableExposureModes objectAfter:@(self.currentExposureMode)
                                                                wrap:YES] integerValue];
}

- (AVCaptureWhiteBalanceMode)currentWhiteBalanceMode
{
    return _currentDevice.whiteBalanceMode;
}

- (void)setCurrentWhiteBalanceMode:(AVCaptureWhiteBalanceMode)currentWhiteBalanceMode
{
    NBULogInfo(@"%@: %d", THIS_METHOD, currentWhiteBalanceMode);
    
    [self updateDeviceConfigurationWithBlock:^{
        _currentDevice.whiteBalanceMode = currentWhiteBalanceMode;
    }];
}

- (void)toggleWhiteBalanceMode:(id)sender
{
    self.currentWhiteBalanceMode = [[_availableWhiteBalanceModes objectAfter:@(self.currentWhiteBalanceMode)
                                                                        wrap:YES] integerValue];
}

#pragma mark - Gestures

- (void)tapped:(UITapGestureRecognizer *)sender
{
    if (!_currentDevice || ![sender isKindOfClass:[UITapGestureRecognizer class]])
        return;
    
    [super tapped:sender];
    
    // Calculate the point of interest
    CGPoint tapPoint = [sender locationInView:self];
    CGPoint pointOfInterest = [self convertToPointOfInterestFromViewCoordinates:tapPoint];
    _poiView.center = tapPoint;
    
    NBULogVerbose(@"Adjust point of interest: %@ > %@",
                  NSStringFromCGPoint(tapPoint), NSStringFromCGPoint(pointOfInterest));
    
    __block BOOL adjustingConfiguration = NO;
    
    [self updateDeviceConfigurationWithBlock:^{
        
        if (_currentDevice.isFocusPointOfInterestSupported)
        {
            NBULogVerbose(@"Focus point of interest...");
            _currentDevice.focusPointOfInterest = pointOfInterest;
            adjustingConfiguration = YES;
        }
        if ([_currentDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus])
        {
            NBULogVerbose(@"Focusing...");
            _currentDevice.focusMode = AVCaptureFocusModeAutoFocus;
            adjustingConfiguration = YES;
        }
        if (_currentDevice.isExposurePointOfInterestSupported)
        {
            NBULogVerbose(@"Exposure point of interest...");
            _currentDevice.exposurePointOfInterest = pointOfInterest;
            adjustingConfiguration = YES;
        }
        if ([_currentDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose])
        {
            NBULogVerbose(@"Adjusting exposure...");
            _currentDevice.exposureMode = AVCaptureExposureModeAutoExpose;
            adjustingConfiguration = YES;
        }
        if ([_currentDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance])
        {
            NBULogVerbose(@"Adjusting white balance...");
            _currentDevice.whiteBalanceMode = AVCaptureWhiteBalanceModeAutoWhiteBalance;
            adjustingConfiguration = YES;
        }
    }];
    
    if (adjustingConfiguration)
    {
        [self flashPoIView];
    }
    else
    {
        NBULogVerbose(@"Nothing to adjust for device: %@", _currentDevice);
    }
}

- (void)flashPoIView
{
    // We need to stop the animation after a while
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.9 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
                       [_poiView.layer removeAllAnimations];
                       _poiView.alpha = 0.0;
                   });
    
    [UIView animateWithDuration:0.15
                          delay:0.0
                        options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat
                     animations:^{
                         _poiView.alpha = 1.0;
                     }
                     completion:NULL];
}

- (void)doubleTapped:(UITapGestureRecognizer *)sender
{
    [super doubleTapped:sender];
    
    if (![sender isKindOfClass:[UITapGestureRecognizer class]])
        return;
}

// From Apple AVCam demo
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates
{
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = self.size;
    
    if (SYSTEM_VERSION_LESS_THAN(@"6.0") ? _previewLayer.isMirrored : _videoConnection.isVideoMirrored)
    {
        viewCoordinates.x = frameSize.width - viewCoordinates.x;
    }
    
    if ( [[_previewLayer videoGravity] isEqualToString:AVLayerVideoGravityResize] ) {
		// Scale, switch x and y, and reverse x
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
    } else {
        CGRect cleanAperture;
        for (AVCaptureInputPort *port in [_captureInput ports]) {
            if ([port mediaType] == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = .5f;
                CGFloat yc = .5f;
                
                if ( [[_previewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspect] ) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
						// If point is inside letterboxed area, do coordinate conversion; otherwise, don't change the default value returned (.5,.5)
                        if (point.x >= blackBar && point.x <= blackBar + x2) {
							// Scale (accounting for the letterboxing on the left and right of the video preview), switch x and y, and reverse x
                            xc = point.y / y2;
                            yc = 1.f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
						// If point is inside letterboxed area, do coordinate conversion. Otherwise, don't change the default value returned (.5,.5)
                        if (point.y >= blackBar && point.y <= blackBar + y2) {
							// Scale (accounting for the letterboxing on the top and bottom of the video preview), switch x and y, and reverse x
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.f - (point.x / x2);
                        }
                    }
                } else if ([[_previewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
					// Scale, switch x and y, and reverse x
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2; // Account for cropped height
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2); // Account for cropped width
                        xc = point.y / frameSize.height;
                    }
                }
                
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    
    return pointOfInterest;
}

#pragma mark - Other methods

// Create a UIImage from sample buffer data
// Based on http://stackoverflow.com/questions/8924299/ios-capturing-image-using-avframework
- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage
                                         scale:1.0
                                   orientation:_sequenceCaptureOrientation];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}

@end


@implementation PointOfInterestView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(10.0, 10.0, 75.0, 75.0)];
    if (self)
    {
        self.alpha = 0.0;
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.contentStretch = CGRectMake(0.2, 0.2, 0.6, 0.6);
        self.autoresizingMask = UIViewAutoresizingNone;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    UIColor * pathColor = [UIColor colorWithRed:1.0
                                          green:1.0
                                           blue:1.0
                                          alpha:1.0];
    UIColor * shadowColor = [UIColor colorWithRed:0.0
                                            green:0.706
                                             blue:1.0
                                            alpha:0.8];
    CGSize shadowOffset = CGSizeZero;
    CGFloat shadowBlurRadius = 6.0;
    
    // Draw
    UIBezierPath * roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect:
                                           CGRectMake(shadowBlurRadius,
                                                      shadowBlurRadius,
                                                      self.size.width - 2 * shadowBlurRadius,
                                                      self.size.height - 2 * shadowBlurRadius)
                                                                     cornerRadius:4.0];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context,
                                shadowOffset,
                                shadowBlurRadius,
                                shadowColor.CGColor);
    [pathColor setStroke];
    roundedRectanglePath.lineWidth = 1.0;
    [roundedRectanglePath stroke];
    CGContextRestoreGState(context);
}

@end
