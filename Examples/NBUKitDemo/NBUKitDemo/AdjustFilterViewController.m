//
//  AdjustFilterViewController.m
//  NBUKitDemo
//
//  Created by 利辺羅 on 2013/02/22.
//  Copyright (c) 2013年 CyberAgent Inc. All rights reserved.
//

#import "AdjustFilterViewController.h"
#import "CustomGPUImageFilterProvider.h"
#import <NBUKit/NBUFilterGroup.h>

@implementation AdjustFilterViewController
{
    NSMutableArray * _filters;
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
    url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"CustomFilter %d.plist", i]];
    filterGroup.name = [NSString stringWithFormat:@"CustomFilter %d", i];
    
    NBULogInfo(@"%@ %@ to: %@", THIS_METHOD, filterGroup, url);
    
    if (![filterGroup.configurationDictionary writeToURL:url
                                              atomically:NO])
    {
        NBULogError(@"Can't save filter configuration dictionary. It may not be Plist compatible: %@",
                    filterGroup.configurationDictionary);
    }
}

- (NSMutableArray *)filters
{
    @synchronized(self)
    {
        if (!_filters)
        {
            // Configure and set all available filters
            _filters = [NSMutableArray array];
            NBUFilter * filter;
            NSArray * filterTypes = [NBUFilterProvider availableFilterTypes];
            for (NSString * type in filterTypes)
            {
                filter = [NBUFilterProvider filterWithName:nil
                                                      type:type
                                                    values:nil];
                filter.enabled = NO;
                [_filters addObject:filter];
            }
        }
        return _filters;
    }
}

- (void)setFilters:(NSArray *)filters
{
    _filters = [NSMutableArray arrayWithArray:filters];
    
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
    return self.filters.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section < self.filters.count)
    {
        NBUFilter * filter = self.filters[section];
        return filter.defaultValues.count + 1;
    }
    else
    {
        // "Save to plist" cell
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
    if (indexPath.section < self.filters.count)
    {
        // Title cell?
        if (indexPath.row == 0)
        {
            cell = [AdjustFilterCell titleCellForForFilter:self.filters[indexPath.section]];
        }
        // Value cell
        else
        {
            cell = [AdjustFilterCell valueCellForForIndex:indexPath.row - 1
                                                   filter:self.filters[indexPath.section]];
        }
    }
    else
    {
        cell = [[NSBundle loadNibNamed:@"AdjustFilterSaveCell"
                                 owner:nil
                               options:nil] objectAtIndex:0];
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
    AdjustFilterTitleCell * cell = [[NSBundle loadNibNamed:@"AdjustFilterTitleCell"
                                                     owner:nil
                                                   options:nil] objectAtIndex:0];
    cell.filter = filter;
    
    return cell;
}

+ (AdjustFilterValueCell *)valueCellForForIndex:(NSUInteger)index
                                         filter:(NBUFilter *)filter
{
    NSString * valueType = filter.attributes[NBUFilterValuesTypeKey][index];
    NSString * nibName;
    if ([valueType isEqualToString:NBUFilterValuesTypeFloat])
    {
        nibName = @"AdjustFilterSliderCell";
    }
    else if ([valueType isEqualToString:NBUFilterValuesTypeBool])
    {
        nibName = @"AdjustFilterSwitchCell";
    }
    else if ([valueType isEqualToString:NBUFilterValuesTypeImage])
    {
        nibName = @"AdjustFilterButtonCell";
    }
    else if ([valueType isEqualToString:NBUFilterValuesTypeFile])
    {
        nibName = @"AdjustFilterButtonCell";
    }
    else
    {
        NBULogError(@"Can't create cell for value at index %d of type '%@' for filter %@",
                    index, valueType, filter);
        return nil;
    }
    
    AdjustFilterValueCell * cell = [[NSBundle loadNibNamed:nibName
                                                     owner:nil
                                                   options:nil] objectAtIndex:0];
    [cell setIndex:index
            filter:filter];
    
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

@synthesize index = _index;
@synthesize enabled = _enabled;

- (void)setIndex:(NSUInteger)index
          filter:(NBUFilter *)filter
{
    super.filter = filter;
    _index = index;
    
    self.enabled = filter.enabled;
    self.label.text = filter.attributes[NBUFilterValuesDescriptionKey][index];
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

- (void)setIndex:(NSUInteger)index
          filter:(NBUFilter *)filter
{
    [super setIndex:index
             filter:filter];
    
    _slider.minimumValue = [filter minFloatValueForIndex:index];
    _slider.maximumValue = [filter maxFloatValueForIndex:index];
    _slider.value = [filter floatValueForIndex:index];
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
    [self.filter setValue:@(_slider.value)
                 forIndex:self.index];
    
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
        [_slider setValue:[filter floatValueForIndex:self.index]
                 animated:YES];
    }
}

@end


@implementation AdjustFilterSwitchCell

@synthesize onOffSwitch = _onOffSwitch;

- (void)setIndex:(NSUInteger)index
          filter:(NBUFilter *)filter
{
    [super setIndex:index
             filter:filter];
    
    _onOffSwitch.on = [filter boolValueForIndex:index];
}

- (void)setEnabled:(BOOL)enabled
{
    super.enabled = enabled;
    
    _onOffSwitch.enabled = enabled;
}

- (IBAction)updateFilter:(id)sender
{
    [self.filter setValue:@(_onOffSwitch.on)
                 forIndex:self.index];
    
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
        [_onOffSwitch setOn:[filter boolValueForIndex:self.index]
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

- (void)setIndex:(NSUInteger)index
          filter:(NBUFilter *)filter
{
    [super setIndex:index
             filter:filter];
    
    _valueType = filter.attributes[NBUFilterValuesTypeKey][index];
    
    if ([_valueType isEqualToString:NBUFilterValuesTypeImage])
    {
        // Nothing for now
//        _fileExtension = @"png";
    }
    else if ([_valueType isEqualToString:NBUFilterValuesTypeFile])
    {
        _currentFileURL = [filter fileURLForIndex:index];
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
    if ([_valueType isEqualToString:NBUFilterValuesTypeImage])
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
                             forIndex:self.index];
                
                [self updateFilter:self];
            }
        }];
    }
    
    // Pick a file
    else if ([_valueType isEqualToString:NBUFilterValuesTypeFile])
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
                                                                    forIndex:self.index];
                                                       
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

