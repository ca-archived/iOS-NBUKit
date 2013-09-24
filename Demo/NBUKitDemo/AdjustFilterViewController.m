//
//  AdjustFilterViewController.m
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

#import "AdjustFilterViewController.h"
#import "CustomGPUImageFilterProvider.h"
#import <NBUKit/NBUFilterGroup.h>

@implementation AdjustFilterViewController
{
    NSMutableArray * _filters;
    NSMutableArray * _filterValueKeys;
    NSMutableArray * _previouslyEnabledFilters;
}

@synthesize image = _originalImage;
@synthesize imageView = _imageView;
@synthesize tableView = _tableView;

+ (void)initialize
{
    // Register our custom provider
    [NBUFilterProvider addProvider:[CustomGPUImageFilterProvider class]];
}

- (void)loadView
{
    // TODO: Do it in category
    [NSBundle loadNibNamed:DEVICE_IS_IPHONE_IDIOM ? @"AdjustFilterViewController" : @"AdjustFilterViewController_iPad"
                     owner:self
                   options:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_originalImage)
    {
        self.image = [UIImage imageNamed:@"photo_hires.jpg"];
    }
}

- (void)setImage:(UIImage *)image
{
    CGFloat scale = [UIScreen mainScreen].scale;
    
    _originalImage = [image imageDonwsizedToFit:CGSizeMake(_imageView.size.width * scale,
                                                           _imageView.size.height * scale)];
    
    [self updateImage];
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (IBAction)changeImage:(id)sender
{
    [NBUImagePickerController startPickerWithTarget:self
                                            options:(NBUImagePickerOptionSingleImage |
                                                     NBUImagePickerOptionDisableFilters |
                                                     NBUImagePickerOptionDisableCrop |
                                                     NBUImagePickerOptionDisableConfirmation |
                                                     NBUImagePickerOptionStartWithLibrary)
                                            nibName:nil
                                        resultBlock:^(NSArray * images)
     {
         if (images.count == 1)
         {
             self.image = images[0];
         }
     }];
}

- (IBAction)saveFilterGroup:(id)sender
{
    // Prepare filter group
    NSMutableArray * enabledFilters = [NSMutableArray array];
    for (NBUFilter * filter in _filters)
    {
        if (filter.enabled)
        {
            [enabledFilters addObject:filter];
        }
    }
    NBUFilterGroup * filterGroup = [NBUFilterGroup filterGroupWithName:nil
                                                                  type:nil
                                                               filters:enabledFilters];
    
    // Save to disk
    NSURL * url = [[UIApplication sharedApplication].libraryDirectory URLByAppendingPathComponent:@"Filters"];
    NSError * error;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:url.path
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error])
    {
        NBULogError(@"Can't create Filters folder: %@ error: %@", url, error);
        return;
    }
    NSUInteger i = 1;
    while ([[NSFileManager defaultManager] fileExistsAtPath:
            [url.path stringByAppendingPathComponent:
             [NSString stringWithFormat:@"CustomFilter %d.plist", i]]])
    {
        i++;
    }
    filterGroup.name = [NSString stringWithFormat:@"CustomFilter %d", i];
    NSURL * plistURL = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"CustomFilter %d.plist", i]];
    NSURL * jsonURL = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"CustomFilter %d.json", i]];
    
    NBULogInfo(@"%@ %@ to: %@ and %@", THIS_METHOD, filterGroup, plistURL, jsonURL);
    
    // Write plist
    NSDictionary * configurationDictionary = filterGroup.configurationDictionary;
    if (![filterGroup.configurationDictionary writeToURL:plistURL
                                              atomically:NO])
    {
        NBULogError(@"Can't save filter configuration dictionary. It may not be Plist compatible: %@",
                    configurationDictionary);
    }
    
    // Write json
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
    {
        NSError * error;
        NSData * data = [NSJSONSerialization dataWithJSONObject:configurationDictionary
                                                        options:NSJSONWritingPrettyPrinted
                                                          error:&error];
        if (error)
        {
            NBULogError(@"Error converting configuraion to JSON: %@", error);
            return;
        }
        
        if (![data writeToURL:jsonURL
                   atomically:NO])
        {
            NBULogError(@"Can't save filter configuration JSON: %@",data);
        }
    }
}

