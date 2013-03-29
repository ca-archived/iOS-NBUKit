//
//  NBUGPUImageFilterProvider.m
//  NBUKit
//
//  Created by エルネスト 利辺羅 on 12/05/03.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import "NBUGPUImageFilterProvider.h"
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
             NBUFilterTypeACV,
             NBUFilterTypeFisheye,
             NBUFilterTypeMaskBlur
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
    
    if ([type isEqualToString:NBUFilterTypeContrast])
    {
        defaultValues                                   = @[@(1.2)];
        identityValues                                  = @[@(1.0)];
        attributes = @{NBUFilterValuesDescriptionKey    : @[@"Contrast"],
                       NBUFilterValuesTypeKey           : @[NBUFilterValuesTypeFloat],
                       NBUFilterMaxValuesKey            : @[@(4.0)],
                       NBUFilterMinValuesKey            : @[@(0.0)]};
        block = ^(NBUFilter * filter,
                  GPUImageContrastFilter * gpuFilter)
        {
            // Get instance
            if (!gpuFilter)
            {
                gpuFilter = [GPUImageContrastFilter new];
            }
            
            // Configure it
            gpuFilter.contrast = [filter floatValueForIndex:0];
            
            return gpuFilter;
        };
    }
    else if ([type isEqualToString:NBUFilterTypeBrightness])
    {
        defaultValues                                   = @[@(0.1)];
        identityValues                                  = @[@(0.0)];
        attributes = @{NBUFilterValuesDescriptionKey    : @[@"Brightness"],
                       NBUFilterValuesTypeKey           : @[NBUFilterValuesTypeFloat],
                       NBUFilterMaxValuesKey            : @[@(1.0)],
                       NBUFilterMinValuesKey            : @[@(-1.0)]};
        block = ^(NBUFilter * filter,
                  GPUImageBrightnessFilter * gpuFilter)
        {
            // Get instance
            if (!gpuFilter)
            {
                gpuFilter = [GPUImageBrightnessFilter new];
            }
            
            // Configure it
            gpuFilter.brightness = [filter floatValueForIndex:0];
            
            return gpuFilter;
        };
    }
    else if ([type isEqualToString:NBUFilterTypeSaturation])
    {
        defaultValues                                   = @[@(1.3)];
        identityValues                                  = @[@(1.0)];
        attributes = @{NBUFilterValuesDescriptionKey    : @[@"Saturation"],
                       NBUFilterValuesTypeKey           : @[NBUFilterValuesTypeFloat],
                       NBUFilterMaxValuesKey            : @[@(2.0)],
                       NBUFilterMinValuesKey            : @[@(0.0)]};
        block = ^(NBUFilter * filter,
                  GPUImageSaturationFilter * gpuFilter)
        {
            // Get instance
            if (!gpuFilter)
            {
                gpuFilter = [GPUImageSaturationFilter new];
            }
            
            // Configure it
            gpuFilter.saturation = [filter floatValueForIndex:0];
            
            return gpuFilter;
        };
    }
    else if ([type isEqualToString:NBUFilterTypeExposure])
    {
        defaultValues                                   = @[@(0.2)];
        identityValues                                  = @[@(0.0)];
        attributes = @{NBUFilterValuesDescriptionKey    : @[@"Exposure"],
                       NBUFilterValuesTypeKey           : @[NBUFilterValuesTypeFloat],
                       NBUFilterMaxValuesKey            : @[@(10.0)],
                       NBUFilterMinValuesKey            : @[@(-10.0)]};
        block = ^(NBUFilter * filter,
                  GPUImageExposureFilter * gpuFilter)
        {
            // Get instance
            if (!gpuFilter)
            {
                gpuFilter = [GPUImageExposureFilter new];
            }
            
            // Configure it
            gpuFilter.exposure = [filter floatValueForIndex:0];
            
            return gpuFilter;
        };
    }
    else if ([type isEqualToString:NBUFilterTypeSharpen])
    {
        defaultValues                                   = @[@(0.5)];
        identityValues                                  = @[@(0.0)];
        attributes = @{NBUFilterValuesDescriptionKey    : @[@"Sharpness"],
                       NBUFilterValuesTypeKey           : @[NBUFilterValuesTypeFloat],
                       NBUFilterMaxValuesKey            : @[@(4.0)],
                       NBUFilterMinValuesKey            : @[@(-4.0)]};
        block = ^(NBUFilter * filter,
                  GPUImageSharpenFilter * gpuFilter)
        {
            // Get instance
            if (!gpuFilter)
            {
                gpuFilter = [GPUImageSharpenFilter new];
            }
            
            // Configure it
            gpuFilter.sharpness = [filter floatValueForIndex:0];
            
            return gpuFilter;
        };
    }
    else if ([type isEqualToString:NBUFilterTypeGamma])
    {
        defaultValues                                   = @[@(0.8)];
        identityValues                                  = @[@(1.0)];
        attributes = @{NBUFilterValuesDescriptionKey    : @[@"Gamma"],
                       NBUFilterValuesTypeKey           : @[NBUFilterValuesTypeFloat],
                       NBUFilterMaxValuesKey            : @[@(3.0)],
                       NBUFilterMinValuesKey            : @[@(0.0)]};
        block = ^(NBUFilter * filter,
                  GPUImageGammaFilter * gpuFilter)
        {
            // Get instance
            if (!gpuFilter)
            {
                gpuFilter = [GPUImageGammaFilter new];
            }
            
            // Configure it
            gpuFilter.gamma = [filter floatValueForIndex:0];
            
            return gpuFilter;
        };
    }
    else if ([type isEqualToString:NBUFilterTypeMonochrome])
    {
        defaultValues                                   = @[@(1.0), @(0.7), @(0.7), @(0.7)];
        identityValues                                  = @[@(0.0), [NSNull null], [NSNull null], [NSNull null]];
        attributes = @{NBUFilterValuesDescriptionKey    : @[@"Intensity",
                                                            @"Red",
                                                            @"Green",
                                                            @"Blue"],
                       NBUFilterValuesTypeKey           : @[NBUFilterValuesTypeFloat,
                                                            NBUFilterValuesTypeFloat,
                                                            NBUFilterValuesTypeFloat,
                                                            NBUFilterValuesTypeFloat],
                       NBUFilterMaxValuesKey            : @[@(1.0), @(1.0), @(1.0), @(1.0)],
                       NBUFilterMinValuesKey            : @[@(0.0), @(0.0), @(0.0), @(0.0)]};
        block = ^(NBUFilter * filter,
                  GPUImageMonochromeFilter * gpuFilter)
        {
            // Get instance
            if (!gpuFilter)
            {
                gpuFilter = [GPUImageMonochromeFilter new];
            }
            
            // Configure it
            gpuFilter.intensity = [filter floatValueForIndex:0];
            [gpuFilter setColorRed:[filter floatValueForIndex:1]
                             green:[filter floatValueForIndex:2]
                              blue:[filter floatValueForIndex:3]];
            
            return gpuFilter;
        };
    }
    else if ([type isEqualToString:NBUFilterTypeFisheye])
    {
        defaultValues                                   = @[@(0.3), @(0.65)];
        identityValues                                  = @[[NSNull null], @(0.0)];
        attributes = @{NBUFilterValuesDescriptionKey    : @[@"Scale",
                                                            @"Radius"],
                       NBUFilterValuesTypeKey           : @[NBUFilterValuesTypeFloat,
                                                            NBUFilterValuesTypeFloat],
                       NBUFilterMaxValuesKey            : @[@(1.0), @(1.0)],
                       NBUFilterMinValuesKey            : @[@(-1.0), @(0.0)]};
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
            
            return gpuFilter;
        };
    }
    else if ([type isEqualToString:NBUFilterTypeMaskBlur])
    {
        defaultValues                           = @[@"NBUKitResources.bundle/Filters/frame.png", @(1.0)];
        identityValues                          = @[@""];
        attributes                              = @{NBUFilterValuesDescriptionKey   : @[@"Alpha mask",
                                                                                        @"Blur size"],
                                                    NBUFilterValuesTypeKey          : @[NBUFilterValuesTypeImage,
                                                                                        NBUFilterValuesTypeFloat],
                                                    NBUFilterMaxValuesKey           : @[[NSNull null], @(3.0)],
                                                    NBUFilterMinValuesKey           : @[[NSNull null], @(0.0)]};
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
            UIImage * mask = [filter imageForIndex:0];
            [gpuFilterGroup setImage:mask
              forImagePictureAtIndex:0
             withTargetFilterAtIndex:0
                   atTextureLocation:1];
            GPUImageGaussianBlurFilter * blurFilter = (GPUImageGaussianBlurFilter *)[gpuFilterGroup filterAtIndex:1];
            blurFilter.blurSize = [filter floatValueForIndex:1];
            
            return gpuFilterGroup;
        };
    }
    else if ([type isEqualToString:NBUFilterTypeMultiplyBlend])
    {
        defaultValues                           = @[@"NBUKitResources.bundle/Filters/mask.png"];
        identityValues                          = @[@""];
        attributes                              = @{NBUFilterValuesDescriptionKey   : @[@"Second image"],
                                                    NBUFilterValuesTypeKey          : @[NBUFilterValuesTypeImage]};
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
            UIImage * overlay = [filter imageForIndex:0];
            [gpuFilterGroup setImage:overlay
              forImagePictureAtIndex:0
             withTargetFilterAtIndex:0
                   atTextureLocation:1];
            
            return gpuFilterGroup;
        };
    }
    else if ([type isEqualToString:NBUFilterTypeAdditiveBlend])
    {
        defaultValues                           = @[@"NBUKitResources.bundle/Filters/frame.png"];
        identityValues                          = @[@""];
        attributes                              = @{NBUFilterValuesDescriptionKey   : @[@"Second image"],
                                                    NBUFilterValuesTypeKey          : @[NBUFilterValuesTypeImage]};
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
            UIImage * overlay = [filter imageForIndex:0];
            [gpuFilterGroup setImage:overlay
              forImagePictureAtIndex:0
             withTargetFilterAtIndex:0
                   atTextureLocation:1];
            
            return gpuFilterGroup;
        };
    }
    else if ([type isEqualToString:NBUFilterTypeAlphaBlend])
    {
        defaultValues                           = @[@"NBUKitResources.bundle/Filters/frame.png", @(0.5)];
        identityValues                          = nil;
        attributes                              = @{NBUFilterValuesDescriptionKey   : @[@"Second image",
                                                                                        @"Mix"],
                                                    NBUFilterValuesTypeKey          : @[NBUFilterValuesTypeImage,
                                                                                        NBUFilterValuesTypeFloat],
                                                    NBUFilterMaxValuesKey           : @[[NSNull null], @(1.0)],
                                                    NBUFilterMinValuesKey           : @[[NSNull null], @(0.0)]};
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
            UIImage * overlay = [filter imageForIndex:0];
            [gpuFilterGroup setImage:overlay
              forImagePictureAtIndex:0
             withTargetFilterAtIndex:0
                   atTextureLocation:1];
            GPUImageAlphaBlendFilter * blendFilter = (GPUImageAlphaBlendFilter *)[gpuFilterGroup filterAtIndex:0];
            blendFilter.mix = [filter floatValueForIndex:1];
            
            return gpuFilterGroup;
        };
    }
    else if ([type isEqualToString:NBUFilterTypeSourceOver])
    {
        defaultValues                           = @[@"NBUKitResources.bundle/Filters/frame.png"];
        identityValues                          = @[@""];
        attributes                              = @{NBUFilterValuesDescriptionKey   : @[@"Second image"],
                                                    NBUFilterValuesTypeKey          : @[NBUFilterValuesTypeImage]};
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
            UIImage * overlay = [filter imageForIndex:0];
            [gpuFilterGroup setImage:overlay
              forImagePictureAtIndex:0
             withTargetFilterAtIndex:0
                   atTextureLocation:1];
            
            return gpuFilterGroup;
        };
    }
    else if ([type isEqualToString:NBUFilterTypeACV])
    {
        defaultValues                           = @[@"NBUKitResources.bundle/Filters/sample.acv"];
        identityValues                          = @[@""];
        attributes                              = @{NBUFilterValuesDescriptionKey   : @[@"ACV file"],
                                                    NBUFilterValuesTypeKey          : @[NBUFilterValuesTypeFile]};
        block = ^(NBUFilter * filter,
                  GPUImageToneCurveFilter * gpuFilter)
        {
            // Get instance
            if (!gpuFilter)
            {
                gpuFilter = [GPUImageToneCurveFilter new];
            }
            
            // Configure it
            NSURL * fileURL = [filter fileURLForIndex:0];
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
                                     defaultValues:defaultValues
                                    identityValues:identityValues
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

- (void)setImage:(UIImage *)image
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

