//
//  NBUCameraViewController.m
//  NBUKit
//
//  Created by 利辺羅 on 2012/11/12.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import "NBUCameraViewController.h"
#import "RBVolumeButtons.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_CAMERA_ASSETS

@implementation NBUCameraViewController
{
    RBVolumeButtons * _buttonStealer;
}

@synthesize cameraView = _cameraView;
@synthesize targetResolution = _targetResolution;
@synthesize captureResultBlock = _captureResultBlock;
@synthesize savePicturesToLibrary = _savePicturesToLibrary;
@synthesize targetLibraryAlbumName = _targetLibraryAlbumName;
@synthesize singlePictureMode = _singlePictureMode;
@synthesize takesPicturesWithVolumeButtons = _takesPicturesWithVolumeButtons;

+ (BOOL)isCameraAvailable
{
#ifdef __i386__
    // Simulator has a mock camera
    return YES;
#endif
    
    // Check with UIImagePickerController
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (void)commonInit
{
    [super commonInit];
    
    self.takesPicturesWithVolumeButtons = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configure the camera view
    self.targetResolution = _targetResolution;
    self.captureResultBlock = _captureResultBlock;
    self.savePicturesToLibrary = _savePicturesToLibrary;
    self.targetLibraryAlbumName = _targetLibraryAlbumName;
    if (_singlePictureMode)
    {
        [_cameraView.lastPictureImageView removeFromSuperview];
        _cameraView.lastPictureImageView = nil;
    }
}

- (void)viewDidUnload
{
    _cameraView = nil;
    
    [super viewDidUnload];
}

- (void)setTakesPicturesWithVolumeButtons:(BOOL)takesPicturesWithVolumeButtons
{
    if (SYSTEM_VERSION_LESS_THAN(@"5.0"))
        return;
    
    _takesPicturesWithVolumeButtons = takesPicturesWithVolumeButtons;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Start stealing buttons
    if (_takesPicturesWithVolumeButtons)
    {
        if (!_buttonStealer)
        {
            __unsafe_unretained NBUCameraViewController * weakSelf = self;
            ButtonBlock block = ^
            {
                [weakSelf.cameraView takePicture:weakSelf];
            };
            _buttonStealer = [RBVolumeButtons new];
            _buttonStealer.upBlock = block;
            _buttonStealer.downBlock = block;
        }
        
        [_buttonStealer startStealingVolumeButtonEvents];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Stop stealing buttons
    if (_takesPicturesWithVolumeButtons)
    {
        [_buttonStealer stopStealingVolumeButtonEvents];
    }
}

- (void)setTargetResolution:(CGSize)targetResolution
{
    _targetResolution = targetResolution;
    
    if (_cameraView)
    {
        _cameraView.targetResolution = targetResolution;
    }
}

- (void)setCaptureResultBlock:(NBUCapturePictureResultBlock)captureResultBlock
{
    _captureResultBlock = captureResultBlock;
    
    if (_cameraView)
    {
        _cameraView.captureResultBlock = captureResultBlock;
    }
}

- (void)setSavePicturesToLibrary:(BOOL)savePicturesToLibrary
{
    _savePicturesToLibrary = savePicturesToLibrary;
    
    if (_cameraView)
    {
        _cameraView.savePicturesToLibrary = savePicturesToLibrary;
    }
}

- (void)setTargetLibraryAlbumName:(NSString *)targetLibraryAlbumName
{
    _targetLibraryAlbumName = targetLibraryAlbumName;
    
    if (_cameraView)
    {
        _cameraView.targetLibraryAlbumName = targetLibraryAlbumName;
    }
}

@end

