//
//  PickerTestsViewController.h
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

#import <UIKit/UIKit.h>

@interface PickerTestsViewController : NBUViewController

// Outlets
@property (weak, nonatomic) IBOutlet ObjectSlideView * slideView;

// Actions
- (IBAction)startPicker:(id)sender;
- (IBAction)toggleMultiImageMode:(id)sender;
- (IBAction)segmentControlChanged:(id)sender;
- (IBAction)toggleCamera:(id)sender;
- (IBAction)toggleLibrary:(id)sender;
- (IBAction)toggleCrop:(id)sender;
- (IBAction)toggleFilters:(id)sender;
- (IBAction)toggleConfirmation:(id)sender;
- (IBAction)toggleSaveTakenImages:(id)sender;
- (IBAction)toggleSaveEditedImages:(id)sender;

@end

