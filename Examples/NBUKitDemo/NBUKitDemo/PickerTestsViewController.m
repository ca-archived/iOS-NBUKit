//
//  PickerTestsViewController.m
//  NBUKitDemo
//
//  Created by 利辺羅 on 2012/11/13.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import "PickerTestsViewController.h"

@implementation PickerTestsViewController
{
    NBUImagePickerOptions _options;
}
@synthesize imageView = _imageView;

- (IBAction)startPicker:(id)sender
{
    // *** If we were using fixed options we could retain the picker ***
    [NBUImagePickerController startPickerWithTarget:self
                                            options:(_options |
                                                     NBUImagePickerOptionSaveTakenOrEditedImages |
                                                     NBUImagePickerOptionReturnMediaInfo)
                                            nibName:nil
                                        resultBlock:^(NSArray * mediaInfo)
    {
        NBULogInfo(@"Picker finished with media info: %@", mediaInfo);
        
        if (mediaInfo.count > 0)
        {
            UIImage * image = mediaInfo[0][NBUImagePickerEditedImageKey];
            if (!image)
            {
                image = mediaInfo[0][NBUImagePickerOriginalImageKey];
            }
            
            _imageView.image = image;
        }
    }];
}

#pragma mark - Handle UI -> options

- (IBAction)segmentControlChanged:(UISegmentedControl *)sender
{
    // Clear bits
    _options = (_options | NBUImagePickerOptionStartWithLibrary) ^ NBUImagePickerOptionStartWithLibrary;
    
    switch (sender.selectedSegmentIndex)
    {
        case 0:
            _options = _options | NBUImagePickerOptionStartWithPrompt;
            break;
        case 1:
            _options = _options | NBUImagePickerOptionStartWithCamera;
            break;
        case 2:
            _options = _options | NBUImagePickerOptionStartWithLibrary;
            break;
    };
    NBULogVerbose(@"Options: %x", _options);
}

- (IBAction)toggleCamera:(UIButton *)sender
{
    sender.selected = !sender.selected;
    _options |= NBUImagePickerOptionDisableCamera;
    if (!sender.selected)
        _options ^= NBUImagePickerOptionDisableCamera;
    NBULogVerbose(@"Options: %x", _options);
}

- (IBAction)toggleLibrary:(UIButton *)sender
{
    sender.selected = !sender.selected;
    _options |= NBUImagePickerOptionDisableLibrary;
    if (!sender.selected)
        _options ^= NBUImagePickerOptionDisableLibrary;
    NBULogVerbose(@"Options: %x", _options);
}

- (IBAction)toggleCrop:(UIButton *)sender
{
    sender.selected = !sender.selected;
    _options |= NBUImagePickerOptionDisableCrop;
    if (!sender.selected)
        _options ^= NBUImagePickerOptionDisableCrop;
    NBULogVerbose(@"Options: %x", _options);
}

- (IBAction)toggleFilters:(UIButton *)sender
{
    sender.selected = !sender.selected;
    _options |= NBUImagePickerOptionDisableFilters;
    if (!sender.selected)
        _options ^= NBUImagePickerOptionDisableFilters;
    NBULogVerbose(@"Options: %x", _options);
}

- (IBAction)toggleConfirmation:(UIButton *)sender
{
    sender.selected = !sender.selected;
    _options |= NBUImagePickerOptionDisableConfirmation;
    if (!sender.selected)
        _options ^= NBUImagePickerOptionDisableConfirmation;
    NBULogVerbose(@"Options: %x", _options);
}

@end

