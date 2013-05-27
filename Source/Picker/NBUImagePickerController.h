//
//  NBUImagePickerController.h
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

@class NBUCameraViewController, NBUAssetsLibraryViewController, NBUAssetsGroupViewController, NBUEditMultiImageViewController, NBUGalleryViewController;

/// Picker result block.
typedef void (^NBUImagePickerResultBlock)(NSArray * imagesOrMediaInfos);

/// Picker configuration options.
enum
{
    // Single or multiple images
    NBUImagePickerOptionSingleImage             = 0 << 0,
    NBUImagePickerOptionMultipleImages          = 1 << 0,
    
    // NBUImagePickerResultBlock mode
    NBUImagePickerOptionReturnImages            = 0 << 2,   // The result will be an array of UIImage objects
    NBUImagePickerOptionReturnMediaInfo         = 1 << 2,   // The result will be an array of Media Info dictionaries

    // Start mode
    NBUImagePickerOptionStartWithPrompt         = 0 << 4,   // Ask user which input to start with
    NBUImagePickerOptionDoNotStartWithPrompt    = 1 << 4,
    NBUImagePickerOptionStartWithCamera         = 1 << 4,
    NBUImagePickerOptionStartWithLibrary        = 3 << 4,
    
    // Disable features
    NBUImagePickerOptionDisableCamera           = 1 << 8,
    NBUImagePickerOptionDisableLibrary          = 1 << 9,
    NBUImagePickerOptionDisableCrop             = 1 << 10,
    NBUImagePickerOptionDisableFilters          = 1 << 11,
    NBUImagePickerOptionDisableEdition          = (NBUImagePickerOptionDisableCrop |
                                                   NBUImagePickerOptionDisableFilters),
    NBUImagePickerOptionDisableConfirmation     = 1 << 12,
    
    // Saving images
    NBUImagePickerOptionDoNotSaveImages         = 0 << 16,
    NBUImagePickerOptionSaveTakenImages         = 1 << 16,
    NBUImagePickerOptionSaveEditedImages        = 1 << 17,
    NBUImagePickerOptionSaveTakenOrEditedImages = (NBUImagePickerOptionSaveTakenImages |
                                                   NBUImagePickerOptionSaveEditedImages),
    
    // Default options
    NBUImagePickerDefaultOptions                = (NBUImagePickerOptionSingleImage |
                                                   NBUImagePickerOptionReturnImages |
                                                   NBUImagePickerOptionStartWithPrompt |
                                                   NBUImagePickerOptionDoNotSaveImages)
};
typedef NSUInteger NBUImagePickerOptions;

/**
 An AVFondation and AssetsLibrary-based image picker.
 
 - Combines NBUCameraViewController, NBUAssetsLibraryViewController and NBUAssetsGroupViewController.
 - Fully customizable.
 - Only one modal controller.
 - Many configuration options.
 - Can return and array of edited images or dictionaries (media info) with both original and edite
 images in addition to other metadata.
 - Completly customize the picker flow by overriding the goToNextStep method.
 
 @note Should be initialized from a Nib file.
 */
@interface NBUImagePickerController : UINavigationController

/// @name Creating and Starting the Picker

/// Create, configure and start an image picker.
/// @param target A controller or view to be used to present the picker.
/// @param options The picker configuration options.
/// @param nibName An optional Nib file to be used to instantiate the picker.
/// The picker should be the first object in the Nib.
/// @param resultBlock The block to be called when the picker finishes. When cancelled images is `nil`.
+ (void)startPickerWithTarget:(id)target
                      options:(NBUImagePickerOptions)options
                      nibName:(NSString *)nibName
                  resultBlock:(NBUImagePickerResultBlock)resultBlock;

/// Create an image picker specifying a custom Nib file.
/// @param options The picker configuration options.
/// @param nibName The name of the Nib file to be loaded.
/// @return A ready to use image picker that can be used multiple times.
/// @param resultBlock The block to be called when the picker finishes. When cancelled images is `nil`.
+ (NBUImagePickerController *)pickerWithOptions:(NBUImagePickerOptions)options
                                        nibName:(NSString *)nibName
                                    resultBlock:(NBUImagePickerResultBlock)resultBlock;

/// Start the image picker.
/// @param target A controller or view to be used to present the picker.
- (void)startPickerWithTarget:(id)target;

/// @name Properties

/// The picker options.
@property (nonatomic, readonly)         NBUImagePickerOptions options;

/// Whether the picker is in single image mode.
@property (nonatomic, readonly)         BOOL singleImageMode;

/// The result block to be called upon picker completion.
@property (nonatomic, copy, readonly)   NBUImagePickerResultBlock resultBlock;

/// The library album to be used to save resulting images.
/// @discussion To enable saving adding a save images option has to be set in options.
@property (strong, nonatomic)           NSString * targetLibraryAlbumName;

/// @name Methods to Override As Needed

/// Override to configure custom controllers.
/// @param options The picker configuration options.
- (void)finishConfiguringControllers:(NBUImagePickerOptions)options;

/// @name Handling the Current Media Infos

/// The current array of NBUMediaInfo objects.
- (NSMutableArray *)currentMediaInfos;

/// @name Outlets

/// The camera view controller.
@property (strong, nonatomic) IBOutlet  NBUCameraViewController * cameraController;

/// The assets library controller.
@property (strong, nonatomic) IBOutlet  NBUAssetsLibraryViewController * libraryController;

/// The assets group controller.
@property (strong, nonatomic) IBOutlet  NBUAssetsGroupViewController * assetsGroupController;

/// The edit (cropping and filters) controller.
@property (strong, nonatomic) IBOutlet  NBUEditMultiImageViewController * editController;

/// The picker confirmation controller.
@property (strong, nonatomic) IBOutlet  NBUGalleryViewController * confirmController;

/// @name Actions

/// Toggle between camera and library sources.
/// @param sender The sender object.
- (IBAction)toggleSource:(id)sender;

/// @name Methods to Override if Needed

/// Action to be called to go to the next step of the picker.
/// @discussion Override to modify the picker flow.
/// @param sender The sender object.
- (IBAction)goToNextStep:(id)sender;

/// Method called by goToNextStep before pushing the next view controller.
/// @discussion Override it to finalize the previous task.
- (void)prepareToGoToNextStep;

/// The edit images step.
/// @discussion By default configures and pushes the editController.
- (void)editImages;

/// The confirm selection step.
/// @discussion By default configures and pushes the confirmController.
- (void)confirmImages;

/// Finish the picker.
/// @param sender The sender object.
- (IBAction)finishPicker:(id)sender;

@end

