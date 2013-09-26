//
//  CustomGPUImageFilterProvider.m
//  NBUKitDemo
//
//  Created by Ernesto Rivera on 2013/02/26.
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
                       values:(NSDictionary *)values
{
    NSDictionary * attributes;
    NBUConfigureFilterBlock block;
    
    if ([type isEqualToString:CustomFilterTypeSphereRefraction])
    {
        NSString * refractiveIndex  = @"refractiveIndex";
        NSString * radius           = @"radius";
        NSString * centerX          = @"centerX";
        NSString * centerY          = @"centerY";
        attributes = @{refractiveIndex  : @{NBUFilterValueDescriptionKey : @"Refractive index",
                                            NBUFilterValueTypeKey        : NBUFilterValueTypeFloat,
                                            NBUFilterDefaultValueKey     : @(0.3),
                                            NBUFilterMaximumValueKey     : @(1.0),
                                            NBUFilterMinimumValueKey     : @(-1.0)},
                       radius           : @{NBUFilterValueDescriptionKey : @"Radius",
                                            NBUFilterValueTypeKey        : NBUFilterValueTypeFloat,
                                            NBUFilterDefaultValueKey     : @(0.65),
                                            NBUFilterIdentityValueKey    : @(0.0),
                                            NBUFilterMaximumValueKey     : @(1.0),
                                            NBUFilterMinimumValueKey     : @(0.0)},
                       centerX          : @{NBUFilterValueDescriptionKey : @"Center x",
                                            NBUFilterValueTypeKey        : NBUFilterValueTypeFloat,
                                            NBUFilterDefaultValueKey     : @(0.5),
                                            NBUFilterMaximumValueKey     : @(1.0),
                                            NBUFilterMinimumValueKey     : @(0.0)},
                       centerY          : @{NBUFilterValueDescriptionKey : @"Center y",
                                            NBUFilterValueTypeKey        : NBUFilterValueTypeFloat,
                                            NBUFilterDefaultValueKey     : @(0.5),
                                            NBUFilterMaximumValueKey     : @(1.0),
                                            NBUFilterMinimumValueKey     : @(0.0)}};
        block = ^(NBUFilter * filter,
                  GPUImageSphereRefractionFilter * gpuFilter)
        {
            // Get instance
            if (!gpuFilter)
            {
                gpuFilter = [GPUImageSphereRefractionFilter new];
            }
            
            // Configure it
            gpuFilter.refractiveIndex   = [filter floatValueForKey:refractiveIndex];
            gpuFilter.radius            = [filter floatValueForKey:radius];
            gpuFilter.center            = CGPointMake([filter floatValueForKey:centerX],
                                                      [filter floatValueForKey:centerY]);
            
            return gpuFilter;
        };
    }
    else if ([type isEqualToString:CustomFilterTypeBulgeDistortion])
    {
        NSString * scale    = @"scale";
        NSString * radius   = @"radius";
        NSString * centerX  = @"centerX";
        NSString * centerY  = @"centerY";
        attributes = @{scale    : @{NBUFilterValueDescriptionKey : @"Scale",
                                    NBUFilterValueTypeKey        : NBUFilterValueTypeFloat,
                                    NBUFilterDefaultValueKey     : @(0.5),
                                    NBUFilterMaximumValueKey     : @(1.0),
                                    NBUFilterMinimumValueKey     : @(-1.0)},
                       radius   : @{NBUFilterValueDescriptionKey : @"Radius",
                                    NBUFilterValueTypeKey        : NBUFilterValueTypeFloat,
                                    NBUFilterDefaultValueKey     : @(0.25),
                                    NBUFilterIdentityValueKey    : @(0.0),
                                    NBUFilterMaximumValueKey     : @(1.0),
                                    NBUFilterMinimumValueKey     : @(0.0)},
                       centerX  : @{NBUFilterValueDescriptionKey : @"Center x",
                                    NBUFilterValueTypeKey        : NBUFilterValueTypeFloat,
                                    NBUFilterDefaultValueKey     : @(0.5),
                                    NBUFilterMaximumValueKey     : @(1.0),
                                    NBUFilterMinimumValueKey     : @(0.0)},
                       centerY  : @{NBUFilterValueDescriptionKey : @"Center y",
                                    NBUFilterValueTypeKey        : NBUFilterValueTypeFloat,
                                    NBUFilterDefaultValueKey     : @(0.5),
                                    NBUFilterMaximumValueKey     : @(1.0),
                                    NBUFilterMinimumValueKey     : @(0.0)}};
        block = ^(NBUFilter * filter,
                  GPUImageBulgeDistortionFilter * gpuFilter)
        {
            // Get instance
            if (!gpuFilter)
            {
                gpuFilter = [GPUImageBulgeDistortionFilter new];
            }
            
            // Configure it
            gpuFilter.scale     = [filter floatValueForKey:scale];
            gpuFilter.radius    = [filter floatValueForKey:radius];
            gpuFilter.center    = CGPointMake([filter floatValueForKey:centerX],
                                              [filter floatValueForKey:centerY]);
            
            return gpuFilter;
        };
    }
    else if ([type isEqualToString:CustomFilterTypeGaussianSelectiveBlur])
    {
        NSString * blurSize         = @"blurSize";
        NSString * excludeBlurSize  = @"excludeBlurSize";
        NSString * radius           = @"radius";
        NSString * centerX          = @"centerX";
        NSString * centerY          = @"centerY";
        attributes = @{blurSize         : @{NBUFilterValueDescriptionKey : @"Blur size",
                                            NBUFilterValueTypeKey        : NBUFilterValueTypeFloat,
                                            NBUFilterDefaultValueKey     : @(1.0),
                                            NBUFilterMaximumValueKey     : @(3.0),
                                            NBUFilterMinimumValueKey     : @(0.0)},
                       excludeBlurSize  : @{NBUFilterValueDescriptionKey : @"Exclude blur size",
                                            NBUFilterValueTypeKey        : NBUFilterValueTypeFloat,
                                            NBUFilterDefaultValueKey     : @(1.0),
                                            NBUFilterMaximumValueKey     : @(4.0),
                                            NBUFilterMinimumValueKey     : @(0.0)},
                       radius           : @{NBUFilterValueDescriptionKey : @"Radius",
                                            NBUFilterValueTypeKey        : NBUFilterValueTypeFloat,
                                            NBUFilterDefaultValueKey     : @(1.0),
                                            NBUFilterIdentityValueKey    : @(0.0),
                                            NBUFilterMaximumValueKey     : @(1.0),
                                            NBUFilterMinimumValueKey     : @(0.0)},
                       centerX          : @{NBUFilterValueDescriptionKey : @"Center x",
                                            NBUFilterValueTypeKey        : NBUFilterValueTypeFloat,
                                            NBUFilterDefaultValueKey     : @(0.5),
                                            NBUFilterMaximumValueKey     : @(1.0),
                                            NBUFilterMinimumValueKey     : @(0.0)},
                       centerY          : @{NBUFilterValueDescriptionKey : @"Center y",
                                            NBUFilterValueTypeKey        : NBUFilterValueTypeFloat,
                                            NBUFilterDefaultValueKey     : @(0.5),
                                            NBUFilterMaximumValueKey     : @(1.0),
                                            NBUFilterMinimumValueKey     : @(0.0)}};
        block = ^(NBUFilter * filter,
                  GPUImageGaussianSelectiveBlurFilter * gpuFilter)
        {
            // Get instance
            if (!gpuFilter)
            {
                gpuFilter = [GPUImageGaussianSelectiveBlurFilter new];
            }
            
            // Configure it
            gpuFilter.blurSize = [filter floatValueForKey:blurSize];
            gpuFilter.excludeBlurSize = [filter floatValueForKey:excludeBlurSize];
            gpuFilter.excludeCircleRadius = [filter floatValueForKey:radius];
            gpuFilter.excludeCirclePoint = CGPointMake([filter floatValueForKey:centerX],
                                                       [filter floatValueForKey:centerY]);
            
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
                                        attributes:attributes
                                          provider:self
                              configureFilterBlock:block];
    
    NBULogVerbose(@"%@ %@", THIS_METHOD, filter);
    
    return filter;
}

@end

