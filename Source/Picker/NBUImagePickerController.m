//
//  NBUImagePickerController.m
//  NBUKit
//
//  Created by 利辺羅 on 2012/11/12.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import "NBUImagePickerController.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_CAMERA_ASSETS

NSString * const NBUImagePickerOriginalImageKey     = @"NBUImagePickerOriginalImageKey";
NSString * const NBUImagePickerOriginalImageURLKey  = @"NBUImagePickerOriginalImageURLKey";
NSString * const NBUImagePickerEditedImageKey       = @"NBUImagePickerEditedImageKey";
NSString * const NBUImagePickerEditedImageURLKey    = @"NBUImagePickerEditedImageURLKey";

@implementation NBUImagePickerController
{
    BOOL _mediaInfoMode;
    NSMutableArray * _mediaInfo;
}

@synthesize options = _options;
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
    NBUImagePickerController * controller = [[NSBundle loadNibNamed:nibName ? nibName : @"NBUImagePickerController"
                                                              owner:nil
                                                            options:nil] objectAtIndex:0];
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
    NBUActionSheet * actionSheet = [[NBUActionSheet alloc] initWithTitle:nil
                                                                delegate:nil
                                                       cancelButtonTitle:NSLocalizedString(@"Cancel",
                                                                                           @"Picker actionSheet")
                                                  destructiveButtonTitle:nil
                                                       otherButtonTitles:NSLocalizedString(@"Take a picture",
                                                                                           @"Picker actionSheet"),
                                    NSLocalizedString(@"Choose a picture",
                                                      @"Picker actionSheet"), nil];
    actionSheet.selectedButtonBlock = ^(NSInteger buttonIndex)
    {
        self.rootViewController = buttonIndex == 0 ? _cameraController : _libraryController;
        [self _startPickerWithTarget:target];
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

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Localization
    _cameraController.navigationItem.title = NSLocalizedString(@"Camera",
                                                               @"Picker CameraTitle");
    _libraryController.navigationItem.title = NSLocalizedString(@"Loading...",
                                                                @"Picker LibraryLoadingTitle");
    _editController.navigationItem.title = NSLocalizedString(@"Edit",
                                                             @"Picker EditTitle");
    _editController.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Apply",
                                                                                @"Picker EditApplyButton");
    _confirmController.navigationItem.title = NSLocalizedString(@"Confirm",
                                                                @"Picker ConfirmTitle");
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

- (NSArray *)currentMediaInfo
{
    return _mediaInfo;
}

- (void)addMediaInfo:(NSDictionary *)mediaInfo
             atIndex:(NSUInteger)index
{
    if (index >= _mediaInfo.count)
    {
        _mediaInfo[index] = [NSMutableDictionary dictionaryWithDictionary:mediaInfo];
    }
    else
    {
        [(NSMutableDictionary *)_mediaInfo[index] addEntriesFromDictionary:mediaInfo];
    }
}

- (UIImage *)originalImageAtIndex:(NSUInteger)index
{
    return _mediaInfo[index][NBUImagePickerOriginalImageKey];
}

- (void)setOriginalImage:(UIImage *)image
                 atIndex:(NSUInteger)index
{
    [self addMediaInfo:@{ NBUImagePickerOriginalImageKey : image }
               atIndex:index];
}

- (UIImage *)editedImageAtIndex:(NSUInteger)index
{
    UIImage * editedImage = _mediaInfo[index][NBUImagePickerEditedImageKey];
    
    return editedImage ? editedImage : [self originalImageAtIndex:index];
}

- (void)setEditedImage:(UIImage *)image
               atIndex:(NSUInteger)index
{
    [self addMediaInfo:@{ NBUImagePickerEditedImageKey : image }
               atIndex:index];
}

- (BOOL)imageAtIndexIsTakenFromCamera:(NSUInteger)index
{
    return !_mediaInfo[index][NBUImagePickerOriginalImageURLKey];
}

