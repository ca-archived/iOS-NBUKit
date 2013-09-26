//
//  NBUGPUImageFilterProvider.m
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

#import "NBUGPUImageFilterProvider.h"
#import "NBUKitPrivate.h"
#import <GPUImage/GPUImage.h>

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_IMAGE

// Private class
@interface NBUGPUMultiInputImageFilterGroup : GPUImageFilterGroup

@property (strong, nonatomic, readonly) NSArray * otherImagePictures;

- (void)setImage:(UIImage *)image
forImagePictureAtIndex:(NSUInteger)index
withTargetFilterAtIndex:(NSUInteger)targetIndex
atTextureLocation:(NSInteger)textureLocation;

@end


// GPUImage shader strings
NSString * const kNBUAlphaMaskShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 void main()
 {
	 lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
	 lowp vec4 textureColor2 = texture2D(inputImageTexture2, textureCoordinate2);
     
	 gl_FragColor = vec4(textureColor.xyz, textureColor2.a);
 }
 );


@implementation NBUGPUImageFilterProvider

+ (NSArray *)availableFilterTypes
{
    return @[
             NBUFilterTypeContrast,
             NBUFilterTypeBrightness,
             NBUFilterTypeSaturation,
             NBUFilterTypeExposure,
             NBUFilterTypeSharpen,
             NBUFilterTypeGamma,
             NBUFilterTypeMonochrome,
             NBUFilterTypeMultiplyBlend,
             NBUFilterTypeAdditiveBlend,
             NBUFilterTypeAlphaBlend,
             NBUFilterTypeSourceOver,
             NBUFilterTypeToneCurve,
             NBUFilterTypeFisheye,
             NBUFilterTypeMaskBlur
             ];
}

