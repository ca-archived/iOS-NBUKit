//
//  NBUEditMultiImageViewController.h
//  NBUKit
//
//  Created by Ernesto Rivera on 2013/04/08.
//  Copyright (c) 2013 CyberAgent Inc.
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

#import "NBUEditImageViewController.h"

@protocol UIButton;

/**
 A NBUEditImageViewController subclass that supports multiple images.
 */
@interface NBUEditMultiImageViewController : NBUEditImageViewController

/// The set of NBUMediaInfo objects to be edited.
@property (nonatomic, strong, getter=editedMediaInfos)  NSMutableArray * mediaInfos;

/// The current object's index.
@property (nonatomic)                                   NSInteger currentIndex;

/// @name Customizing Appearance

/// Whether the title should be automatically updated to reflect the currentIndex.
@property (nonatomic)                                   BOOL updatesTitle;

/// An optional title label.
@property (strong, nonatomic) IBOutlet                  UILabel * titleLabel;

/// An optional previous button.
@property (strong, nonatomic) IBOutlet                  id<UIButton> previousButton;
/// An optional next button.
@property (strong, nonatomic) IBOutlet                  id<UIButton> nextButton;

/// @name Actions

/// Go to the previous item.
/// @param sender The sender object.
- (IBAction)goToPrevious:(id)sender;

/// Go to the next item.
/// @param sender The sender object.
- (IBAction)goToNext:(id)sender;

@end

