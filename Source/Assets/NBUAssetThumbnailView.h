//
//  NBUAssetThumbnailView.h
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/11/08.
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

#import "NBUAssetView.h"

// Media infos' change notification adn its userInfo keys
extern NSString * const NBUAssetThumbnailViewSelectionStateChangedNotification;

/**
 NBUAssetView for NBUAssetImageSizeThumbnail images. Provides selection.
 */
@interface NBUAssetThumbnailView : NBUAssetView

/// @name Handling Selection

/// Whether the view has been selected or not.
/// @note When tapped the view's superclass sends an ActiveViewTappedNotification.
@property (nonatomic, getter=isSelected)    BOOL selected;

/// @name Customizing Selection Behaviour

/// Whether the view should change its alpha value when selected. Default `YES`.
/// @param yesOrNo If `YES` changes its alpha value when selected.
+ (void)setChangesAlphaOnSelection:(BOOL)yesOrNo;

/// The current alpha behaviour for all instances.
+ (BOOL)changesAlphaOnSelection;

/// @name Outlets

/// A view to be shown/hidden upon selection.
/// @see selected
@property (weak, nonatomic) IBOutlet        UIView * selectionView;

@end

