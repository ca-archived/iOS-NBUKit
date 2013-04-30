//
//  NBUFilter.h
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/08/16.
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
@protocol NBUFilterProvider;

/// Predefined attribute dictionary keys
extern NSString * const NBUFilterValuesDescriptionKey;
extern NSString * const NBUFilterValuesTypeKey;
extern NSString * const NBUFilterMinValuesKey;
extern NSString * const NBUFilterMaxValuesKey;

/// Value types
extern NSString * const NBUFilterValuesTypeFloat;
extern NSString * const NBUFilterValuesTypeBool;
extern NSString * const NBUFilterValuesTypeImage;
extern NSString * const NBUFilterValuesTypeFile;
extern NSString * const NBUFilterValuesTypeUnknown;

/// Concrete filter block
typedef id (^NBUConfigureFilterBlock)(NBUFilter * filter, id concreteFilter);

/**
 An abstract filter object.
 
 Abstracts the underlying filter library to have a uniform way of using filters.
 @note Will be refactored soon.
 */
@interface NBUFilter : NSObject

/// @name Creating a filter

/// Create a new NBUFilter of a given type, optionally setting a given name and initial values.
/// @param name An optional filter name.
/// @param type The desired filter type.
/// @param values The optional initial values.
/// @param defaultValues The default filter values.
/// @param identityValues The filter values that don't modify the input.
/// @param attributes A dictionary describing in more detail the input values range, type, etc.
/// @param provider The associated NBUFilterProvider capable of handling the filter.
/// @param block The block to be called to retrieve a configured concreteFilter.
/// @note Prefer NBUFilterProvider methods.
+ (id)filterWithName:(NSString *)name
                type:(NSString *)type
              values:(NSArray *)values
       defaultValues:(NSArray *)defaultValues
      identityValues:(NSArray *)identityValues
          attributes:(NSDictionary *)attributes
            provider:(Class<NBUFilterProvider>)provider
configureFilterBlock:(NBUConfigureFilterBlock)block;

/// @name Configuring the Filter

/// A customizable filter name.
@property (nonatomic, strong)           NSString * name;

/// Whether or not the filter is enabled.
@property (nonatomic, getter=isEnabled) BOOL enabled;

/// The current filter values.
@property (nonatomic, strong)           NSArray * values;

/// Set a value for given values index.
/// @param value The value to set.
/// @param index The corresponding value index.
- (void)setValue:(id)value
        forIndex:(NSUInteger)index;

/// Reset the values by setting it to `nil`.
- (void)reset;

/// @name Read-only Properties

/// The filter type (ex. NBUFilterTypeBrightness).
@property (nonatomic, readonly)         NSString * type;

/// The default flter values.
@property (nonatomic, readonly)         NSArray * defaultValues;

/// The values that don't modify the input.
@property (nonatomic, readonly)         NSArray * identityValues;

/// A complete description of the filter.
@property (nonatomic, readonly)         NSDictionary * attributes;

/// @name Convenience Methods for Retrieving Values

/// Get a value as a float number.
/// @param index A values' index.
- (CGFloat)floatValueForIndex:(NSUInteger)index;

/// Get the maximum float value for a given index.
/// @param index A values' index.
- (CGFloat)maxFloatValueForIndex:(NSUInteger)index;

/// Get the minimum float value for a given index.
/// @param index A values' index.
- (CGFloat)minFloatValueForIndex:(NSUInteger)index;

/// Get a value as a boolean number.
/// @param index A values' index.
- (BOOL)boolValueForIndex:(NSUInteger)index;

/// Get a value as a file URL number.
/// @param index A values' index.
- (NSURL *)fileURLForIndex:(NSUInteger)index;

/// Get an UIImage from a given value.
/// @param index A values' index.
- (UIImage *)imageForIndex:(NSUInteger)index;

/// @name Using the Concrete Filter

/// The filter concrete provider.
/// @see NBUFilterProvider, NBUCoreImageFilterProvider, NBUGPUImageFilterProvider.
@property (nonatomic, readonly)     Class<NBUFilterProvider> provider;

/// The underlying concrete filter provided by the provider object.
@property (nonatomic, readonly)     id concreteFilter;

/// @name Converting To/From Dictionaries

/// A Plist-compatible dictionary respresentation of the filter.
@property (strong, nonatomic)       NSDictionary * configurationDictionary;

@end

