//
//  NBUFilterThumbnailView.h
//  NBUKit
//
//  Created by 利辺羅 on 2012/09/05.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

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
@property (strong, nonatomic, setter = setObject:, getter = object) NBUFilter * filter;

/// @name Properties

/// The image to be presented as thumbnail.
@property (assign, nonatomic)               UIImage * thumbnailImage;

/// Whether the thumbanil view is selected or not.
@property (nonatomic, getter = isSelected)  BOOL selected;

/// Wheter to disable tap to deselect.
///
/// Default `NO`.
@property (nonatomic)                       BOOL disableTapToDeselect;

/// The current default selection type.
///
/// Default `NBUSelectionTypeAlphaImageView | NBUSelectionTypeAlphaLabel | NBUSelectionTypeShowSelectionView`.
+ (NBUSelectionType)selectionType;

/// Change the default selection type.
///
/// Default `NBUSelectionTypeAlphaImageView | NBUSelectionTypeAlphaLabel | NBUSelectionTypeShowSelectionView`.
/// @param selectionType The new selection type.
+ (void)setSelectionType:(NBUSelectionType)selectionType;

/// @name Outlets

/// The label used to disaplay the [NBUFilter name].
@property (assign, nonatomic) IBOutlet      UILabel * nameLabel;

/// The view to display the filtered thumbnail image.
@property (assign, nonatomic) IBOutlet      UIImageView * imageView;

/// An optional view to be shown/hidden upon selection.
@property (assign, nonatomic) IBOutlet      UIView * selectionView;

@end

