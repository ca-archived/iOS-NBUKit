//
//  NBUFilterThumbnailView.m
//  NBUKit
//
//  Created by 利辺羅 on 2012/09/05.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import "NBUFilterThumbnailView.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_IMAGE

static NBUSelectionType _selectionType = NBUSelectionTypeDefault;

@implementation NBUFilterThumbnailView
{
    UIImage * _originalImage;
}
@dynamic filter;
@synthesize selected = _selected;
@synthesize disableTapToDeselect = _disableTapToDeselect;
@synthesize nameLabel = _nameLabel;
@synthesize imageView = _imageView;
@synthesize selectionView = _selectionView;

+ (NBUSelectionType)selectionType
{
    return _selectionType;
}

+ (void)setSelectionType:(NBUSelectionType)selectionType
{
    _selectionType = selectionType;
}

- (void)commonInit
{
    [super commonInit];
    
    self.recognizeTap = YES;
}

- (void)objectUpdated:(NSDictionary *)userInfo
{
    [super objectUpdated:userInfo];
    
    if (!_originalImage)
        return;
    
    _nameLabel.text = self.filter.name;
    
    // Updated filtered thumbnail
    self.noContentsView.alpha = 1.0;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       UIImage * image = [NBUFilterProvider applyFilters:@[self.filter]
                                                                 toImage:_originalImage];
                       
                       // Update UI in main queue
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          _imageView.image = image;
                                          self.noContentsView.alpha = 0.0;
                                      });
                   });
}

- (void)setThumbnailImage:(UIImage *)thumbnailImage
{
    _originalImage = thumbnailImage;
    
    // First set the unmodified image
    _imageView.image = thumbnailImage;
    
    // Now update filtered thumbnail
    [self objectUpdated:nil];
}

- (UIImage *)thumbnailImage
{
    return _imageView.image;
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    
    if (_selectionType & NBUSelectionTypeAlphaImageView)
    {
        _imageView.alpha = selected ? 0.7 : 1.0;
    }
    if (_selectionType & NBUSelectionTypeAlphaLabel)
    {
        _nameLabel.alpha = selected ? 0.5 : 1.0;
    }
    if (_selectionType & NBUSelectionTypeShowSelectionView)
    {
        _selectionView.hidden = !selected;
    }
}

- (void)tapped:(id)sender
{
    if (_disableTapToDeselect && _selected)
        return;
    
    self.selected = !_selected;
    
    [super tapped:sender];
}

@end

