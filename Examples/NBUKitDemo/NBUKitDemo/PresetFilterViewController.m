//
//  PresetFilterViewController.m
//  NBUKitDemo
//
//  Created by 利辺羅 on 2012/08/13.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
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
    NSMutableArray * filters = [NSMutableArray array];
    NBUFilter * filter;
    NSArray * filterTypes = [NBUFilterProvider availableFilterTypes];
    for (NSString * type in filterTypes)
    {
        filter = [NBUFilterProvider filterWithName:nil
                                              type:type
                                            values:nil];
        [filters addObject:filter];
    }
    _providerFilters = filters;
    self.filters = _providerFilters;
    
    /*
     Another possibility:
     
    _filters = @[
                 [NBUFilterProvider filterWithName:NSLocalizedString(@"Reset", @"Filter name")
                                              type:NBUFilterTypeNone
                                            values:nil],
                 [NBUFilterProvider filterWithName:NSLocalizedString(@"Gamma", @"Filter name")
                                              type:NBUFilterTypeGamma
                                            values:nil],
                 [NBUFilterProvider filterWithName:NSLocalizedString(@"Saturation", @"Filter name")
                                              type:NBUFilterTypeSaturation
                                            values:nil],
                 [NBUFilterProvider filterWithName:NSLocalizedString(@"Sharpen", @"Filter name")
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
        UIViewController * controller = [UIViewController new];
        controller.view = [UIScrollView new];
        UIImageView * imageView = [[UIImageView alloc]initWithImage:image];
        [controller.view addSubview:imageView];
        ((UIScrollView *)controller.view).contentSize = imageView.frame.size;
        [weakSelf.navigationController pushViewController:controller
                                                 animated:YES];
    };
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Add custom filters
    NSURL * filtersURL = [[UIApplication sharedApplication].libraryDirectory URLByAppendingPathComponent:@"Filters"];
    NSArray * contents = [[NSFileManager defaultManager] URLsForFilesWithExtensions:@[@"plist"]
                                                              searchInDirectoryURLs:@[filtersURL]];
    
    NBULogInfo(@"Filters folder contents: %@", contents);
    
    NSMutableArray * customFilters = [NSMutableArray array];
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

