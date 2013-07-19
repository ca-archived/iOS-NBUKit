//
//  PresetFilterViewController.m
//  NBUKitDemo
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

#import "PresetFilterViewController.h"
#import <NBUKit/NBUFilterGroup.h>

@implementation PresetFilterViewController
{
    NSArray * _providerFilters;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Configure and set all available filters
    _providerFilters = [NBUFilterProvider availableFilters];
    self.filters = _providerFilters;

    /*
     Another possibility:
     
    _filters = @[
                 [NBUFilterProvider filterWithName:@"Reset"
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
     */
    
    // Our test image
    self.image = [UIImage imageNamed:@"photo_hires.jpg"];
    
    // Our resultBlock
    __unsafe_unretained PresetFilterViewController * weakSelf = self;
    self.resultBlock = ^(UIImage * image)
    {
        // *** Do whatever you want with the resulting image here ***
        
        // Push the resulting image in a new controller
        NBUGalleryViewController * controller = [NBUGalleryViewController new];
        controller.objectArray = @[image];
        [weakSelf.navigationController pushViewController:controller
                                                 animated:YES];
    };
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Add .acv filters
    NSMutableArray * customFilters = [NSMutableArray array];
    NSArray * fileURLs = [[NSFileManager defaultManager] URLsForFilesWithExtensions:@[@"acv"]
                                                              searchInDirectoryURLs:@[[NSBundle mainBundle].bundleURL]];
    for (NSURL * url in fileURLs)
    {
        [customFilters addObject:[NBUFilterProvider filterWithName:[url.lastPathComponent stringByDeletingPathExtension]
                                                              type:NBUFilterTypeToneCurve
                                                            values:@{@"curveFile": url}]];
    }
    
    // Add custom filters created with the editor
    NSURL * filtersURL = [[UIApplication sharedApplication].libraryDirectory URLByAppendingPathComponent:@"Filters"];
    NSArray * contents = [[NSFileManager defaultManager] URLsForFilesWithExtensions:@[@"plist"]
                                                              searchInDirectoryURLs:@[filtersURL]];
    
    NBULogInfo(@"Filters folder contents: %@", contents);
    
    NBUFilterGroup * filter;
    NSDictionary * configuration;
    for (NSURL * fileURL in contents)
    {
        configuration = [NSDictionary dictionaryWithContentsOfURL:fileURL];
        if (!configuration)
        {
            NBULogWarn(@"Skipping file at: %@", fileURL);
            continue;
        }
        
        filter = [NBUFilterGroup filterGroupWithName:nil
                                                type:NBUFilterTypeGroup
                                             filters:nil];
        filter.configurationDictionary = configuration;
        
        NBULogInfo(@"Adding %@", filter);
        
        [customFilters addObject:filter];
    }
    
    self.filters = [_providerFilters arrayByAddingObjectsFromArray:customFilters];
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

@end

