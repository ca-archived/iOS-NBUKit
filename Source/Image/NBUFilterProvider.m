//
//  NBUFilterProvider.m
//  NBUKit
//
//  Created by エルネスト 利辺羅 on 12/05/03.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_IMAGE

#import "NBUFilterProvider.h"
#import "NBUGPUImageFilterProvider.h"
#import "NBUCoreImageFilterProvider.h"

static NSMutableArray * _providers;
static NSArray * _availableFilterTypes;

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

+ (NBUFilter *)filterWithName:(NSString *)name
                         type:(NSString *)type
                       values:(NSArray *)values
{
    // Handle the "None" filter
    if ([type isEqualToString:NBUFilterTypeNone])
    {
        return [NBUFilter filterWithName:name
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
            return [provider filterWithName:name
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

