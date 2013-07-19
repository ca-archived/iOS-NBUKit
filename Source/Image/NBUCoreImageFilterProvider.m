//
//  NBUCoreImageFilterProvider.m
//  NBUKit
//
//  Created by Ernesto Rivera on 12/05/01.
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

#import "NBUCoreImageFilterProvider.h"
#import "NBUKitPrivate.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_IMAGE

@implementation NBUCoreImageFilterProvider

+ (void)initialize
{
//    NBULogInfo(@"Available CI filters on this device: %@", [CIFilter filterNamesInCategories:nil]);
//    NBULogInfo(@"+++++ %@", [CIFilter filterWithName:@"CIColorMonochrome"].attributes);
}

+ (CIFilter *)ciFilterWithName:(NSString *)name
{
    CIFilter * filter = [CIFilter filterWithName:name];
//    NBULogInfo(@"%@ %@ attributes: %@", THIS_METHOD, name, filter.attributes);
    return filter;
}

+ (NSArray *)availableFilterTypes
{
    if (SYSTEM_VERSION_LESS_THAN(@"5.0"))
        return nil;
    
    NSArray * iOS5Filters = @[
                              NBUFilterTypeContrast,
                              NBUFilterTypeBrightness,
                              NBUFilterTypeSaturation,
                              NBUFilterTypeExposure,
                              NBUFilterTypeGamma,
                              NBUFilterTypeAuto
                              ];
    
    NSArray * iOS6Filters = @[
                              NBUFilterTypeSharpen
                              ];
    
    if (SYSTEM_VERSION_LESS_THAN(@"6.0"))
    {
        return iOS5Filters;
    }
    else
    {
        return [iOS5Filters arrayByAddingObjectsFromArray:iOS6Filters];
    }
}