- (BOOL)imageAtIndexIsEdited:(NSUInteger)index
{
    return _mediaInfo[index][NBUImagePickerEditedImageKey] != nil;
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
    _mediaInfoMode = (_options & NBUImagePickerOptionReturnMediaInfo) == NBUImagePickerOptionReturnMediaInfo;
    _mediaInfo = [NSMutableArray array];
    
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
    }
    // Customize camera controller
    else
    {
        _cameraController.supportedInterfaceOrientations = UIInterfaceOrientationMaskPortrait;
        _cameraController.singlePictureMode = !(options & NBUImagePickerOptionMultipleImages);
        
        __unsafe_unretained NBUImagePickerController * weakSelf = self;
        _cameraController.captureResultBlock = ^(UIImage * image,
                                                 NSError * error)
        {
            if (!error)
            {
                [weakSelf setOriginalImage:image
                                   atIndex:0];
                
                [weakSelf editImageAtIndex:0];
            }
        };
    }
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
    }
    else
    {
        [_libraryController setCustomBackButtonTitle:NSLocalizedString(@"Albums", @"BackButtonTitle")];
        
        __unsafe_unretained NBUImagePickerController * weakSelf = self;
        _libraryController.groupControllerBlock = ^UIViewController *(NBUAssetsGroup * assetsGroup)
        {
            weakSelf.assetsGroupController.assetsGroup = assetsGroup;
            return weakSelf.assetsGroupController;
        };
        
        // Customize assets group controller
        _assetsGroupController.navigationItem.leftBarButtonItem = nil; // Allow back button
        _assetsGroupController.singleImageMode = !(options & NBUImagePickerOptionMultipleImages);
        _assetsGroupController.selectionChangedBlock = ^()
        {
            NSArray * selectedAssets = weakSelf.assetsGroupController.selectedAssets;
            if (selectedAssets.count > 0)
            {
                UIImage * image = ((NBUAsset *)selectedAssets[0]).fullResolutionImage;
                
                [weakSelf addMediaInfo:@
                 {
                     NBUImagePickerOriginalImageKey     : image,
                     NBUImagePickerOriginalImageURLKey  : ((NBUAsset *)selectedAssets[0]).URL
                 }
                               atIndex:0];
                
                [weakSelf editImageAtIndex:0];
            }
        };
    }
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
    
    // Set result block
    __unsafe_unretained NBUImagePickerController * weakSelf = self;
    _editController.resultBlock = ^(UIImage * editedImage)
    {
        // Register edited image
        [weakSelf setEditedImage:editedImage
                         atIndex:0];
        
        [weakSelf confirmOrFinishWithImageAtIndex:0];
    };
}

- (void)editImageAtIndex:(NSUInteger)index
{
    // No edit?
    if (!_editController)
    {
        [self confirmOrFinishWithImageAtIndex:index];
    }
    else
    {
        // Configure the edit controller
        _editController.image = [self originalImageAtIndex:index];
        
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
}

#pragma mark - Confirm controller

- (void)configureConfirmController:(NBUImagePickerOptions)options
{
    if (options & NBUImagePickerOptionDisableConfirmation)
    {
        NBULogVerbose(@"Options: Confirmation disabled");
        _confirmController = nil;
    }
}

- (void)confirmOrFinishWithImageAtIndex:(NSUInteger)index
{
    // No confirmation?
    if (!_confirmController)
    {
        [self finishPicker:self];
    }
    else
    {
        _confirmController.imageView.image = [self editedImageAtIndex:index];
        [self pushViewController:_confirmController
                        animated:YES];
    }
}

#pragma mark - Actions

- (IBAction)toggleSource:(id)sender
{
    if (self.rootViewController != _cameraController)
    {
        self.rootViewController = _cameraController;
    }
    else
    {
        self.rootViewController = _libraryController;
    }
    
    // Force orientation refresh
    UIViewController * controller = [UIViewController new];
    [self presentModalViewController:controller animated:NO];
    [self dismissModalViewControllerAnimated:NO];
}

- (IBAction)finishPicker:(id)sender
{
    // Save images?
    BOOL saveTaken = (_options & NBUImagePickerOptionSaveTakenImages) == NBUImagePickerOptionSaveTakenImages;
    BOOL saveEdited = (_options & NBUImagePickerOptionSaveEditedImages) == NBUImagePickerOptionSaveEditedImages;
    if (_options & NBUImagePickerOptionSaveTakenImages || _options & NBUImagePickerOptionSaveEditedImages)
    {
        for (NSUInteger index = 0; index < _mediaInfo.count; index++)
        {
            if ((saveTaken && [self imageAtIndexIsTakenFromCamera:index]) ||
                (saveEdited && [self imageAtIndexIsEdited:index]))
            {
                [[NBUAssetsLibrary sharedLibrary] saveImageToCameraRoll:[self editedImageAtIndex:index]
                                                               metadata:nil // _mediaInfo[index] (seems give problems)
                                               addToAssetsGroupWithName:_targetLibraryAlbumName
                                                            resultBlock:^(NSURL * assetURL,
                                                                          NSError * error)
                 {
                     if (assetURL)
                     {
                         _mediaInfo[index][NBUImagePickerEditedImageURLKey] = assetURL;
                     }
                 }];
            }
        }
    }
    
    // Prepare result
    NSMutableArray * result = _mediaInfo;
    if (!_mediaInfoMode)
    {
        result = [NSMutableArray arrayWithCapacity:_mediaInfo.count];
        for (NSUInteger index = 0; index < _mediaInfo.count; index++)
        {
            [result addObject:[self editedImageAtIndex:index++]];
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


@implementation NBUImagePickerConfirmController

@synthesize imageView = _imageView;

@end

