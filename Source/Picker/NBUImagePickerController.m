//
//  NBUImagePickerController.m
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

#import "NBUImagePickerController.h"
#import "NBUKitPrivate.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_CAMERA_ASSETS

@implementation NBUImagePickerController
{
    BOOL _returnMediaInfoMode;
    NSMutableArray * _mediaInfos;
    NSMutableDictionary * _previousSelectedAssetPaths;
}

@synthesize options = _options;
@synthesize singleImageMode = _singleImageMode;
@synthesize resultBlock = _resultBlock;
@synthesize targetLibraryAlbumName = _targetLibraryAlbumName;
@synthesize cameraController = _cameraController;
@synthesize libraryController = _libraryController;
@synthesize assetsGroupController = _assetsGroupController;
@synthesize editController = _editController;
@synthesize confirmController = _confirmController;

+ (NBUImagePickerController *)pickerWithOptions:(NBUImagePickerOptions)options
                                        nibName:(NSString *)nibName
                                    resultBlock:(NBUImagePickerResultBlock)resultBlock
{
    NBUImagePickerController * controller = [NSBundle loadNibNamed:nibName ? nibName : @"NBUImagePickerController"
                                                             owner:nil
                                                           options:nil][0];
    controller.resultBlock = resultBlock;
    controller.options = options;
    controller.modalPresentationStyle = UIModalPresentationFormSheet;
    return controller;
}

+ (void)startPickerWithTarget:(id)target
                      options:(NBUImagePickerOptions)options
                      nibName:(NSString *)nibName
                  resultBlock:(NBUImagePickerResultBlock)resultBlock
{
    NBUImagePickerController * controller = [self pickerWithOptions:options
                                                            nibName:nibName
                                                        resultBlock:resultBlock];
    [controller startPickerWithTarget:target];
}

- (void)startPickerWithTarget:(id)target
{
    // No need to prompt?
    if (_options & NBUImagePickerOptionDisableCamera ||
        _options & NBUImagePickerOptionDisableLibrary ||
        _options & NBUImagePickerOptionDoNotStartWithPrompt)
    {
        [self _startPickerWithTarget:target];
        return;
    }
    
    // Otherwise use a prompt
    NSString * cancel = NSLocalizedStringWithDefaultValue(@"NBUImagePickerController Cancel prompt actionSheet",
                                                          nil, nil,
                                                          @"Cancel",
                                                          @"NBUImagePickerController Cancel prompt actionSheet");
    NSString * takePicture = NSLocalizedStringWithDefaultValue(@"NBUImagePickerController Take picture actionSheet",
                                                               nil, nil,
                                                               @"Take a picture",
                                                               @"NBUImagePickerController Take picture actionSheet");
    NSString * chooseImage = NSLocalizedStringWithDefaultValue(@"NBUImagePickerController Choose image actionSheet",
                                                               nil, nil,
                                                               @"Choose an image",
                                                               @"NBUImagePickerController Choose image actionSheet");
    NBUActionSheet * actionSheet = [[NBUActionSheet alloc] initWithTitle:nil
                                                                delegate:nil
                                                       cancelButtonTitle:cancel
                                                  destructiveButtonTitle:nil
                                                       otherButtonTitles:takePicture, chooseImage, nil];
    
    // Configure selection blocks
    actionSheet.selectedButtonBlock = ^(NSInteger buttonIndex)
    {
        self.rootViewController = buttonIndex == 0 ? _cameraController : _libraryController;
        [self _startPickerWithTarget:target];
    };
    actionSheet.cancelButtonBlock = ^
    {
        if (_resultBlock) _resultBlock(nil);
    };
    
    [actionSheet showFrom:target];
}

- (void)_startPickerWithTarget:(id)target
{
    // Resolve a target controller
    UIViewController * targetController = target;
    if ([target isKindOfClass:[UIView class]])
    {
        targetController = ((UIView *)target).viewController;
    }
    
    // iOS5+
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
    {
        [targetController presentViewController:self
                                       animated:YES
                                     completion:nil];
    }
    // iOS4
    else
    {
        [targetController presentModalViewController:self
                                            animated:YES ];
    }
}

