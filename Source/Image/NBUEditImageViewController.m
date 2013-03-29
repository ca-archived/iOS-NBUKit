//
//  NBUEditImageViewController.m
//  NBUKit
//
//  Created by 利辺羅 on 2012/11/30.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import "NBUEditImageViewController.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_IMAGE

@implementation NBUEditImageViewController

@dynamic image;
@synthesize resultBlock = _resultBlock;
@synthesize cropGuideSize = _cropGuideSize;
@synthesize maximumScaleFactor = _maximumScaleFactor;
@synthesize filters = _filters;
@synthesize workingSize = _workingSize;
@synthesize filterView = _filterView;
@synthesize cropView = _cropView;

- (void)commonInit
{
    [super commonInit];
    
    _maximumScaleFactor = 1.5;
    _cropGuideSize = CGSizeMake(300.0, 300.0);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configure filterView
    if (!_filterView)
    {
        NBULogVerbose(@"Filters disabled");
    }
    else
    {
        _filterView.filters = self.filters;
        _filterView.workingSize = _workingSize;
    }
    
    // Configure cropView
    if (!_cropView)
    {
        NBULogVerbose(@"Crop disabled");
    }
    else
    {
        _cropView.cropGuideSize = _cropGuideSize;
        _cropView.maximumScaleFactor = _maximumScaleFactor;
    }
}

- (void)setFilters:(NSArray *)filters
{
    _filters = filters;
    
    _filterView.filters = filters;
}

- (NSArray *)filters
{
    if (!_filters)
    {
        // Set some default filters
        
        // iOS 5+
        if (NO && SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
        {
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
                         [NBUFilterProvider filterWithName:NSLocalizedString(@"Auto", @"Filter name")
                                                      type:NBUFilterTypeAuto
                                                    values:nil]
                         ];
        }
        
        // iOS 4.x
        else
        {
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
        }
        
        NBULogInfo(@"Initialized with filters: %@", _filters);
    }
    return _filters;
}

- (void)objectUpdated:(NSDictionary *)userInfo
{
    [super objectUpdated:userInfo];
    
    // Start with cropView if present
    if (_cropView)
    {
        _cropView.image = self.image;
    }
    
    // Or just filterView
    else
    {
        _filterView.image = self.image;
    }
}

- (UIImage *)editedImage
{
    NBULogVerbose(@"Processing image...");
    
    // Get the resulting image from cropView if present
    if (_cropView)
    {
        return _cropView.image;
    }
    
    // Or from filterView
    else
    {
        return _filterView.image;
    }
    
    NBULogVerbose(@"...Processing Done");
}

- (void)reset:(id)sender
{
    [self objectUpdated:nil];
}

- (void)apply:(id)sender
{
    if (_resultBlock)
    {
        _filterView.activityView.hidden = NO;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
        {
            UIImage * processedImage = self.editedImage;
            dispatch_async(dispatch_get_main_queue(), ^
            {
                _filterView.activityView.hidden = YES;
                _resultBlock(processedImage);
            });
        });
    }
}

@end

