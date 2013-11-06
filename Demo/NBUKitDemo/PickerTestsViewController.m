//
//  PickerTestsViewController.m
//  NBUKitDemo
//
//  Created by Ernesto Rivera on 2012/11/13.
//  Copyright (c) 2012-2013 CyberAgent Inc.
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

#import "PickerTestsViewController.h"

@implementation PickerTestsViewController
{
    NBUImagePickerOptions _options;
}
@synthesize slideView = _slideView;

- (IBAction)startPicker:(id)sender
{
    // *** If we were using fixed options we could retain the picker ***
    [NBUImagePickerController startPickerWithTarget:self
                                            options:(_options | NBUImagePickerOptionReturnMediaInfo)
                                            nibName:nil
                                        resultBlock:^(NSArray * mediaInfos)
    {
        NBULogInfo(@"Picker finished with media info: %@", mediaInfos);
        
        if (mediaInfos.count > 0)
        {
            _slideView.objectArray = mediaInfos;
        }
    }];
}

#pragma mark - Handle UI -> options

- (IBAction)toggleMultiImageMode:(UISwitch *)sender
{
    _options |= NBUImagePickerOptionMultipleImages;
    if (!sender.on)
        _options ^= NBUImagePickerOptionMultipleImages;
    NBULogVerbose(@"Options: %x", _options);
}

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

- (IBAction)toggleSaveTakenImages:(UISwitch *)sender
{
    _options |= NBUImagePickerOptionSaveTakenImages;
    if (!sender.on)
        _options ^= NBUImagePickerOptionSaveTakenImages;
    NBULogVerbose(@"Options: %x", _options);
}

- (IBAction)toggleSaveEditedImages:(UISwitch *)sender
{
    _options |= NBUImagePickerOptionSaveEditedImages;
    if (!sender.on)
        _options ^= NBUImagePickerOptionSaveEditedImages;
    NBULogVerbose(@"Options: %x", _options);
}

@end

