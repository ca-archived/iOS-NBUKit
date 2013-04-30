//
//  NBUEditImageViewController.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/11/30.
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

#import "NBUEditImageViewController.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_IMAGE

@implementation NBUEditImageViewController

@dynamic image;
@synthesize mediaInfo = _mediaInfo;
@synthesize resultBlock = _resultBlock;
@synthesize cropTargetSize = _cropTargetSize;
@synthesize cropGuideSize = _cropGuideSize;
@synthesize maximumScaleFactor = _maximumScaleFactor;
@synthesize filters = _filters;
@synthesize workingSize = _workingSize;
@synthesize filterView = _filterView;
@synthesize cropView = _cropView;

- (void)commonInit
{
    [super commonInit];
    
    _maximumScaleFactor = 1.5;
    _cropGuideSize = CGSizeMake(300.0, 300.0);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configure filterView
    if (!_filterView)
    {
        NBULogVerbose(@"Filters disabled");
    }
    else
    {
        _filterView.filters = self.filters;
        _filterView.workingSize = _workingSize;
    }
    
    // Configure cropView
    if (!_cropView)
    {
        NBULogVerbose(@"Crop disabled");
    }
    else
    {
        _cropView.cropGuideSize = _cropGuideSize;
        _cropView.maximumScaleFactor = _maximumScaleFactor;
    }
}

- (void)setFilters:(NSArray *)filters
{
    _filters = filters;
    
    _filterView.filters = filters;
}

- (NSArray *)filters
{
    if (!_filters)
    {
        // Set some default filters
        
        // iOS 5+
        if (NO && SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
        {
            _filters = @[
                         [NBUFilterProvider filterWithName:nil
                                                      type:NBUFilterTypeNone
                                                    values:nil],
                         [NBUFilterProvider filterWithName:nil
                                                      type:NBUFilterTypeGamma
                                                    values:nil],
                         [NBUFilterProvider filterWithName:nil
                                                      type:NBUFilterTypeSaturation
                                                    values:nil],
                         [NBUFilterProvider filterWithName:nil
                                                      type:NBUFilterTypeAuto
                                                    values:nil]
                         ];
        }
        
        // iOS 4.x
        else
        {
            _filters = @[
                         [NBUFilterProvider filterWithName:nil
                                                      type:NBUFilterTypeNone
                                                    values:nil],
                         [NBUFilterProvider filterWithName:nil
                                                      type:NBUFilterTypeGamma
                                                    values:nil],
                         [NBUFilterProvider filterWithName:nil
                                                      type:NBUFilterTypeSaturation
                                                    values:nil],
                         [NBUFilterProvider filterWithName:nil
                                                      type:NBUFilterTypeSharpen
                                                    values:nil]
                         ];
        }
        
        NBULogInfo(@"Initialized with filters: %@", _filters);
    }
    return _filters;
}

- (void)objectUpdated:(NSDictionary *)userInfo
{
    [super objectUpdated:userInfo];
    
    // Start with cropView if present
    if (_cropView)
    {
        _cropView.image = self.image;
    }
    
    // Or just filterView
    else
    {
        _filterView.image = self.image;
    }
}

- (UIImage *)editedImage
{
    NBULogVerbose(@"Processing image...");
    
    // Get the resulting image from cropView if present
    UIImage * image;
    if (_cropView)
    {
        image = _cropView.image;
    }
    
    // Or from filterView
    else
    {
        image = _filterView.image;
    }
    
    // Set to target size?
    if (!CGSizeEqualToSize(_cropTargetSize, CGSizeZero))
    {
        image = [image imageDonwsizedToFill:_cropTargetSize];
    }
    
    NBULogInfo(@"Processed image with size: %@", NSStringFromCGSize(image.size));
    
    return image;
}

- (void)setMediaInfo:(NBUMediaInfo *)mediaInfo
{
    NBULogInfo(@"%@ %@", THIS_METHOD, mediaInfo);
    
    _mediaInfo = mediaInfo;
    
    self.object = mediaInfo.originalImage;
    
    // Restore state
    NBUFilter * filter = mediaInfo.attributes[NBUMediaInfoFiltersKey];
    if (filter)
    {
        _filterView.currentFilter = filter;
    }
}

- (NBUMediaInfo *)mediaInfo
{
    // Add metadata
    if (_cropView)
    {
        _mediaInfo.attributes[NBUMediaInfoCropRectKey] = [NSValue valueWithCGRect:_cropView.currentCropRect];
    }
    if (_filterView)
    {
        NBUFilter * currentFilter = _filterView.currentFilter;
        if (currentFilter)
            _mediaInfo.attributes[NBUMediaInfoFiltersKey] = currentFilter;
    }
    
    return _mediaInfo;
}

- (NBUMediaInfo *)editedMediaInfo
{
    // Try to refresh the edited image
    UIImage * editedImage = self.editedImage;
    if (editedImage)
    {
        _mediaInfo.editedImage = editedImage;
    }
    
    return self.mediaInfo;
}

- (void)reset:(id)sender
{
    [self objectUpdated:nil];
}

- (void)apply:(id)sender
{
    if (_resultBlock)
    {
        _filterView.activityView.hidden = NO;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
        {
            UIImage * processedImage = self.editedImage;
            dispatch_async(dispatch_get_main_queue(), ^
            {
                _filterView.activityView.hidden = YES;
                _resultBlock(processedImage);
            });
        });
    }
}

@end