- (NSMutableArray *)filters
{
    @synchronized(self)
    {
        if (!_filters)
        {
            // Configure and set all available filters
            NSMutableArray * filters = [NSMutableArray array];
            NBUFilter * filter;
            NSArray * filterTypes = [NBUFilterProvider availableFilterTypes];
            for (NSString * type in filterTypes)
            {
                filter = [NBUFilterProvider filterWithName:nil
                                                      type:type
                                                    values:nil];
                filter.enabled = NO;
                [filters addObject:filter];
            }
            
            self.filters = filters;
        }
        return _filters;
    }
}

- (void)setFilters:(NSArray *)filters
{
    _filters = [NSMutableArray arrayWithArray:filters];
    
    // Create the value keys
    _filterValueKeys = [NSMutableArray arrayWithCapacity:filters.count];
    for (NBUFilter * filter in filters)
    {
        [_filterValueKeys addObject:filter.attributes ? filter.attributes.allKeys : @[]];
    }
    
    _previouslyEnabledFilters = nil;
    [_tableView reloadData];
}

- (void)toggleEnabledFilters
{
    // Remember the filters to enable?
    NBUFilter * none = _filters[0];
    if (none.enabled)
    {
        _previouslyEnabledFilters = [NSMutableArray array];
        for (NBUFilter * filter in [_filters subarrayWithRange:NSMakeRange(1, _filters.count - 1)])
        {
            if (filter.enabled)
            {
                [_previouslyEnabledFilters addObject:filter];
                filter.enabled = NO;
            }
        }
    }
    
    // Restore previous filters
    else
    {
        for (NBUFilter * filter in _previouslyEnabledFilters)
        {
            filter.enabled = YES;
        }
        _previouslyEnabledFilters = nil;
    }
    
    [self updateImage];
}

- (void)updateImage
{
    // Update "None" filter which will auto-update the "None" switch
    BOOL noneEnabled = YES;
    for (NBUFilter * filter in [_filters subarrayWithRange:NSMakeRange(1, _filters.count - 1)])
    {
        if (filter.enabled)
        {
            noneEnabled = NO;
            break;
        }
    }
    NBUFilter * none = _filters[0];
    none.enabled = noneEnabled;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       UIImage * processedImage = [NBUFilterProvider applyFilters:self.filters
                                                                          toImage:_originalImage];
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          self.imageView.image = processedImage;
                                      });
                   });
}

- (void)moveFilterUp:(NBUFilter *)filter
{
    NSUInteger index = [_filters indexOfObject:filter];
    if (index != NSNotFound &&
        index > 1)
    {
        NBUFilter * otherFilter = _filters[index - 1];
        
        [_filters exchangeObjectAtIndex:index
                      withObjectAtIndex:index - 1];
        [_filterValueKeys exchangeObjectAtIndex:index
                              withObjectAtIndex:index - 1];
        [_tableView moveSection:index
                      toSection:index - 1];
        
        if (filter.enabled &&
            otherFilter.enabled)
        {
            [self updateImage];
        }
    }
}

- (void)moveFilterDown:(NBUFilter *)filter
{
    NSUInteger index = [_filters indexOfObject:filter];
    if (index != NSNotFound &&
        index < _filters.count - 2)
    {
        NBUFilter * otherFilter = _filters[index + 1];
        
        [_filters exchangeObjectAtIndex:index
                      withObjectAtIndex:index + 1];
        [_filterValueKeys exchangeObjectAtIndex:index
                              withObjectAtIndex:index + 1];
        [_tableView moveSection:index
                      toSection:index + 1];
        
        if (filter.enabled &&
            otherFilter.enabled)
        {
            [self updateImage];
        }
    }
}

