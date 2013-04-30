//
//  NBUFilterThumbnailView.h
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/09/05.
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

#import "NBUObjectView.h"

@class NBUFilter;

/// Possible refresh statuses.
enum
{
    NBUSelectionTypeNone                = 0 << 0,
    NBUSelectionTypeAlphaImageView      = 1 << 0,
    NBUSelectionTypeAlphaLabel          = 1 << 1,
    NBUSelectionTypeShowSelectionView   = 1 << 2,
    NBUSelectionTypeDefault             = (NBUSelectionTypeAlphaImageView |
                                           NBUSelectionTypeAlphaLabel |
                                           NBUSelectionTypeShowSelectionView),
};
typedef NSUInteger NBUSelectionType;

/**
 A simple ObjectView to display a filtered thumbnail image and trigger updates
 on its NBUPresetFilterView superview.
 */
@interface NBUFilterThumbnailView : NBUObjectView

/// Associated NBUFilter.
@property (strong, nonatomic, setter=setObject:,
                              getter=object)        NBUFilter * filter;

/// @name Properties

/// The image to be presented as thumbnail.
@property (assign, nonatomic)                       UIImage * thumbnailImage;

/// Whether the thumbanil view is selected or not.
@property (nonatomic, getter=isSelected)            BOOL selected;

/// Wheter to disable tap to deselect.
/// @discussion Default `NO`.
@property (nonatomic)                               BOOL disableTapToDeselect;

/// The current default selection type.
/// @discussion Default `NBUSelectionTypeAlphaImageView | NBUSelectionTypeAlphaLabel | NBUSelectionTypeShowSelectionView`.
+ (NBUSelectionType)selectionType;

/// Change the default selection type.
/// @discussion Default `NBUSelectionTypeAlphaImageView | NBUSelectionTypeAlphaLabel | NBUSelectionTypeShowSelectionView`.
/// @param selectionType The new selection type.
+ (void)setSelectionType:(NBUSelectionType)selectionType;

/// @name Outlets

/// The label used to disaplay the [NBUFilter name].
@property (assign, nonatomic) IBOutlet              UILabel * nameLabel;

/// The view to display the filtered thumbnail image.
@property (assign, nonatomic) IBOutlet              UIImageView * imageView;

/// An optional view to be shown/hidden upon selection.
@property (assign, nonatomic) IBOutlet              UIView * selectionView;

@end