+ (NBUFilter *)filterWithName:(NSString *)name
                         type:(NSString *)type
                       values:(NSDictionary *)values
{
    if (SYSTEM_VERSION_LESS_THAN(@"5.0"))
        return nil;
    
    NSDictionary * attributes;
    NBUConfigureFilterBlock block;
    
    // iOS5+
    if ([type isEqualToString:NBUFilterTypeContrast])
    {
        NSString * contrast = @"contrast";
        attributes = @{contrast : @{NBUFilterValueDescriptionKey : @"Contrast",
                                    NBUFilterValueTypeKey        : NBUFilterValueTypeFloat,
                                    NBUFilterDefaultValueKey     : @(1.1),
                                    NBUFilterIdentityValueKey    : @(1.0),
                                    NBUFilterMaximumValueKey     : @(4.0),
                                    NBUFilterMinimumValueKey     : @(0.0)}};
        block = ^(NBUFilter * filter,
                  CIFilter * ciFilter)
        {
            // Create a CI filter?
            if (!ciFilter)
            {
                ciFilter = [self ciFilterWithName:@"CIColorControls"];
            }
            
            // Configure it
            [ciFilter setDefaults];
            [ciFilter setValue:filter.values[contrast]
                        forKey:@"inputContrast"];
            
            return ciFilter;
        };
    }
    else if ([type isEqualToString:NBUFilterTypeBrightness])
    {
        NSString * brightness = @"brightness";
        attributes = @{brightness : @{NBUFilterValueDescriptionKey : @"Brightness",
                                      NBUFilterValueTypeKey        : NBUFilterValueTypeFloat,
                                      NBUFilterDefaultValueKey     : @(0.1),
                                      NBUFilterIdentityValueKey    : @(0.0),
                                      NBUFilterMaximumValueKey     : @(1.0),
                                      NBUFilterMinimumValueKey     : @(-1.0)}};
        block = ^(NBUFilter * filter,
                  CIFilter * ciFilter)
        {
            // Create a CI filter?
            if (!ciFilter)
            {
                ciFilter = [self ciFilterWithName:@"CIColorControls"];
            }
            
            // Configure it
            [ciFilter setDefaults];
            [ciFilter setValue:filter.values[brightness]
                        forKey:@"inputBrightness"];
            
            return ciFilter;
        };
    }
    else if ([type isEqualToString:NBUFilterTypeSaturation])
    {
        NSString * saturation = @"saturation";
        attributes = @{saturation : @{NBUFilterValueDescriptionKey : @"Saturation",
                                      NBUFilterValueTypeKey        : NBUFilterValueTypeFloat,
                                      NBUFilterDefaultValueKey     : @(1.3),
                                      NBUFilterIdentityValueKey    : @(1.0),
                                      NBUFilterMaximumValueKey     : @(2.0),
                                      NBUFilterMinimumValueKey     : @(0.0)}};
        block = ^(NBUFilter * filter,
                  CIFilter * ciFilter)
        {
            // Create a CI filter?
            if (!ciFilter)
            {
                ciFilter = [self ciFilterWithName:@"CIColorControls"];
            }
            
            // Configure it
            [ciFilter setDefaults];
            [ciFilter setValue:filter.values[saturation]
                        forKey:@"inputSaturation"];
            
            return ciFilter;
        };
    }
    else if ([type isEqualToString:NBUFilterTypeExposure])
    {
        NSString * exposure = @"exposure";
        attributes = @{exposure : @{NBUFilterValueDescriptionKey : @"Exposure",
                                    NBUFilterValueTypeKey        : NBUFilterValueTypeFloat,
                                    NBUFilterDefaultValueKey     : @(0.2),
                                    NBUFilterIdentityValueKey    : @(0.0),
                                    NBUFilterMaximumValueKey     : @(10.0),
                                    NBUFilterMinimumValueKey     : @(-10.0)}};
        block = ^(NBUFilter * filter,
                  CIFilter * ciFilter)
        {
            // Create a CI filter?
            if (!ciFilter)
            {
                ciFilter = [self ciFilterWithName:@"CIExposureAdjust"];
            }
            
            // Configure it
            [ciFilter setDefaults];
            [ciFilter setValue:filter.values[exposure]
                        forKey:@"inputEV"];
            
            return ciFilter;
        };
    }
    else if ([type isEqualToString:NBUFilterTypeGamma])
    {
        NSString * gamma = @"gamma";
        attributes = @{gamma : @{NBUFilterValueDescriptionKey : @"Gamma",
                                 NBUFilterValueTypeKey        : NBUFilterValueTypeFloat,
                                 NBUFilterDefaultValueKey     : @(0.8),
                                 NBUFilterIdentityValueKey    : @(1.0),
                                 NBUFilterMaximumValueKey     : @(4.0),
                                 NBUFilterMinimumValueKey     : @(0.0)}}; // CIAttributeSliderMin 0.25
        block = ^(NBUFilter * filter, CIFilter * ciFilter)
        {
            // Create a CI filter?
            if (!ciFilter)
            {
                ciFilter = [self ciFilterWithName:@"CIGammaAdjust"];
            }
            
            // Configure it
            [ciFilter setDefaults];
            [ciFilter setValue:filter.values[gamma]
                        forKey:@"inputPower"];
            
            return ciFilter;
        };
    }
    else if ([type isEqualToString:NBUFilterTypeAuto])
    {
        NSString * autoAdjust = @"autoAdjust";
        attributes = @{autoAdjust : @{NBUFilterValueDescriptionKey : @"Auto adjust",
                                      NBUFilterValueTypeKey        : NBUFilterValueTypeBool,
                                      NBUFilterDefaultValueKey     : @(YES),
                                      NBUFilterIdentityValueKey    : @(NO)}};
        block = NULL; // Special processing at applyFilters:toImage:
    }
    
    // iOS6+
    else if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
    {
        if ([type isEqualToString:NBUFilterTypeSharpen])
        {
            NSString * sharpness = @"sharpness";
            attributes = @{sharpness : @{NBUFilterValueDescriptionKey : @"Sharpness",
                                         NBUFilterValueTypeKey        : NBUFilterValueTypeFloat,
                                         NBUFilterDefaultValueKey     : @(0.4),
                                         NBUFilterIdentityValueKey    : @(0.0),
                                         NBUFilterMaximumValueKey     : @(2.0),
                                         NBUFilterMinimumValueKey     : @(0.0)}};
            block = ^(NBUFilter * filter, CIFilter * ciFilter)
            {
                // Create a CI filter?
                if (!ciFilter)
                {
                    ciFilter = [self ciFilterWithName:@"CISharpenLuminance"];
                }
                
                // Configure it
                [ciFilter setDefaults];
                [ciFilter setValue:filter.values[sharpness]
                            forKey:@"inputSharpness"];
                
                return ciFilter;
            };
        }
    }
    
    // Not available
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

+ (UIImage *)applyFilters:(NSArray *)filters
                  toImage:(UIImage *)image
{
    // Read the CIImage
    CIImage * ciImage = [CIImage imageWithCGImage:[image imageWithOrientationUp].CGImage];
    if (!ciImage)
    {
        ciImage = image.CIImage;
    }
    if (!ciImage)
    {
        NBULogError(@"CIImage couldn't be loaded from %@! The CI filters will be skipped: %@", image, filters);
        return image;
    }
    
    NBULogInfo(@"%@ %@ %@", THIS_METHOD, filters, NSStringFromCGSize(image.size));
    
    // Apply the filters
    CIFilter * ciFilter;
    for (NBUFilter * filter in filters)
    {
        // Skip disabled filters
        if (!filter.enabled)
            continue;
        
        if (![filter.type isEqualToString:NBUFilterTypeAuto])
        {
            ciImage = [self applyCIFilter:filter.concreteFilter
                                toCIImage:ciImage];
        }
        else
        {
            // Auto adjust off?
            if (![filter boolValueForKey:@"autoAdjust"])
                continue;
            
            NSArray * autoFilters = [ciImage autoAdjustmentFilters];
            NBULogVerbose(@"Applying auto adjustment filters: %@", autoFilters);
            for (ciFilter in autoFilters)
            {
                ciImage = [self applyCIFilter:ciFilter
                                    toCIImage:ciImage];
            }
        }
    }
    
    // Convert to CGImage and then UIImage
    CIContext * context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:ciImage
                                       fromRect:ciImage.extent];
    UIImage * uiImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    return uiImage;
}

+ (CIImage *)applyCIFilter:(CIFilter *)ciFilter
                  toCIImage:(CIImage *)ciImage
{
    [ciFilter setValue:ciImage
                forKey:kCIInputImageKey];
    NBULogVerbose(@"Applying: %@", ciFilter);
    return [ciFilter valueForKey:kCIOutputImageKey];
}

@end