- (void)removeFilter:(NBUFilter *)filter
{
    NSUInteger index = [_filters indexOfObject:filter];
    if (index != NSNotFound)
    {
        [_filters removeObjectAtIndex:index];
        [_tableView deleteSections:[NSIndexSet indexSetWithIndex:index]
                  withRowAnimation:UITableViewRowAnimationFade];
        
        if (filter.enabled)
        {
            [self updateImage];
        }
    }
    
    // No need to remember it either
    [_previouslyEnabledFilters removeObject:filter];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.filters.count;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return ((NSArray *)_filterValueKeys[section]).count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
    // Title cell?
    if (indexPath.row == 0)
    {
        cell = [AdjustFilterCell titleCellForForFilter:self.filters[indexPath.section]];
    }
    // Value cell
    else
    {
        cell = [AdjustFilterCell valueCellForForKey:_filterValueKeys[indexPath.section][indexPath.row - 1]
                                             filter:self.filters[indexPath.section]];
    }
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row == 0 &&
            indexPath.section != 0) ? 68.0 : 37.0;
}

@end


#pragma mark - Cells

@implementation AdjustFilterCell

@dynamic viewController;
@synthesize filter = _filter;
@synthesize label = _label;

+ (AdjustFilterTitleCell *)titleCellForForFilter:(NBUFilter *)filter
{
    AdjustFilterTitleCell * cell = [NSBundle loadNibNamed:@"AdjustFilterTitleCell"
                                                    owner:nil
                                                  options:nil][0];
    cell.filter = filter;
    
    return cell;
}

+ (AdjustFilterValueCell *)valueCellForForKey:(NSString *)valueKey
                                       filter:(NBUFilter *)filter
{
    NSString * valueType = filter.attributes[valueKey][NBUFilterValueTypeKey];
    NSString * nibName;
    if ([valueType isEqualToString:NBUFilterValueTypeFloat])
    {
        nibName = @"AdjustFilterSliderCell";
    }
    else if ([valueType isEqualToString:NBUFilterValueTypeBool])
    {
        nibName = @"AdjustFilterSwitchCell";
    }
    else if ([valueType isEqualToString:NBUFilterValueTypeImage])
    {
        nibName = @"AdjustFilterButtonCell";
    }
    else if ([valueType isEqualToString:NBUFilterValueTypeFile])
    {
        nibName = @"AdjustFilterButtonCell";
    }
    else
    {
        NBULogError(@"Can't create cell for value '%@' of type '%@' for filter %@",
                    valueKey, valueType, filter);
        return nil;
    }
    
    AdjustFilterValueCell * cell = [NSBundle loadNibNamed:nibName
                                                    owner:nil
                                                  options:nil][0];
    [cell setFilter:filter
                key:valueKey];
    
    return cell;
}

- (void)setFilter:(NBUFilter *)filter
{
    if (_filter == filter)
        return;
    
    if (_filter)
    {
        [_filter removeObserver:self
                     forKeyPath:@"enabled"];
        [_filter removeObserver:self
                     forKeyPath:@"values"];
    }
    
    _filter = filter;
    
    [filter addObserver:self
             forKeyPath:@"enabled"
                options:0
                context:nil];
    [filter addObserver:self
             forKeyPath:@"values"
                options:0
                context:nil];
}

- (void)dealloc
{
    [_filter removeObserver:self
                 forKeyPath:@"enabled"];
    [_filter removeObserver:self
                 forKeyPath:@"values"];
}

- (void)updateFilter:(id)sender
{
    [self.viewController updateImage];
}

@end


@implementation AdjustFilterTitleCell

@synthesize providerLabel = _providerLabel;
@synthesize enableSwitch = _enableSwitch;
@synthesize moveUpButton = _moveUpButton;
@synthesize moveDownButton = _moveDownButton;
@synthesize resetButton = _resetButton;
@synthesize removeButton = _removeButton;

