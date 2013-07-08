//
//  NBUFilterProvider.m
//  NBUKit
//
//  Created by Ernesto Rivera on 12/05/03.
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

#import "NBUFilterProvider.h"
#import "NBUKitPrivate.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_IMAGE

// Built-in filter types
NSString * const NBUFilterTypeNone              = @"NBUFilterTypeNone";
NSString * const NBUFilterTypeContrast          = @"NBUFilterTypeContrast";
NSString * const NBUFilterTypeBrightness        = @"NBUFilterTypeBrightness";
NSString * const NBUFilterTypeSaturation        = @"NBUFilterTypeSaturation";
NSString * const NBUFilterTypeExposure          = @"NBUFilterTypeExposure";
NSString * const NBUFilterTypeSharpen           = @"NBUFilterTypeSharpen";
NSString * const NBUFilterTypeGamma             = @"NBUFilterTypeGamma";
NSString * const NBUFilterTypeAuto              = @"NBUFilterTypeAuto";
NSString * const NBUFilterTypeMonochrome        = @"NBUFilterTypeMonochrome";
NSString * const NBUFilterTypeMultiplyBlend     = @"NBUFilterTypeMultiplyBlend";
NSString * const NBUFilterTypeAdditiveBlend     = @"NBUFilterTypeAdditiveBlend";
NSString * const NBUFilterTypeAlphaBlend        = @"NBUFilterTypeAlphaBlend";
NSString * const NBUFilterTypeSourceOver        = @"NBUFilterTypeSourceOver";
NSString * const NBUFilterTypeACV               = @"NBUFilterTypeACV";
NSString * const NBUFilterTypeFisheye           = @"NBUFilterTypeFisheye";
NSString * const NBUFilterTypeMaskBlur          = @"NBUFilterTypeMaskBlur";
NSString * const NBUFilterTypeGroup             = @"NBUFilterTypeGroup";

// Static variables
static NSMutableArray * _providers;
static NSArray * _availableFilterTypes;
static NSDictionary * _localizedFilterNames;

@implementation NBUFilterProvider

+ (void)initialize
{
    _providers = [NSMutableArray array];
    
    // Add GPUImage
    [self addProvider:[NBUGPUImageFilterProvider class]];
    
    // Add CoreImage
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
    {
        [self addProvider:[NBUCoreImageFilterProvider class]];
    }
}

+ (void)addProvider:(Class<NBUFilterProvider>)provider
{
    [_providers addObject:provider];
    
    // Reset available filters
    _availableFilterTypes = nil;
}

+ (NSString *)localizedNameForFilterWithType:(NSString *)type
{
    if (!_localizedFilterNames)
    {
        // Read the localized filter names
        _localizedFilterNames = @
        {
            NBUFilterTypeNone           : NSLocalizedStringWithDefaultValue(@"NBUFilterProvider None filter",
                                                                            nil, nil,
                                                                            @"None",
                                                                            @"NBUFilterProvider None filter"),
            NBUFilterTypeContrast       : NSLocalizedStringWithDefaultValue(@"NBUFilterProvider Contrast filter",
                                                                            nil, nil,
                                                                            @"Contrast",
                                                                            @"NBUFilterProvider Contrast filter"),
            NBUFilterTypeBrightness     : NSLocalizedStringWithDefaultValue(@"NBUFilterProvider Brightness filter",
                                                                            nil, nil,
                                                                            @"Brightness",
                                                                            @"NBUFilterProvider Brightness filter"),
            NBUFilterTypeSaturation     : NSLocalizedStringWithDefaultValue(@"NBUFilterProvider Saturation filter",
                                                                            nil, nil,
                                                                            @"Saturation",
                                                                            @"NBUFilterProvider Saturation filter"),
            NBUFilterTypeExposure       : NSLocalizedStringWithDefaultValue(@"NBUFilterProvider Exposure filter",
                                                                            nil, nil,
                                                                            @"Exposure",
                                                                            @"NBUFilterProvider Exposure filter"),
            NBUFilterTypeSharpen        : NSLocalizedStringWithDefaultValue(@"NBUFilterProvider Sharpen filter",
                                                                            nil, nil,
                                                                            @"Sharpen",
                                                                            @"NBUFilterProvider Sharpen filter"),
            NBUFilterTypeGamma          : NSLocalizedStringWithDefaultValue(@"NBUFilterProvider filter",
                                                                            nil, nil,
                                                                            @"Gamma",
                                                                            @"NBUFilterProvider filter"),
            NBUFilterTypeAuto           : NSLocalizedStringWithDefaultValue(@"NBUFilterProvider Auto filter",
                                                                            nil, nil,
                                                                            @"Auto",
                                                                            @"NBUFilterProvider Auto filter"),
            NBUFilterTypeMonochrome     : NSLocalizedStringWithDefaultValue(@"NBUFilterProvider Monochrome filter",
                                                                            nil, nil,
                                                                            @"Monochrome",
                                                                            @"NBUFilterProvider Monochrome filter"),
            NBUFilterTypeMultiplyBlend  : NSLocalizedStringWithDefaultValue(@"NBUFilterProvider Multiply blend filter",
                                                                            nil, nil,
                                                                            @"Multiply blend",
                                                                            @"NBUFilterProvider Multiply blend filter"),
            NBUFilterTypeAdditiveBlend  : NSLocalizedStringWithDefaultValue(@"NBUFilterProvider Additive blend filter",
                                                                            nil, nil,
                                                                            @"Additive blend",
                                                                            @"NBUFilterProvider Additive blend filter"),
            NBUFilterTypeAlphaBlend     : NSLocalizedStringWithDefaultValue(@"NBUFilterProvider Alpha blend filter",
                                                                            nil, nil,
                                                                            @"Alpha blend",
                                                                            @"NBUFilterProvider Alpha blend filter"),
            NBUFilterTypeSourceOver     : NSLocalizedStringWithDefaultValue(@"NBUFilterProvider Source over filter",
                                                                            nil, nil,
                                                                            @"Source over",
                                                                            @"NBUFilterProvider Source over filter"),
            NBUFilterTypeACV            : NSLocalizedStringWithDefaultValue(@"NBUFilterProvider Curve adjustement filter",
                                                                            nil, nil,
                                                                            @"Curve adjustement",
                                                                            @"NBUFilterProvider Curve adjustement filter"),
            NBUFilterTypeFisheye        : NSLocalizedStringWithDefaultValue(@"NBUFilterProvider Fisheye filter",
                                                                            nil, nil,
                                                                            @"Fisheye",
                                                                            @"NBUFilterProvider Fisheye filter"),
            NBUFilterTypeMaskBlur       : NSLocalizedStringWithDefaultValue(@"NBUFilterProvider Mask blur filter",
                                                                            nil, nil,
                                                                            @"Mask blur",
                                                                            @"NBUFilterProvider Mask blur filter"),
            NBUFilterTypeGroup          : NSLocalizedStringWithDefaultValue(@"NBUFilterProvider Filter group filter",
                                                                            nil, nil,
                                                                            @"Filter group",
                                                                            @"NBUFilterProvider Filter group filter")
        };
    }
    return _localizedFilterNames[type];
}

