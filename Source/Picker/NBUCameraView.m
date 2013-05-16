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
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "RKOrderedDictionary.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_CAMERA_ASSETS

// Private class
@interface PointOfInterestView : UIView

@end

@implementation NBUCameraView
{
    NSMutableArray * _controls;
    AVCaptureDevice * _currentDevice;
    AVCaptureSession * _captureSession;
    AVCaptureVideoPreviewLayer * _previewLayer;
    AVCaptureDeviceInput * _captureInput;
    AVCaptureStillImageOutput * _captureOutput;
    AVCaptureConnection * _videoConnection;
    PointOfInterestView * _poiView;
    
#ifdef __i386__
    // Mock image for simulator
    UIImage * _mockImage;
#endif
}

@synthesize targetResolution = _targetResolution;
@synthesize captureResultBlock = _captureResultBlock;
@synthesize saveResultBlock = _saveResultBlock;
@synthesize savePicturesToLibrary = _savePicturesToLibrary;
@synthesize targetLibraryAlbumName = _targetLibraryAlbumName;
@synthesize shouldAutoRotateView = _shouldAutoRotateView;
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
    [self addSubview:mockView];
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
    if (!_captureOutput)
    {
        _captureOutput = [AVCaptureStillImageOutput new];
        if ([_captureSession canAddOutput:_captureOutput])
            [_captureSession addOutput:_captureOutput];
        else
        {
            NBULogError(@"Can't add output: %@ to session: %@", _captureOutput, _captureSession);
            return;
        }
        NBULogVerbose(@"Output: %@ settings: %@", _captureOutput, _captureOutput.outputSettings);
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
    _videoConnection.videoOrientation = (AVCaptureVideoOrientation)UIInterfaceOrientationFromValidDeviceOrientation(orientation);
    
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
    for (AVCaptureConnection * connection in _captureOutput.connections)
    {
        for (AVCaptureInputPort * port in [connection inputPorts])
        {
            if ([port.mediaType isEqual:AVMediaTypeVideo])
            {
                _videoConnection = connection;
                break;
            }
        }
        if (_videoConnection)
        {
            NBULogVerbose(@"Video connection: %@", _videoConnection);
            break;
        }
    }
    if (!_videoConnection)
    {
        NBULogError(@"Couldn't create video connection for output: %@", _captureOutput);
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
    
#ifndef __i386__
    // Update UI
    _shootButton.enabled = NO;
    [self flashHighlightMask];
    self.window.userInteractionEnabled = NO;
    
    // Get the image
    [_captureOutput captureStillImageAsynchronouslyFromConnection:_videoConnection
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
             
             // Execute capture block
             if (_captureResultBlock) _captureResultBlock(image, nil);
             
             NSDictionary * metadata = (__bridge_transfer NSDictionary *)CMCopyDictionaryOfAttachments(kCFAllocatorDefault,
                                                                                                       imageDataSampleBuffer,
                                                                                                       kCMAttachmentMode_ShouldPropagate);
             NBULogVerbose(@"Metadata: %@", metadata);
             
             // Update UI
             dispatch_async(dispatch_get_main_queue(),
                            ^{
                                _shootButton.enabled = YES;
                                self.window.userInteractionEnabled = YES;
                                
                                // Update last picture view
                                if (_lastPictureImageView)
                                {
                                    _lastPictureImageView.image = [image thumbnailWithSize:_lastPictureImageView.size];
                                }
                            });
             
             // No need to save image?
             if (!_savePicturesToLibrary)
                 return;
             
             // Save to the Camera Roll
             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                 
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
         }
     }];
    
#else
    // Mock simulator
    
    NBULogInfo(@"Captured mock image: %@ of size: %@",
               _mockImage, NSStringFromCGSize(_mockImage.size));
    
    // Execute capture block
    if (_captureResultBlock) _captureResultBlock(_mockImage, nil);
    
    // Update last picture view
    if (_lastPictureImageView)
    {
        _lastPictureImageView.image = [_mockImage thumbnailWithSize:_lastPictureImageView.size];
    }
    
    // No need to save image?
    if (!_savePicturesToLibrary)
        return;
    
    // Save to the Camera Roll
    [[NBUAssetsLibrary sharedLibrary] saveImageToCameraRoll:_mockImage
                                                   metadata:nil
                                   addToAssetsGroupWithName:_targetLibraryAlbumName
                                                resultBlock:^(NSURL *assetURL,
                                                              NSError * saveError)
     {
         // Execute result block
         if (_saveResultBlock) _saveResultBlock(_mockImage, nil, assetURL, saveError);
     }];
#endif
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

- (NSInteger)currentFlashMode
{
    return _currentDevice.flashMode;
}

- (void)setCurrentFlashMode:(NSInteger)currentFlashMode
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

- (NSInteger)currentFocusMode
{
    return _currentDevice.focusMode;
}

- (void)setCurrentFocusMode:(NSInteger)currentFocusMode
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

- (NSInteger)currentExposureMode
{
    return _currentDevice.exposureMode;
}

- (void)setCurrentExposureMode:(NSInteger)currentExposureMode
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

- (NSInteger)currentWhiteBalanceMode
{
    return _currentDevice.whiteBalanceMode;
}

- (void)setCurrentWhiteBalanceMode:(NSInteger)currentWhiteBalanceMode
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