- (void)setFilter:(NBUFilter *)filter
{
    super.filter = filter;
    
    self.label.text = filter.name;
    _providerLabel.text = filter.provider ? NSStringFromClass(filter.provider) : @"";
    _enableSwitch.on = filter.enabled;
}

- (void)updateFilter:(id)sender
{
    self.filter.enabled = _enableSwitch.on;
    
    // "None" filter?
    if ([self.filter.type isEqualToString:NBUFilterTypeNone])
    {
        [self.viewController toggleEnabledFilters];
    }
    else
    {
        [super updateFilter:sender];
    }
}

- (IBAction)reset:(id)sender
{
    [self.filter reset];
    
    [super updateFilter:sender];
}

- (IBAction)moveUp:(id)sender
{
    [self.viewController moveFilterUp:self.filter];
}

- (IBAction)moveDown:(id)sender
{
    [self.viewController moveFilterDown:self.filter];
}

- (IBAction)remove:(id)sender
{
    [self.viewController removeFilter:self.filter];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(NBUFilter *)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"enabled"])
    {
        [_enableSwitch setOn:self.filter.enabled
                    animated:YES];
    }
}

@end


@implementation AdjustFilterValueCell

@synthesize valueKey = _valueKey;
@synthesize enabled = _enabled;

- (void)setFilter:(NBUFilter *)filter
              key:(NSString *)valueKey
{
    super.filter = filter;
    _valueKey = valueKey;
    
    self.enabled = filter.enabled;
    self.label.text = filter.attributes[valueKey][NBUFilterValueDescriptionKey];
}

- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
    
    self.label.alpha = enabled ? 1.0 : 0.7;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(NBUFilter *)filter
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"enabled"])
    {
        self.enabled = filter.enabled;
    }
}

@end


@implementation AdjustFilterSliderCell

@synthesize slider = _slider;
@synthesize currentValueLabel = _currentValueLabel;
@synthesize minValueLabel = _minValueLabel;
@synthesize maxValueLabel = _maxValueLabel;

- (void)setFilter:(NBUFilter *)filter
              key:(NSString *)valueKey
{
    [super setFilter:filter
                 key:valueKey];
    
    _slider.minimumValue = [filter minFloatValueForKey:valueKey];
    _slider.maximumValue = [filter maxFloatValueForKey:valueKey];
    _slider.value = [filter floatValueForKey:valueKey];
    _minValueLabel.text = [NSString stringWithFormat:@"%0.2f", _slider.minimumValue];
    _maxValueLabel.text = [NSString stringWithFormat:@"%0.2f", _slider.maximumValue];
    _currentValueLabel.text = [NSString stringWithFormat:@"%0.2f", _slider.value];
}

- (void)setEnabled:(BOOL)enabled
{
    super.enabled = enabled;
    
    _slider.enabled = enabled;
    _minValueLabel.alpha = enabled ? 1.0 : 0.7;
    _maxValueLabel.alpha = enabled ? 1.0 : 0.7;
    _currentValueLabel.alpha = enabled ? 1.0 : 0.7;
}