#pragma mark - NBUFilterProvider protocol

+ (NSArray *)availableFilterTypes
{
    // Cached?
    if (_availableFilterTypes)
    {
        return _availableFilterTypes;
    }
    
    // Check available types
    NSMutableSet * filterTypes = [NSMutableSet set];
    for (Class<NBUFilterProvider> provider in _providers)
    {
        [filterTypes addObjectsFromArray:[provider availableFilterTypes]];
    }
    
    // Finish with the "None" filter
    _availableFilterTypes = [@[NBUFilterTypeNone] arrayByAddingObjectsFromArray:filterTypes.allObjects];
    
    NBULogInfo(@"Available filter types: %@", _availableFilterTypes);
    
    return _availableFilterTypes;
}

+ (NSArray *)availableFilters
{
    NSMutableArray * filters = [NSMutableArray array];
    NBUFilter * filter;
    NSArray * filterTypes = [self availableFilterTypes];
    for (NSString * type in filterTypes)
    {
        filter = [self filterWithName:nil
                                 type:type
                               values:nil];
        [filters addObject:filter];
    }
    return filters;
}

+ (NBUFilter *)filterWithName:(NSString *)name
                         type:(NSString *)type
                       values:(NSArray *)values
{
    // Handle the "None" filter
    if ([type isEqualToString:NBUFilterTypeNone])
    {
        return [NBUFilter filterWithName:name ? name : [self localizedNameForFilterWithType:type]
                                    type:type
                                  values:nil
                           defaultValues:nil
                          identityValues:nil
                              attributes:nil
                                provider:nil
                    configureFilterBlock:NULL];
    }
    
    // Check available types
    for (Class<NBUFilterProvider> provider in _providers)
    {
        if ([[provider availableFilterTypes] containsObject:type])
        {
            return [provider filterWithName:name ? name : [self localizedNameForFilterWithType:type]
                                       type:type
                                     values:values];
        }
    }
    
    NBULogWarn(@"NBUFilter of type '%@' is not available", type);
    return nil;
}

+ (UIImage *)applyFilters:(NSArray *)filters
                  toImage:(UIImage *)image
{
    if (!filters.count)
        return image;
    
    // Expand filter groups
    NSMutableArray * expandedFilters = [NSMutableArray array];
    for (NBUFilter * filter in filters)
    {
        // Add normal filters
        if (![filter isKindOfClass:[NBUFilterGroup class]])
        {
            [expandedFilters addObject:filter];
        }
        
        // And add filters from non disabled group filters
        else if (filter.enabled)
        {
            [expandedFilters addObjectsFromArray:((NBUFilterGroup *)filter).filters];
        }
    }
    
    // Order filters by provider
    Class<NBUFilterProvider> currentProvider;
    NSMutableArray * filtersByProvider = [NSMutableArray array];
    NSMutableArray * sameProviderFilters;
    for (NBUFilter * filter in expandedFilters)
    {
        // Skip disabled filters
        if (!filter.enabled)
            continue;
        
        // Different provider?
        if (filter.provider != currentProvider)
        {
            currentProvider = filter.provider;
            sameProviderFilters = [NSMutableArray arrayWithObject:filter];
            [filtersByProvider addObject:sameProviderFilters];
        }
        
        // Same provider
        else
        {
            [sameProviderFilters addObject:filter];
        }
    }
    
    NBULogVerbose(@"filtersByProvider: %@ image size: %@", filtersByProvider, NSStringFromCGSize(image.size));
    
    // Process the image
    UIImage * filteredImage = image;
    
    for (sameProviderFilters in filtersByProvider)
    {
        currentProvider = ((NBUFilter *)sameProviderFilters[0]).provider;
        filteredImage = [currentProvider applyFilters:sameProviderFilters
                                              toImage:filteredImage];
    }
    
    return filteredImage;
}

@end

