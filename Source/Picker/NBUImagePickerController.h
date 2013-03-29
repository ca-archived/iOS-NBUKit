//
//  NBUImagePickerController.h
//  NBUKit
//
//  Created by 利辺羅 on 2012/11/12.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

@class NBUImagePickerConfirmController;

/// Picker result block.
typedef void (^NBUImagePickerResultBlock)(NSArray * imagesOrMediaInfo);

/// Media Info keys.
extern NSString * const NBUImagePickerOriginalImageKey;
extern NSString * const NBUImagePickerOriginalImageURLKey;
extern NSString * const NBUImagePickerEditedImageKey;
extern NSString * const NBUImagePickerEditedImageURLKey;

/// Picker configuration options.
enum
{
    // Single or multiple images
    NBUImagePickerOptionSingleImage             = 0 << 0,
    NBUImagePickerOptionMultipleImages          = 1 << 0,   // TODO: Multiple images
    
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
@property (readonly, nonatomic)         NBUImagePickerOptions options;

/// The result block to be called upon picker completion.
@property (strong, nonatomic, readonly) NBUImagePickerResultBlock resultBlock;

/// The library album to be used to save resulting images.
/// @discussion To enable saving adding a save images option has to be set in options.
@property (strong, nonatomic)           NSString * targetLibraryAlbumName;

/// @name Methods to Override As Needed

/// Override to further configure the picker's NBUCameraViewController instance.
/// @param options The picker configuration options.
- (void)configureCameraController:(NBUImagePickerOptions)options;

/// Override to further configure the picker's NBUAssetsLibraryViewController instance.
/// @param options The picker configuration options.
- (void)configureLibraryController:(NBUImagePickerOptions)options;

/// Override to further configure the picker's NBUEditImageViewController instance.
/// @param options The picker configuration options.
- (void)configureEditController:(NBUImagePickerOptions)options;

/// Override to further configure the picker's NBUImagePickerConfirmController instance.
/// @param options The picker configuration options.
- (void)configureConfirmController:(NBUImagePickerOptions)options;

/// Override to configure custom controllers.
/// @param options The picker configuration options.
- (void)finishConfiguringControllers:(NBUImagePickerOptions)options;

/// Override to manually set the controller that should be shown first.
/// @param options The picker configuration options.
- (void)configureRootController:(NBUImagePickerOptions)options;

/// @name Handling the Current Media Info

/// The current array of media info.
- (NSArray *)currentMediaInfo;

/// Add a new media info entry.
/// @param mediaInfo The media info dictionary to be added.
/// @param index The target media info position.
- (void)addMediaInfo:(NSDictionary *)mediaInfo
             atIndex:(NSUInteger)index;

/// Set the original image for a given media info.
/// @param image The UIImage to be set as the original image.
/// @param index The target media info position.
- (void)setOriginalImage:(UIImage *)image
                 atIndex:(NSUInteger)index;

/// Get the original image for a given media info.
/// @param index The target media info position.
- (UIImage *)originalImageAtIndex:(NSUInteger)index;

/// Set the edited image for a given media info.
/// @discussion If the image was not edited it returns the original image instead.
/// @param image The UIImage to be set as the edited image.
/// @param index The target media info position.
- (void)setEditedImage:(UIImage *)image
               atIndex:(NSUInteger)index;

/// Set the edited image for a given media info.
/// @param index The target media info position.
- (UIImage *)editedImageAtIndex:(NSUInteger)index;

/// @name Outlets

/// The camera view controller.
@property (strong, nonatomic) IBOutlet  NBUCameraViewController * cameraController;

/// The assets library controller.
@property (strong, nonatomic) IBOutlet  NBUAssetsLibraryViewController * libraryController;

/// The assets group controller.
@property (strong, nonatomic) IBOutlet  NBUAssetsGroupViewController * assetsGroupController;

/// The edit (cropping and filters) controller.
@property (strong, nonatomic) IBOutlet  NBUEditImageViewController * editController;

/// The picker confirmation controller.
@property (strong, nonatomic) IBOutlet  NBUImagePickerConfirmController * confirmController;

/// @name Actions

/// Toggle between camera and library sources.
/// @param sender The sender object.
- (IBAction)toggleSource:(id)sender;

/// Finish the picker.
/// @param sender The sender object.
- (IBAction)finishPicker:(id)sender;

@end


/**
 Simple controller to preview picked images.
 */
@interface NBUImagePickerConfirmController : UIViewController

/// @name Outlets

/// The preview UIImageView.
@property (assign, nonatomic) IBOutlet UIImageView * imageView;

@end

