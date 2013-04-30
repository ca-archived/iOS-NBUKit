//
//  NBUPresetFilterView.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/08/13.
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

#import "NBUPresetFilterView.h"
#import "ObjectSlideView.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_IMAGE

@implementation NBUPresetFilterView
{
    NSUInteger _currentFilterIndex;
    UIImage * _workingImage;
    UIImage * _thumbnailImage;
    NSMutableArray * _cachedFilteredImages;
}

@synthesize image = _image;
@synthesize workingSize = _workingSize;
@synthesize filters = _filters;
@synthesize currentFilter = _currentFilter;
@synthesize editingImageView = _editingImageView;
@synthesize filterSlideView = _filterSlideView;
@synthesize activityView = _activityView;
@synthesize resetButton = _resetButton;

- (void)commonInit
{
    [super commonInit];
    
    // Register for memory warnings
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetCachedFilteredImages)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Localization
    [_filterSlideView setNoContentsViewText:NSLocalizedStringWithDefaultValue(@"NBUPresetFilterView NoFiltersAvailable",
                                                                              nil, nil,
                                                                              @"No filters available",
                                                                              @"NBUPresetFilterView NoFiltersAvailable")];
}

- (void)dealloc
{
    // Remove observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    
    if (self.window)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(filterThumbnailTapped:)
                                                     name:ActiveViewTappedNotification
                                                   object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:ActiveViewTappedNotification
                                                      object:nil];
    }
}

- (void)filterThumbnailTapped:(NSNotification *)notification
{
    NBUFilterThumbnailView * thumbnailView = notification.object;
    if (![thumbnailView isKindOfClass:[NBUFilterThumbnailView class]])
        return;
    
    NBULogTrace();
    
    self.currentFilter = thumbnailView.selected ? thumbnailView.filter : nil;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    
    NBULogInfo(@"Input image size: %@ orientation: %d",
              NSStringFromCGSize(image.size), image.imageOrientation);
    
    // Get a working-size image
    _workingImage = [image imageDonwsizedToFit:self.workingSize];
    NBULogInfo(@"Working image size: %@: orientation: %d",
              NSStringFromCGSize(_workingImage.size), _workingImage.imageOrientation);
    _editingImageView.image = _workingImage;
    
    // Check if filters are set!
    if (!_filterSlideView.objectArray.count)
    {
        NBULogError(@"You should set the filters property before setting an image");
        return;
    }
    
    // Set the thumbnails
    NSArray * thumbnailViews = _filterSlideView.currentViews;
    CGSize thumbnailSize = ((NBUFilterThumbnailView *)thumbnailViews[0]).imageView.size;
    _thumbnailImage = [image thumbnailWithSize:thumbnailSize];
    NBULogInfo(@"Thumbnail image size: %@ orientation: %d",
              NSStringFromCGSize(_thumbnailImage.size), _thumbnailImage.imageOrientation);
    for (NBUFilterThumbnailView * view in thumbnailViews)
    {
        view.thumbnailImage = _thumbnailImage;
    }
    
    // Reset the current filter
//    self.currentFilter = nil;
//    _activityView.hidden = YES;
    [self resetCachedFilteredImages];
    [self reset:self];
    
    [self setNeedsLayout];
}

- (CGSize)workingSize
{
    if (CGSizeEqualToSize(_workingSize, CGSizeZero))
    {
        CGFloat scale = [UIScreen mainScreen].scale;
        _workingSize = CGSizeMake(_editingImageView.size.width * scale,
                                  _editingImageView.size.height * scale);
    }
    return _workingSize;
}

- (UIImage *)originalImage
{
    return _image;
}

- (UIImage *)image
{
    if (!_currentFilter)
    {
        return self.originalImage;
    }
    
    return [NBUFilterProvider applyFilters:@[_currentFilter]
                                   toImage:self.originalImage];
}

- (void)setFilterSlideView:(ObjectSlideView *)filterSlideView
{
    _filterSlideView = filterSlideView;
    
    // Configure slide view
    _filterSlideView.nibNameForViews = @"NBUFilterThumbnailView";
    _filterSlideView.margin = CGSizeMake(4.0, 4.0);
    _filterSlideView.animated = NO;
}

- (void)setFilters:(NSArray *)filters
{
    _filters = filters;
    
    _filterSlideView.objectArray = filters;
    for (NBUFilterThumbnailView * view in _filterSlideView.currentViews)
    {
        if (!view.thumbnailImage)
        {
            view.thumbnailImage = _thumbnailImage;
        }
    }
    
    [self resetCachedFilteredImages];
}

- (IBAction)reset:(id)sender
{
    self.currentFilter = nil;
}

- (void)resetCachedFilteredImages
{
    _cachedFilteredImages = [NSMutableArray array];
    for (NSUInteger i = 0; i < _filters.count; i++)
    {
        [_cachedFilteredImages addObject:[NSNull null]];
    }
}

- (void)setCurrentFilter:(NBUFilter *)currentFilter
{
    // Update current filter and index
    _currentFilter = currentFilter.type == NBUFilterTypeNone ? nil : currentFilter;
    _currentFilterIndex = currentFilter ? [_filters indexOfObject:currentFilter] : NSNotFound;
    
    // Update selections
    for (NBUFilterThumbnailView * view in _filterSlideView.currentViews)
    {
        view.selected = (view.filter == currentFilter ||
                         (!currentFilter && view.filter.type == NBUFilterTypeNone));
    }
    
    // Update reset button
    _resetButton.enabled = _currentFilter != nil;
    NBULogVerbose(@"setCurrentFilter: %@", _currentFilter);
    
    // Refresh editing view
    [self setNeedsLayout];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return [_editingImageView sizeThatFits:size];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // If current filter is nil then reset the editing image view
    if (!_currentFilter)
    {
        _editingImageView.image = _workingImage;
        _activityView.hidden = YES;
        return;
    }
    
    // Cache result if needed
    UIImage * cachedImage = _cachedFilteredImages[_currentFilterIndex];
    if ((id)cachedImage == [NSNull null])
    {
        _activityView.hidden = NO;
        
        // Process async
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage * image = [NBUFilterProvider applyFilters:@[_currentFilter]
                                                      toImage:_workingImage];
            _cachedFilteredImages[_currentFilterIndex] = image;
            _editingImageView.image = image;
            _activityView.hidden = YES;
        });
        
        return;
    }
    
    _editingImageView.image = cachedImage;
}

@end