- (IBAction)updateFilter:(id)sender
{
    _currentValueLabel.text = [NSString stringWithFormat:@"%0.2f", _slider.value];
    self.filter.values[self.valueKey] = @(_slider.value);
    
    [super updateFilter:sender];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(NBUFilter *)filter
                        change:(NSDictionary *)change
                       context:(void *)context
{
    [super observeValueForKeyPath:keyPath
                         ofObject:filter
                           change:change
                          context:context];
    
    if ([keyPath isEqualToString:@"values"])
    {
        [_slider setValue:[filter floatValueForKey:self.valueKey]
                 animated:YES];
    }
}

@end


@implementation AdjustFilterSwitchCell

@synthesize onOffSwitch = _onOffSwitch;

- (void)setFilter:(NBUFilter *)filter
              key:(NSString *)valueKey
{
    [super setFilter:filter
                 key:valueKey];
    
    _onOffSwitch.on = [filter boolValueForKey:valueKey];
}

- (void)setEnabled:(BOOL)enabled
{
    super.enabled = enabled;
    
    _onOffSwitch.enabled = enabled;
}

- (IBAction)updateFilter:(id)sender
{
    [self.filter setValue:@(_onOffSwitch.on)
                   forKey:self.valueKey];
    
    [super updateFilter:sender];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(NBUFilter *)filter
                        change:(NSDictionary *)change
                       context:(void *)context
{
    [super observeValueForKeyPath:keyPath
                         ofObject:filter
                           change:change
                          context:context];
    
    if ([keyPath isEqualToString:@"values"])
    {
        [_onOffSwitch setOn:[filter boolValueForKey:self.valueKey]
                   animated:YES];
    }
}

@end


@implementation AdjustFilterButtonCell
{
    NSString * _valueType;
    NSString * _fileExtension;
    NSURL * _currentFileURL;
}

@synthesize button = _button;

- (void)setFilter:(NBUFilter *)filter
              key:(NSString *)valueKey
{
    [super setFilter:filter
                 key:valueKey];
    
    _valueType = filter.attributes[valueKey][NBUFilterValueTypeKey];
    
    if ([_valueType isEqualToString:NBUFilterValueTypeImage])
    {
        // Nothing for now
        //        _fileExtension = @"png";
    }
    else if ([_valueType isEqualToString:NBUFilterValueTypeFile])
    {
        _currentFileURL = [filter fileURLForKey:valueKey];
        _fileExtension = _currentFileURL.pathExtension;
        _button.title = _currentFileURL.lastPathComponent;
    }
}

- (void)setEnabled:(BOOL)enabled
{
    super.enabled = enabled;
    
    _button.enabled = enabled;
}

- (IBAction)buttonTapped:(id)sender
{
    // Pick an image
    if ([_valueType isEqualToString:NBUFilterValueTypeImage])
    {
        [NBUImagePickerController startPickerWithTarget:_button
                                                options:(NBUImagePickerDefaultOptions |
                                                         NBUImagePickerOptionDisableEdition |
                                                         NBUImagePickerOptionDisableConfirmation |
                                                         NBUImagePickerOptionStartWithLibrary)
                                                nibName:nil
                                            resultBlock:^(NSArray * images)
         {
             if (images.count == 1)
             {
                 [self.filter setValue:images[0]
                                forKey:self.valueKey];
                 
                 [self updateFilter:self];
             }
         }];
    }
    
    // Pick a file
    else if ([_valueType isEqualToString:NBUFilterValueTypeFile])
    {
        NSArray * directoyURLs = @[[UIApplication sharedApplication].documentsDirectory,
                                   [[NBUKit resourcesBundle].bundleURL URLByAppendingPathComponent:@"Filters"]];
        NSArray * fileURLs = [[NSFileManager defaultManager] URLsForFilesWithExtensions:@[_fileExtension]
                                                                  searchInDirectoryURLs:directoyURLs];
        if (fileURLs.count == 0)
            return;
        
        NBULogInfo(@"Files found: %@", fileURLs);
        
        NBUActionSheet * sheet = [[NBUActionSheet alloc] initWithTitle:self.label.text
                                                     cancelButtonTitle:@"Cancel"
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:nil
                                                   selectedButtonBlock:^(NSInteger buttonIndex) {
                                                       
                                                       NSURL * selectedURL = fileURLs[buttonIndex];
                                                       
                                                       // No need to update?
                                                       if ([selectedURL.path isEqualToString:_currentFileURL.path])
                                                           return;
                                                       
                                                       _currentFileURL = selectedURL;
                                                       
                                                       _button.title = selectedURL.lastPathComponent;
                                                       [self.filter setValue:selectedURL.path
                                                                      forKey:self.valueKey];
                                                       
                                                       [self updateFilter:self];
                                                   }
                                                     cancelButtonBlock:NULL];
        for (NSURL * fileURL in fileURLs)
        {
            [sheet addButtonWithTitle:fileURL.lastPathComponent];
        }
        
        [sheet showFromView:_button];
    }
}

@end

