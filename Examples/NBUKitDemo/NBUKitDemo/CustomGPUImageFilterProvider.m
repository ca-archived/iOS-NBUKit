//
//  CustomGPUImageFilterProvider.m
//  NBUKitDemo
//
//  Created by 利辺羅 on 2013/02/26.
//  Copyright (c) 2013年 CyberAgent Inc. All rights reserved.
//

#import "CustomGPUImageFilterProvider.h"
#import <GPUImage/GPUImage.h>

NSString * const CustomFilterTypeSphereRefraction         = @"CustomFilterTypeSphereRefraction";
NSString * const CustomFilterTypeBulgeDistortion          = @"CustomFilterTypeBulgeDistortion";
NSString * const CustomFilterTypeGaussianSelectiveBlur    = @"CustomFilterTypeGaussianSelectiveBlur";

@implementation CustomGPUImageFilterProvider

+ (NSArray *)availableFilterTypes
{
    return @[
             CustomFilterTypeBulgeDistortion,
             CustomFilterTypeSphereRefraction,
             CustomFilterTypeGaussianSelectiveBlur
             ];
}

+ (NBUFilter *)filterWithName:(NSString *)name
                         type:(NSString *)type
                       values:(NSArray *)values
{
    NSArray * defaultValues;
    NSArray * identityValues;
    NSDictionary * attributes;
    NBUConfigureFilterBlock block;
    
    if ([type isEqualToString:CustomFilterTypeSphereRefraction])
    {
        defaultValues                                   = @[@(0.30), @(0.65), @(0.5), @(0.5)];
        identityValues                                  = nil;
        attributes = @{NBUFilterValuesDescriptionKey    : @[@"Refractive index",
                                                            @"Radius",
                                                            @"Center x",
                                                            @"Center y"],
                       NBUFilterValuesTypeKey           : @[NBUFilterValuesTypeFloat,
                                                            NBUFilterValuesTypeFloat,
                                                            NBUFilterValuesTypeFloat,
                                                            NBUFilterValuesTypeFloat],
                       NBUFilterMaxValuesKey            : @[@(1.0), @(1.0), @(1.0), @(1.0)],
                       NBUFilterMinValuesKey            : @[@(-1.0), @(0.0), @(0.0), @(0.0)]};
        block = ^(NBUFilter * filter,
                  GPUImageSphereRefractionFilter * gpuFilter)
        {
            // Get instance
            if (!gpuFilter)
            {
                gpuFilter = [GPUImageSphereRefractionFilter new];
            }
            
            // Configure it
            gpuFilter.refractiveIndex = [filter floatValueForIndex:0];
            gpuFilter.radius = [filter floatValueForIndex:1];
            gpuFilter.center = CGPointMake([filter floatValueForIndex:2],
                                           [filter floatValueForIndex:3]);
            
            return gpuFilter;
        };
    }
    else if ([type isEqualToString:CustomFilterTypeBulgeDistortion])
    {
        defaultValues                                   = @[@(0.5), @(0.25), @(0.5), @(0.5)];
        identityValues                                  = nil;
        attributes = @{NBUFilterValuesDescriptionKey    : @[@"Scale",
                                                            @"Radius",
                                                            @"Center x",
                                                            @"Center y"],
                       NBUFilterValuesTypeKey           : @[NBUFilterValuesTypeFloat,
                                                            NBUFilterValuesTypeFloat,
                                                            NBUFilterValuesTypeFloat,
                                                            NBUFilterValuesTypeFloat],
                       NBUFilterMaxValuesKey            : @[@(1.0), @(1.0), @(1.0), @(1.0)],
                       NBUFilterMinValuesKey            : @[@(-1.0), @(0.0), @(0.0), @(0.0)]};
        block = ^(NBUFilter * filter,
                  GPUImageBulgeDistortionFilter * gpuFilter)
        {
            // Get instance
            if (!gpuFilter)
            {
                gpuFilter = [GPUImageBulgeDistortionFilter new];
            }
            
            // Configure it
            gpuFilter.scale = [filter floatValueForIndex:0];
            gpuFilter.radius = [filter floatValueForIndex:1];
            gpuFilter.center = CGPointMake([filter floatValueForIndex:2],
                                           [filter floatValueForIndex:3]);
            
            return gpuFilter;
        };
    }
    else if ([type isEqualToString:CustomFilterTypeGaussianSelectiveBlur])
    {
        defaultValues                                   = @[@(1.0), @(1.0), @(1.0), @(0.5), @(0.5)];
        identityValues                                  = nil;
        attributes = @{NBUFilterValuesDescriptionKey    : @[@"Blur size",
                                                            @"Exclude blur size",
                                                            @"Exclude radius",
                                                            @"Exclude point x",
                                                            @"Exclude point y"],
                       NBUFilterValuesTypeKey           : @[NBUFilterValuesTypeFloat,
                                                            NBUFilterValuesTypeFloat,
                                                            NBUFilterValuesTypeFloat,
                                                            NBUFilterValuesTypeFloat,
                                                            NBUFilterValuesTypeFloat],
                       NBUFilterMaxValuesKey            : @[@(3.0), @(4.0), @(1.0), @(1.0), @(1.0)],
                       NBUFilterMinValuesKey            : @[@(0.0), @(0.0), @(0.0), @(0.0), @(0.0)]};
        block = ^(NBUFilter * filter,
                  GPUImageGaussianSelectiveBlurFilter * gpuFilter)
        {
            // Get instance
            if (!gpuFilter)
            {
                gpuFilter = [GPUImageGaussianSelectiveBlurFilter new];
            }
            
            // Configure it
            gpuFilter.blurSize = [filter floatValueForIndex:0];
            gpuFilter.excludeBlurSize = [filter floatValueForIndex:1];
            gpuFilter.excludeCircleRadius = [filter floatValueForIndex:2];
            gpuFilter.excludeCirclePoint = CGPointMake([filter floatValueForIndex:3],
                                                       [filter floatValueForIndex:4]);
            
            return gpuFilter;
        };
    }
    else
    {
        NBULogWarn(@"NBUFilter of type '%@' is not available", type);
        return nil;
    }
    
    NBUFilter * filter = [NBUFilter filterWithName:name
                                              type:type
                                            values:values
                                     defaultValues:defaultValues
                                    identityValues:identityValues
                                        attributes:attributes
                                          provider:self
                              configureFilterBlock:block];
    
    NBULogVerbose(@"%@ %@", THIS_METHOD, filter);
    
    return filter;
}

@end