- (BOOL)shouldAutorotate
{
    return [self.topViewController shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return [self.topViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [self.topViewController preferredInterfaceOrientationForPresentation];
}

#pragma mark - Images and Media Info

- (NSMutableArray *)currentMediaInfos
{
    return _mediaInfos;
}

#pragma mark - Customization

- (void)setResultBlock:(NBUImagePickerResultBlock)resultBlock
{
    _resultBlock = resultBlock;
}

- (void)setOptions:(NBUImagePickerOptions)options
{
    NBULogInfo(@"Picker options: %x", options);
    _options = options;
    
    // NBUImagePickerResultBlock mode
    _returnMediaInfoMode = (_options & NBUImagePickerOptionReturnMediaInfo) == NBUImagePickerOptionReturnMediaInfo;
    _singleImageMode = (options & NBUImagePickerOptionMultipleImages) != NBUImagePickerOptionMultipleImages;
    _mediaInfos = [NSMutableArray array];
    _previousSelectedAssetPaths = [NSMutableDictionary dictionary];
    
    // Configure camera controller
    [self configureCameraController:options];
    
    // Configure library controller
    [self configureLibraryController:options];
    
    // Configure edit controller
    [self configureEditController:options];
    
    // Configure confirmation controller
    [self configureConfirmController:options];
    
    // Configure other controllers
    [self finishConfiguringControllers:options];
    
    // Configure the root controller
    [self configureRootController:options];
}

- (IBAction)goToNextStep:(id)sender
{
    [self prepareToGoToNextStep];
    
    // *** Override to customize the flow ***
    
    // Edit?
    if (_editController &&
        (self.topViewController == _cameraController ||
         self.topViewController == _assetsGroupController))
    {
        [self editImages];
        return;
    }
    
    // Confirm?
    if (_confirmController &&
        self.topViewController != _confirmController)
    {
        [self confirmImages];
        return;
    }
    
    // Else just finish the picker
    [self finishPicker:self];
}

- (void)prepareToGoToNextStep
{
    // *** Override if you need to take some actions before going to the next step ***
    
    // First refresh media infos if nedeed
    if (self.topViewController == _editController)
    {
        _mediaInfos = _editController.editedMediaInfos;
    }
}

- (void)finishConfiguringControllers:(NBUImagePickerOptions)options
{
    // *** Override in subclasses if needed ***
}

- (void)configureRootController:(NBUImagePickerOptions)options
{
    // Skip if already set
    if (self.rootViewController)
        return;
    
    // Set it using the options
    if ((_cameraController &&
         !(options & (NBUImagePickerOptionStartWithLibrary ^ NBUImagePickerOptionDoNotStartWithPrompt))) ||
        !_libraryController)
    {
        self.rootViewController = _cameraController;
    }
    else
    {
        self.rootViewController = _libraryController;
    }
}

#pragma mark - Camera controller

- (void)configureCameraController:(NBUImagePickerOptions)options
{
    // No camera?
    if (options & NBUImagePickerOptionDisableCamera)
    {
        NBULogVerbose(@"Options: Camera disabled");
        
        _cameraController = nil;
        _libraryController.navigationItem.rightBarButtonItem = nil;
        _assetsGroupController.navigationItem.rightBarButtonItem = nil;
        return;
    }
    
    // Configure controller
    _cameraController.navigationItem.title = NSLocalizedStringWithDefaultValue(@"NBUImagePickerController CameraTitle",
                                                                               nil, nil,
                                                                               @"Camera",
                                                                               @"NBUImagePickerController CameraTitle");
    _cameraController.supportedInterfaceOrientations = UIInterfaceOrientationMaskPortrait;
    _cameraController.singlePictureMode = _singleImageMode;
    
    __unsafe_unretained NBUImagePickerController * weakSelf = self;
    BOOL singleImageMode = _singleImageMode;
    _cameraController.captureResultBlock = ^(UIImage * image,
                                             NSError * error)
    {
        if (!error && image)
        {
            NBUMediaInfo * mediaInfo = [NBUMediaInfo mediaInfoWithOriginalImage:image];
            
            if (singleImageMode)
            {
                weakSelf.currentMediaInfos[0] = mediaInfo;
            }
            else
            {
                [weakSelf.currentMediaInfos insertObject:mediaInfo
                                                 atIndex:0];
            }
            
            [weakSelf goToNextStep:weakSelf];
        }
    };
}

#pragma mark - Library controller

- (void)configureLibraryController:(NBUImagePickerOptions)options
{
    if ((options & NBUImagePickerOptionDisableLibrary) &&
        _cameraController)
    {
        NBULogVerbose(@"Options: Library disabled");
        
        _libraryController = nil;
        _assetsGroupController = nil;
        _cameraController.navigationItem.rightBarButtonItem = nil;
        return;
    }
    
    // Customize
    _libraryController.navigationItem.title = NSLocalizedStringWithDefaultValue(@"NBUImagePickerController LibraryLoadingTitle",
                                                                                nil, nil,
                                                                                @"Loading...",
                                                                                @"NBUImagePickerController LibraryLoadingTitle");
    _libraryController.customBackButtonTitle = NSLocalizedStringWithDefaultValue(@"NBUImagePickerController libraryController.customBackButtonTitle",
                                                                                 nil, nil,
                                                                                 @"Albums",
                                                                                 @"NBUImagePickerController libraryController.customBackButtonTitle");
    _libraryController.assetsGroupController = _assetsGroupController;
    
    [self configureAssetsGroupController:options];
}

- (void)configureAssetsGroupController:(NBUImagePickerOptions)options
{
    // Customize assets group controller
    _assetsGroupController.reverseOrder = YES;
    _assetsGroupController.navigationItem.leftBarButtonItem = nil; // Allow back button
    _assetsGroupController.customBackButtonTitle = NSLocalizedStringWithDefaultValue(@"NBUImagePickerController assetsGroupController.customBackButtonTitle",
                                                                                     nil, nil,
                                                                                     @"Library",
                                                                                     @"NBUImagePickerController assetsGroupController.customBackButtonTitle");
    
    // Single image mode
    if (_singleImageMode)
    {
        _assetsGroupController.selectionCountLimit = 1;
        _assetsGroupController.clearsSelectionOnViewWillAppear = YES;
        
        __unsafe_unretained NBUImagePickerController * weakSelf = self;
        _assetsGroupController.selectionChangedBlock = ^()
        {
            NSArray * selectedAssets = weakSelf.assetsGroupController.selectedAssets;
            if (selectedAssets.count > 0)
            {
                [weakSelf finishAssetsSelection];
            }
        };
    }
    
    // Multiple images mode
    else
    {
        // Replace the camera button by a continue button if not customized
        if (_assetsGroupController.navigationItem.rightBarButtonItem.style == UIBarButtonSystemItemCamera)
        {
            UIBarButtonItem * continueButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"NBUImagePickerController assetsGroupController.continueButton",
                                                                                                                        nil, nil,
                                                                                                                        @"Continue",
                                                                                                                        @"NBUImagePickerController assetsGroupController.continueButton")
                                                                                style:UIBarButtonItemStyleDone
                                                                               target:self
                                                                               action:@selector(finishAssetsSelection)];
            _assetsGroupController.continueButton = continueButton;
            _assetsGroupController.navigationItem.rightBarButtonItem = continueButton;
        }
    }
}