+ (NBUFilter *)filterWithName:(NSString *)name
                         type:(NSString *)type
                       values:(NSDictionary *)values
{
    NSDictionary * attributes;
    NBUConfigureFilterBlock block;
    
    if ([type isEqualToString:NBUFilterTypeContrast])
    {
        NSString * contrast = @"contrast";
        attributes = @{contrast : @{NBUFilterValueDescriptionKey : @"Contrast",
                                    NBUFilterValueTypeKey        : NBUFilterValueTypeFloat,
                                    NBUFilterDefaultValueKey     : @(1.2),
                                    NBUFilterIdentityValueKey    : @(1.0),
                                    NBUFilterMaximumValueKey     : @(4.0),
                                    NBUFilterMinimumValueKey     : @(0.0)}};
        block = ^(NBUFilter * filter,
                  GPUImageContrastFilter * gpuFilter)
        {
            // Get instance
            if (!gpuFilter)
            {
                gpuFilter = [GPUImageContrastFilter new];
            }
            
            // Configure it
            gpuFilter.contrast = [filter floatValueForKey:contrast];
            
            return gpuFilter;
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
                  GPUImageBrightnessFilter * gpuFilter)
        {
            // Get instance
            if (!gpuFilter)
            {
                gpuFilter = [GPUImageBrightnessFilter new];
            }
            
            // Configure it
            gpuFilter.brightness = [filter floatValueForKey:brightness];
            
            return gpuFilter;
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
                  GPUImageSaturationFilter * gpuFilter)
        {
            // Get instance
            if (!gpuFilter)
            {
                gpuFilter = [GPUImageSaturationFilter new];
            }
            
            // Configure it
            gpuFilter.saturation = [filter floatValueForKey:saturation];
            
            return gpuFilter;
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
                  GPUImageExposureFilter * gpuFilter)
        {
            // Get instance
            if (!gpuFilter)
            {
                gpuFilter = [GPUImageExposureFilter new];
            }
            
            // Configure it
            gpuFilter.exposure = [filter floatValueForKey:exposure];
            
            return gpuFilter;
        };
    }
    else if ([type isEqualToString:NBUFilterTypeSharpen])
    {
        NSString * sharpness = @"sharpness";
        attributes = @{sharpness : @{NBUFilterValueDescriptionKey : @"Sharpness",
                                     NBUFilterValueTypeKey        : NBUFilterValueTypeFloat,
                                     NBUFilterDefaultValueKey     : @(0.5),
                                     NBUFilterIdentityValueKey    : @(0.0),
                                     NBUFilterMaximumValueKey     : @(4.0),
                                     NBUFilterMinimumValueKey     : @(-4.0)}};
        block = ^(NBUFilter * filter,
                  GPUImageSharpenFilter * gpuFilter)
        {
            // Get instance
            if (!gpuFilter)
            {
                gpuFilter = [GPUImageSharpenFilter new];
            }
            
            // Configure it
            gpuFilter.sharpness = [filter floatValueForKey:sharpness];
            
            return gpuFilter;
        };
    }
    else if ([type isEqualToString:NBUFilterTypeGamma])
    {
        NSString * gamma = @"gamma";
        attributes = @{gamma : @{NBUFilterValueDescriptionKey : @"Gamma",
                                 NBUFilterValueTypeKey        : NBUFilterValueTypeFloat,
                                 NBUFilterDefaultValueKey     : @(0.8),
                                 NBUFilterIdentityValueKey    : @(1.0),
                                 NBUFilterMaximumValueKey     : @(3.0),
                                 NBUFilterMinimumValueKey     : @(0.0)}};
        block = ^(NBUFilter * filter,
                  GPUImageGammaFilter * gpuFilter)
        {
            // Get instance
            if (!gpuFilter)
            {
                gpuFilter = [GPUImageGammaFilter new];
            }
            
            // Configure it
            gpuFilter.gamma = [filter floatValueForKey:gamma];
            
            return gpuFilter;
        };
    }
    else if ([type isEqualToString:NBUFilterTypeMonochrome])
    {
        NSString * intensity    = @"intensity";
        NSString * red          = @"red";
        NSString * green        = @"green";
        NSString * blue         = @"blue";
        attributes = @{intensity    : @{NBUFilterValueDescriptionKey : @"Intensity",
                                        NBUFilterValueTypeKey        : NBUFilterValueTypeFloat,
                                        NBUFilterDefaultValueKey     : @(1.0),
                                        NBUFilterIdentityValueKey    : @(0.0),
                                        NBUFilterMaximumValueKey     : @(1.0),
                                        NBUFilterMinimumValueKey     : @(0.0)},
                       red          : @{NBUFilterValueDescriptionKey : @"Red",
                                        NBUFilterValueTypeKey        : NBUFilterValueTypeFloat,
                                        NBUFilterDefaultValueKey     : @(0.7),
                                        NBUFilterMaximumValueKey     : @(1.0),
                                        NBUFilterMinimumValueKey     : @(0.0)},
                       green        : @{NBUFilterValueDescriptionKey : @"Green",
                                        NBUFilterValueTypeKey        : NBUFilterValueTypeFloat,
                                        NBUFilterDefaultValueKey     : @(0.7),
                                        NBUFilterMaximumValueKey     : @(1.0),
                                        NBUFilterMinimumValueKey     : @(0.0)},
                       blue         : @{NBUFilterValueDescriptionKey : @"Blue",
                                        NBUFilterValueTypeKey        : NBUFilterValueTypeFloat,
                                        NBUFilterDefaultValueKey     : @(0.7),
                                        NBUFilterMaximumValueKey     : @(1.0),
                                        NBUFilterMinimumValueKey     : @(0.0)}};
        block = ^(NBUFilter * filter,
                  GPUImageMonochromeFilter * gpuFilter)
        {
            // Get instance
            if (!gpuFilter)
            {
                gpuFilter = [GPUImageMonochromeFilter new];
            }
            
            // Configure it
            gpuFilter.intensity  = [filter floatValueForKey:intensity];
            [gpuFilter setColorRed:[filter floatValueForKey:red]
                             green:[filter floatValueForKey:green]
                              blue:[filter floatValueForKey:blue]];
            
            return gpuFilter;
        };
    }
    else if ([type isEqualToString:NBUFilterTypeFisheye])
    {
        NSString * scale    = @"scale";
        NSString * radius   = @"radius";
        attributes = @{scale    : @{NBUFilterValueDescriptionKey : @"Scale",
                                    NBUFilterValueTypeKey        : NBUFilterValueTypeFloat,
                                    NBUFilterDefaultValueKey     : @(0.3),
                                    NBUFilterMaximumValueKey     : @(1.0),
                                    NBUFilterMinimumValueKey     : @(-1.0)},
                       radius   : @{NBUFilterValueDescriptionKey : @"Radius",
                                    NBUFilterValueTypeKey        : NBUFilterValueTypeFloat,
                                    NBUFilterDefaultValueKey     : @(0.65),
                                    NBUFilterIdentityValueKey    : @(0.0),
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
            gpuFilter.scale  = [filter floatValueForKey:scale];
            gpuFilter.radius = [filter floatValueForKey:radius];
            
            return gpuFilter;
        };
    }
    else if ([type isEqualToString:NBUFilterTypeMaskBlur])
    {
        NSString * alphaMask    = @"alphaMask";
        NSString * blurSize     = @"blurSize";
        attributes = @{alphaMask    : @{NBUFilterValueDescriptionKey : @"Alpha mask",
                                        NBUFilterValueTypeKey        : NBUFilterValueTypeImage,
                                        NBUFilterDefaultValueKey     : @"NBUKitResources.bundle/filters/frame.png"},
                       blurSize     : @{NBUFilterValueDescriptionKey : @"Blur size",
                                        NBUFilterValueTypeKey        : NBUFilterValueTypeFloat,
                                        NBUFilterDefaultValueKey     : @(1.0),
                                        NBUFilterIdentityValueKey    : @(0.0),
                                        NBUFilterMaximumValueKey     : @(3.0),
                                        NBUFilterMinimumValueKey     : @(0.0)}};
        block = ^(NBUFilter * filter,
                  NBUGPUMultiInputImageFilterGroup * gpuFilterGroup)
        {
            // Get instance
            if (!gpuFilterGroup)
            {
                // Create filters
                GPUImageGaussianBlurFilter * blurFilter = [GPUImageGaussianBlurFilter new];
                GPUImageTwoInputFilter * alphaMask = [[GPUImageTwoInputFilter alloc] initWithFragmentShaderFromString:kNBUAlphaMaskShaderString];
                GPUImageSourceOverBlendFilter * blendFilter = [GPUImageSourceOverBlendFilter new];
                
                // Connect filters
                [blurFilter addTarget:alphaMask atTextureLocation:0];
                [alphaMask addTarget:blendFilter atTextureLocation:1];
                
                // Configure the filter group
                gpuFilterGroup = [NBUGPUMultiInputImageFilterGroup new];
                [gpuFilterGroup addFilter:alphaMask];
                [gpuFilterGroup addFilter:blurFilter];
                [gpuFilterGroup addFilter:blendFilter];
                gpuFilterGroup.initialFilters = @[blurFilter, blendFilter];
                gpuFilterGroup.terminalFilter = blendFilter;
            }
            
            // Configure
            UIImage * mask = [filter imageForKey:alphaMask];
            [gpuFilterGroup setImage:mask
              forImagePictureAtIndex:0
             withTargetFilterAtIndex:0
                   atTextureLocation:1];
            GPUImageGaussianBlurFilter * blurFilter = (GPUImageGaussianBlurFilter *)[gpuFilterGroup filterAtIndex:1];
            blurFilter.blurSize = [filter floatValueForKey:blurSize];
            
            return gpuFilterGroup;
        };
    }
    else if ([type isEqualToString:NBUFilterTypeMultiplyBlend])
    {
        NSString * secondImage = @"secondImage";
        attributes = @{secondImage : @{NBUFilterValueDescriptionKey : @"Second image",
                                       NBUFilterValueTypeKey        : NBUFilterValueTypeImage,
                                       NBUFilterDefaultValueKey     : @"NBUKitResources.bundle/filters/mask.png"}};
        block = ^(NBUFilter * filter,
                  NBUGPUMultiInputImageFilterGroup * gpuFilterGroup)
        {
            // Get instance
            if (!gpuFilterGroup)
            {
                // Create filter
                GPUImageMultiplyBlendFilter * blendFilter = [GPUImageMultiplyBlendFilter new];
                
                // Configure the filter group
                gpuFilterGroup = [NBUGPUMultiInputImageFilterGroup new];
                [gpuFilterGroup addFilter:blendFilter];
                gpuFilterGroup.initialFilters = @[blendFilter];
                gpuFilterGroup.terminalFilter = blendFilter;
            }
            
            // Configure
            UIImage * overlay = [filter imageForKey:secondImage];
            [gpuFilterGroup setImage:overlay
              forImagePictureAtIndex:0
             withTargetFilterAtIndex:0
                   atTextureLocation:1];
            
            return gpuFilterGroup;
        };
    }
    else if ([type isEqualToString:NBUFilterTypeAdditiveBlend])
    {
        NSString * secondImage = @"secondImage";
        attributes = @{secondImage : @{NBUFilterValueDescriptionKey : @"Second image",
                                       NBUFilterValueTypeKey        : NBUFilterValueTypeImage,
                                       NBUFilterDefaultValueKey     : @"NBUKitResources.bundle/filters/frame.png"}};
        block = ^(NBUFilter * filter,
                  NBUGPUMultiInputImageFilterGroup * gpuFilterGroup)
        {
            // Get instance
            if (!gpuFilterGroup)
            {
                // Create filter
                GPUImageAddBlendFilter * blendFilter = [GPUImageAddBlendFilter new];
                
                // Configure the filter group
                gpuFilterGroup = [NBUGPUMultiInputImageFilterGroup new];
                [gpuFilterGroup addFilter:blendFilter];
                gpuFilterGroup.initialFilters = @[blendFilter];
                gpuFilterGroup.terminalFilter = blendFilter;
            }
            
            // Configure
            UIImage * overlay = [filter imageForKey:secondImage];
            [gpuFilterGroup setImage:overlay
              forImagePictureAtIndex:0
             withTargetFilterAtIndex:0
                   atTextureLocation:1];
            
            return gpuFilterGroup;
        };
    }
    else if ([type isEqualToString:NBUFilterTypeAlphaBlend])
    {
        NSString * secondImage  = @"secondImage";
        NSString * mix     = @"mix";
        attributes = @{secondImage  : @{NBUFilterValueDescriptionKey : @"Second image",
                                        NBUFilterValueTypeKey        : NBUFilterValueTypeImage,
                                        NBUFilterDefaultValueKey     : @"NBUKitResources.bundle/filters/frame.png"},
                       mix          : @{NBUFilterValueDescriptionKey : @"Mix",
                                        NBUFilterValueTypeKey        : NBUFilterValueTypeFloat,
                                        NBUFilterDefaultValueKey     : @(0.5),
                                        NBUFilterIdentityValueKey    : @(0.0),
                                        NBUFilterMaximumValueKey     : @(1.0),
                                        NBUFilterMinimumValueKey     : @(0.0)}};
        block = ^(NBUFilter * filter,
                  NBUGPUMultiInputImageFilterGroup * gpuFilterGroup)
        {
            // Get instance
            if (!gpuFilterGroup)
            {
                // Create filter
                GPUImageAlphaBlendFilter * blendFilter = [GPUImageAlphaBlendFilter new];
                
                // Configure the filter group
                gpuFilterGroup = [NBUGPUMultiInputImageFilterGroup new];
                [gpuFilterGroup addFilter:blendFilter];
                gpuFilterGroup.initialFilters = @[blendFilter];
                gpuFilterGroup.terminalFilter = blendFilter;
            }
            
            // Configure
            UIImage * overlay = [filter imageForKey:secondImage];
            [gpuFilterGroup setImage:overlay
              forImagePictureAtIndex:0
             withTargetFilterAtIndex:0
                   atTextureLocation:1];
            GPUImageAlphaBlendFilter * blendFilter = (GPUImageAlphaBlendFilter *)[gpuFilterGroup filterAtIndex:0];
            blendFilter.mix = [filter floatValueForKey:mix];
            
            return gpuFilterGroup;
        };
    }
    else if ([type isEqualToString:NBUFilterTypeSourceOver])
    {
        NSString * secondImage = @"secondImage";
        attributes = @{secondImage : @{NBUFilterValueDescriptionKey : @"Second image",
                                       NBUFilterValueTypeKey        : NBUFilterValueTypeImage,
                                       NBUFilterDefaultValueKey     : @"NBUKitResources.bundle/filters/frame.png"}};
        block = ^(NBUFilter * filter,
                  NBUGPUMultiInputImageFilterGroup * gpuFilterGroup)
        {
            // Get instance
            if (!gpuFilterGroup)
            {
                // Create filter
                GPUImageSourceOverBlendFilter * blendFilter = [GPUImageSourceOverBlendFilter new];
                
                // Configure the filter group
                gpuFilterGroup = [NBUGPUMultiInputImageFilterGroup new];
                [gpuFilterGroup addFilter:blendFilter];
                gpuFilterGroup.initialFilters = @[blendFilter];
                gpuFilterGroup.terminalFilter = blendFilter;
            }
            
            // Configure
            UIImage * overlay = [filter imageForKey:secondImage];
            [gpuFilterGroup setImage:overlay
              forImagePictureAtIndex:0
             withTargetFilterAtIndex:0
                   atTextureLocation:1];
            
            return gpuFilterGroup;
        };
    }
    else if ([type isEqualToString:NBUFilterTypeToneCurve])
    {
        NSString * curveFile = @"curveFile";
        attributes = @{curveFile : @{NBUFilterValueDescriptionKey : @"Tone curve file",
                                     NBUFilterValueTypeKey        : NBUFilterValueTypeFile,
                                     NBUFilterDefaultValueKey     : @"NBUKitResources.bundle/filters/sample.acv"}};
        block = ^(NBUFilter * filter,
                  GPUImageToneCurveFilter * gpuFilter)
        {
            // Get instance
            if (!gpuFilter)
            {
                gpuFilter = [GPUImageToneCurveFilter new];
            }
            
            // Configure it
            NSURL * fileURL = [filter fileURLForKey:curveFile];
            [gpuFilter setPointsWithACVURL:fileURL];
            
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

+ (UIImage *)applyFilters:(NSArray *)filters
                  toImage:(UIImage *)image
{
    if (!filters.count)
        return image;
    
    NBULogInfo(@"%@ %@ %@", THIS_METHOD, filters, NSStringFromCGSize(image.size));
    
    // Create a pipeline
    GPUImagePicture * input = [[GPUImagePicture alloc] initWithImage:image
                                                 smoothlyScaleOutput:NO];
    GPUImageOutput * output = input;
    
    GPUImageFilter * gpuFilter;
    for (NBUFilter * filter in filters)
    {
        // Skip disabled filters
        if (!filter.enabled)
            continue;
        
        // Get the configured GPUImageFilter
        gpuFilter = filter.concreteFilter;
        
        // Connect
        [output removeAllTargets];
        [output addTarget:gpuFilter atTextureLocation:0];
        
        // Move on
        output = gpuFilter;
    }
    
    // Nothing to process?
    if (input == output)
        return image;
    
    // Process input
    [input processImage];
    
    // Process output
    UIImage * outputImage = [output imageFromCurrentlyProcessedOutputWithOrientation:image.imageOrientation];
    
    // Clean input
    [input removeAllTargets];
    
    return outputImage;
}

@end


@implementation NBUGPUMultiInputImageFilterGroup
{
    NSMutableArray * _otherImagePictures;
}

- (NSArray *)otherImagePictures
{
    return _otherImagePictures;
}

- (void)        setImage:(UIImage *)image
  forImagePictureAtIndex:(NSUInteger)index
 withTargetFilterAtIndex:(NSUInteger)targetIndex
       atTextureLocation:(NSInteger)textureLocation
{
    if (!_otherImagePictures)
    {
        _otherImagePictures = [NSMutableArray array];
    }
    
    // Clean replaced image picture
    if (index < _otherImagePictures.count)
    {
        [(GPUImagePicture *)_otherImagePictures[index] removeAllTargets];
    }
    
    // Create and configure new image picture
    GPUImagePicture * imagePicture = [[GPUImagePicture alloc] initWithImage:image
                                                        smoothlyScaleOutput:YES];
    [imagePicture addTarget:[self filterAtIndex:targetIndex]
          atTextureLocation:textureLocation];
    [imagePicture processImage];
    
    // Register new image picture
    _otherImagePictures[index] = imagePicture;
}

- (void)prepareForImageCapture
{
    // Process images
    for (GPUImagePicture * imagePicture in _otherImagePictures)
    {
        [imagePicture processImage];
    }
    
    [super prepareForImageCapture];
}

@end

