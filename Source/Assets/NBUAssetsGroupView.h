//
//  NBUAssetsGroupView.h
//  NBUKit
//
//  Created by 利辺羅 on 2012/08/17.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

/**
 Customizable ObjectView used to present a NBUAssetsGroupView object.
 */
@interface NBUAssetsGroupView : NBUObjectView

/// The associated NBUAssetsGroup.
@property (strong, nonatomic, setter = setObject:, getter = object) NBUAssetsGroup * assetsGroup;

/// @name Outlets

/// An optional group name UILabel.
@property (assign, nonatomic) IBOutlet UILabel * nameLabel;

/// An optional item count UIlabel.
@property (assign, nonatomic) IBOutlet UILabel * countLabel;

/// An optional UIImageView used to display the [NBUAssetsGroup posterImage].
@property (assign, nonatomic) IBOutlet UIImageView * posterImageView;

/// An optional view to display whether the [NBUAssetsGroup isEditable].
@property (assign, nonatomic) IBOutlet UIView * editableView;

@end
