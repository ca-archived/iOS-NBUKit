//
//  NBUEditMultiImageViewController.m
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

#import "NBUEditMultiImageViewController.h"

@implementation NBUEditMultiImageViewController

@synthesize mediaInfos = _mediaInfos;
@synthesize currentIndex = _currentIndex;
@synthesize updatesTitle = _updatesTitle;
@synthesize titleLabel = _titleLabel;
@synthesize previousButton = _previousButton;
@synthesize nextButton = _nextButton;

- (void)commonInit
{
    [super commonInit];
    
    // Default values
    _updatesTitle = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Maybe media infos was set before the view was loaded?
    if (_currentIndex < (NSInteger)_mediaInfos.count)
    {
        self.currentIndex = _currentIndex;
    }
}

- (void)setMediaInfos:(NSMutableArray *)mediaInfos
{
    _mediaInfos = mediaInfos;
    
    self.currentIndex = 0;
}

- (NSMutableArray *)editedMediaInfos
{
    [self saveCurrentState];
    
    return _mediaInfos;
}

- (void)setCurrentIndex:(NSInteger)index
{
    // Save current state before changing
    if (_currentIndex != index)
    {
        [self saveCurrentState];
    }
    
    // Constrain index
	index = MAX(index, 0);
    index = MIN(index, (NSInteger)_mediaInfos.count);
    _currentIndex = index;
    
    if (!self.isViewLoaded)
        return;
    
    // Update UI
	[self updateTitle];
	[self updateButtons];
    
    // Update the actual editing image
    super.mediaInfo = _mediaInfos[_currentIndex];
}

- (void)saveCurrentState
{
    if (_currentIndex < (NSInteger)_mediaInfos.count)
    {
        NBUMediaInfo * editedMediaInfo = self.editedMediaInfo;
        if (editedMediaInfo)
            _mediaInfos[_currentIndex] = editedMediaInfo;
    }
}

- (void)updateTitle
{
    if (!_updatesTitle)
        return;
    
    NSString * title = [NSString stringWithFormat:
                        NSLocalizedStringWithDefaultValue(@"NBUEditMultiImageViewController title image X of XX",
                                                          nil, nil,
                                                          @"%i of %i",
                                                          @"NBUEditMultiImageViewController title image X of XX"),
                        _currentIndex + 1,
                        _mediaInfos.count];
    
    // To title label
    if (_titleLabel)
    {
        _titleLabel.text = title;
    }
    // To navigation item
    else
    {
        self.navigationItem.title = title;
    }
}

- (void)updateButtons
{
	_previousButton.enabled = _currentIndex > 0;
    _previousButton.hidden  = _mediaInfos.count <= 1;
	_nextButton.enabled     = _currentIndex < _mediaInfos.count - 1;
    _nextButton.hidden      = _mediaInfos.count <= 1;
}

- (void)goToPrevious:(id)sender
{
    self.currentIndex = _currentIndex - 1;
}

- (void)goToNext:(id)sender
{
    self.currentIndex = _currentIndex + 1;
}

@end

