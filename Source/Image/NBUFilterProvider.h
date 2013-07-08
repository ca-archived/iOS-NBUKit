//
//  NBUFilterProvider.h
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

@class NBUFilter;

/// Predefined filter types
extern NSString * const NBUFilterTypeNone;
extern NSString * const NBUFilterTypeContrast;
extern NSString * const NBUFilterTypeBrightness;
extern NSString * const NBUFilterTypeSaturation;
extern NSString * const NBUFilterTypeExposure;
extern NSString * const NBUFilterTypeSharpen;
extern NSString * const NBUFilterTypeGamma;
extern NSString * const NBUFilterTypeAuto;
extern NSString * const NBUFilterTypeMonochrome;
extern NSString * const NBUFilterTypeMultiplyBlend;
extern NSString * const NBUFilterTypeAdditiveBlend;
extern NSString * const NBUFilterTypeAlphaBlend;
extern NSString * const NBUFilterTypeSourceOver;
extern NSString * const NBUFilterTypeACV;
extern NSString * const NBUFilterTypeFisheye;
extern NSString * const NBUFilterTypeMaskBlur;
extern NSString * const NBUFilterTypeGroup;

/**
 Protocol to be adopted by filter library wrappers.
 
 For each new library of filters a NBUFilterProvider compliant class should be created
 (i.e. NBUCoreImageFilterProvider, NBUGPUImageFilterProvider).
 */
@protocol NBUFilterProvider <NSObject>

/// Each filter must be a NSMutableDictionary with the keys above
+ (NSArray *)availableFilterTypes;

/// Create a new NBUFilter of a given type, optionally setting a given name and initial values.
/// @param name An optional filter name. When not set a localized default name will be used.
/// @param type The desired filter type.
/// @param values The optional initial values.
+ (NBUFilter *)filterWithName:(NSString *)name
                         type:(NSString *)type
                       values:(NSArray *)values;

/// Apply filters to an image.
/// @param filters An array of NBUFilter objects to be applied sequentially.
/// @param image The source image.
/// @return A new image with the filters applied to.
+ (UIImage *)applyFilters:(NSArray *)filters
                  toImage:(UIImage *)image;

@end

/**
 The main filter provider wrapping class.
 
 This class will handles filters from different providers and applies them to images.
 */
@interface NBUFilterProvider : NSObject <NBUFilterProvider>

/// Register a custom NBUFilterProvider.
/// @param provider The custom provider's class.
+ (void)addProvider:(Class<NBUFilterProvider>)provider;

/// Retrieve the localized name for a given filter type.
/// @param type The target filter type.
+ (NSString *)localizedNameForFilterWithType:(NSString *)type;

/// Get ready to use instances of each filter from all registered providers.
+ (NSArray *)availableFilters;

@end

