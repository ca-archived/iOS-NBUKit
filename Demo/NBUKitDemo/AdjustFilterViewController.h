//
//  AdjustFilterViewController.h
//  NBUKitDemo
//
//  Created by Ernesto Rivera on 2013/02/22.
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

#import <UIKit/UIKit.h>

@class AdjustFilterTitleCell, AdjustFilterValueCell;

@interface AdjustFilterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

// Outlets
@property (weak, nonatomic) IBOutlet UITableView * tableView;
@property (weak, nonatomic) IBOutlet UIImageView * imageView;

// Properties
@property (strong, nonatomic) UIImage * image;
@property (strong, nonatomic) NSArray * filters;

// Actions
- (IBAction)changeImage:(id)sender;
- (IBAction)saveFilterGroup:(id)sender;

// Methods
- (void)updateImage;
- (void)toggleEnabledFilters;
- (void)moveFilterUp:(NBUFilter *)filter;
- (void)moveFilterDown:(NBUFilter *)filter;
- (void)removeFilter:(NBUFilter *)filter;

@end


@interface AdjustFilterCell : UITableViewCell

+ (AdjustFilterTitleCell *)titleCellForForFilter:(NBUFilter *)filter;
+ (AdjustFilterValueCell *)valueCellForForKey:(NSString *)valueKey
                                       filter:(NBUFilter *)filter;

@property (strong, nonatomic) NBUFilter * filter;
@property (weak, nonatomic) IBOutlet UILabel * label;
@property (nonatomic, readonly) AdjustFilterViewController * viewController;

- (IBAction)updateFilter:(id)sender;

@end


@interface AdjustFilterTitleCell : AdjustFilterCell

@property (weak, nonatomic) IBOutlet UILabel * providerLabel;
@property (weak, nonatomic) IBOutlet UISwitch * enableSwitch;
@property (weak, nonatomic) IBOutlet UIButton * moveUpButton;
@property (weak, nonatomic) IBOutlet UIButton * moveDownButton;
@property (weak, nonatomic) IBOutlet UIButton * resetButton;
@property (weak, nonatomic) IBOutlet UIButton * removeButton;

- (IBAction)moveUp:(id)sender;
- (IBAction)moveDown:(id)sender;
- (IBAction)reset:(id)sender;
- (IBAction)remove:(id)sender;

@end


@interface AdjustFilterValueCell : AdjustFilterCell

@property (nonatomic, readonly)         NSString * valueKey;

@property (nonatomic, getter=isEnabled) BOOL enabled;

- (void)setFilter:(NBUFilter *)filter
              key:(NSString *)valueKey;

@end


@interface AdjustFilterSliderCell : AdjustFilterValueCell

@property (weak, nonatomic) IBOutlet UISlider * slider;
@property (weak, nonatomic) IBOutlet UILabel * currentValueLabel;
@property (weak, nonatomic) IBOutlet UILabel * minValueLabel;
@property (weak, nonatomic) IBOutlet UILabel * maxValueLabel;

@end


@interface AdjustFilterSwitchCell : AdjustFilterValueCell

@property (weak, nonatomic) IBOutlet UISwitch * onOffSwitch;

@end


@interface AdjustFilterButtonCell : AdjustFilterValueCell

@property (weak, nonatomic) IBOutlet UIButton * button;

- (IBAction)buttonTapped:(id)sender;

@end