- (void)finishAssetsSelection
{
    NSArray * selectedAssets = _assetsGroupController.selectedAssets;
    
    // Remove no longer selected assets
    NBUAsset * asset;
    NSString * path;
    NBUMediaInfo * mediaInfo;
    BOOL stillSelected;
    for (NSString * previouslySelectedAssetPath in _previousSelectedAssetPaths.allKeys)
    {
        stillSelected = NO;
        for (asset in selectedAssets)
        {
            path = asset.URL.absoluteString;
            if ([previouslySelectedAssetPath isEqualToString:path])
            {
                stillSelected = YES;
                break;
            }
        }
        
        if (!stillSelected)
        {
            mediaInfo = _previousSelectedAssetPaths[previouslySelectedAssetPath];
            [_mediaInfos removeObject:mediaInfo];
            [_previousSelectedAssetPaths removeObjectForKey:previouslySelectedAssetPath];
        }
    }
    
    // Add newly selected assets
    for (asset in selectedAssets)
    {
        path = asset.URL.absoluteString;
        if (!_previousSelectedAssetPaths[path])
        {
            mediaInfo = [NBUMediaInfo mediaInfoWithAttributes:
                         @{
                          NBUMediaInfoOriginalAssetKey       : asset,
                          NBUMediaInfoOriginalMediaURLKey    : asset.URL
                         }];
            
            if (_singleImageMode)
            {
                _mediaInfos[0] = mediaInfo;
            }
            else
            {
                [_mediaInfos addObject:mediaInfo];
                _previousSelectedAssetPaths[path] = mediaInfo;
            }
        }
    }

    [self goToNextStep:self];
}

#pragma mark - Edit controller

- (void)configureEditController:(NBUImagePickerOptions)options
{
    if ((options & NBUImagePickerOptionDisableCrop) &&
        (options & NBUImagePickerOptionDisableFilters))
    {
        NBULogVerbose(@"Options: Edit disabled");
        
        _editController = nil;
        return;
    }

    // Enable back button
    _editController.navigationItem.leftBarButtonItem = nil;
    
    // Set up crop and working sizes
    CGFloat scale = [UIScreen mainScreen].scale;
    _editController.workingSize = CGSizeMake(450.0 * scale,
                                             450.0 * scale);
    
    // UI customization
    _editController.navigationItem.rightBarButtonItem.title = NSLocalizedStringWithDefaultValue(@"NBUImagePickerController editController rightBarButtonItem.title",
                                                                                                nil, nil,
                                                                                                @"Next",
                                                                                                @"NBUImagePickerController editController rightBarButtonItem.title");
    if (_singleImageMode)
    {
        _editController.navigationItem.titleView = nil;
        _editController.updatesTitle = NO;
        _editController.navigationItem.title = NSLocalizedStringWithDefaultValue(@"NBUImagePickerController editController title",
                                                                                 nil, nil,
                                                                                 @"Edit",
                                                                                 @"NBUImagePickerController editController title");
    }
}

- (void)editImages
{
    NBULogInfo(@"%@: %@", THIS_METHOD, _mediaInfos);
    
    // Configure the edit controller
    _editController.mediaInfos = _mediaInfos;
    
    // Prepare its view if needed
    if (!_editController.isViewLoaded &&
        !_editController.nibName)
    {
        // No filters?
        if (_options & NBUImagePickerOptionDisableFilters)
        {
            [NSBundle loadNibNamed:@"NBUCropViewController"
                             owner:_editController
                           options:nil];
        }
        
        // No crop?
        else if (_options & NBUImagePickerOptionDisableCrop)
        {
            [NSBundle loadNibNamed:@"NBUPresetFilterViewController"
                             owner:_editController
                           options:nil];
        }
        
        // Use both
        else
        {
            [NSBundle loadNibNamed:@"NBUEditImageViewController"
                             owner:_editController
                           options:nil];
        }
        
        // Manually call viewDidLoad
        [_editController viewDidLoad];
    }
    
    [self pushViewController:_editController
                    animated:YES];
}

#pragma mark - Confirm controller

- (void)configureConfirmController:(NBUImagePickerOptions)options
{
    if (options & NBUImagePickerOptionDisableConfirmation)
    {
        NBULogVerbose(@"Options: Confirmation disabled");
        
        _confirmController = nil;
        return;
    }
    
    // Configure controller
    _confirmController.navigationItem.title = NSLocalizedStringWithDefaultValue(@"NBUImagePickerController confirmController title",
                                                                                nil, nil,
                                                                                @"Confirm",
                                                                                @"NBUImagePickerController confirmController title");
    _confirmController.updatesTitle = NO;
}

- (void)confirmImages
{
    _confirmController.objectArray = _mediaInfos;
    
    [self pushViewController:_confirmController
                    animated:YES];
}

#pragma mark - Actions

- (IBAction)toggleSource:(id)sender
{
    if (self.topViewController == _cameraController)
    {
        self.topViewController = _libraryController;
    }
    else
    {
        self.topViewController = _cameraController;
    }
    
    [self refreshOrientation];
}

- (IBAction)finishPicker:(id)sender
{
    // Save images?
    BOOL saveTaken = (_options & NBUImagePickerOptionSaveTakenImages) == NBUImagePickerOptionSaveTakenImages;
    BOOL saveEdited = (_options & NBUImagePickerOptionSaveEditedImages) == NBUImagePickerOptionSaveEditedImages;
    if (saveTaken || saveEdited)
    {
        BOOL sourceIsCamera;
        BOOL imageIsEdited;
        for (NSUInteger index = 0; index < _mediaInfos.count; index++)
        {
            sourceIsCamera = ((NBUMediaInfo *)_mediaInfos[index]).source == NBUMediaInfoSourceCamera;
            imageIsEdited = ((NBUMediaInfo *)_mediaInfos[index]).edited;
            if ((saveTaken && sourceIsCamera) ||
                (saveEdited && imageIsEdited))
            {
                [[NBUAssetsLibrary sharedLibrary] saveImageToCameraRoll:((NBUMediaInfo *)_mediaInfos[index]).editedImage
                                                               metadata:nil
                                               addToAssetsGroupWithName:_targetLibraryAlbumName
                                                            resultBlock:^(NSURL * assetURL,
                                                                          NSError * error)
                 {
                     if (!error && assetURL)
                     {
                         ((NBUMediaInfo *)_mediaInfos[index]).attributes[NBUMediaInfoEditedMediaURLKey] = assetURL;
                     }
                 }];
            }
        }
    }
    
    // Prepare result
    NSMutableArray * result = _mediaInfos;
    if (!_returnMediaInfoMode)
    {
        result = [NSMutableArray arrayWithCapacity:_mediaInfos.count];
        for (NSUInteger index = 0; index < _mediaInfos.count; index++)
        {
            [result addObject:((NBUMediaInfo *)_mediaInfos[index++]).editedImage];
        }
    }
    
    // Call result block
    if (_resultBlock) _resultBlock(result);
    
    // Dismiss
    [self dismiss:self];
}

- (IBAction)dismiss:(id)sender
{
    NBULogTrace();
    
    // Was cancelled by the user?
    if (sender != self)
    {
        NBULogInfo(@"Picker cancelled by user");
        
        if (_resultBlock) _resultBlock(nil);
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
    {
        [self dismissViewControllerAnimated:YES
                                 completion:NULL];
    }
    else
    {
        [self dismissModalViewControllerAnimated:YES];
    }
}

@end

