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
extern NSString * const NBUFilterValueDescriptionKey;
extern NSString * const NBUFilterValueTypeKey;
extern NSString * const NBUFilterDefaultValueKey;       // Value set when the filter is created.
extern NSString * const NBUFilterIdentityValueKey;      // Value that when set filter is disabled.
extern NSString * const NBUFilterMinimumValueKey;
extern NSString * const NBUFilterMaximumValueKey;

/// Value types
extern NSString * const NBUFilterValueTypeFloat;
extern NSString * const NBUFilterValueTypeBool;
extern NSString * const NBUFilterValueTypeImage;
extern NSString * const NBUFilterValueTypeFile;
extern NSString * const NBUFilterValueTypeUnknown;

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
/// @param attributes A dictionary describing in more detail the input values range, type, etc.
/// @param provider The associated NBUFilterProvider capable of handling the filter.
/// @param block The block to be called to retrieve a configured concreteFilter.
/// @note Prefer NBUFilterProvider methods.
+ (id)filterWithName:(NSString *)name
                type:(NSString *)type
              values:(NSDictionary *)values
          attributes:(NSDictionary *)attributes
            provider:(Class<NBUFilterProvider>)provider
configureFilterBlock:(NBUConfigureFilterBlock)block;

/// @name Configuring the Filter

/// A customizable filter name.
@property (nonatomic, strong)           NSString * name;

/// Whether or not the filter is enabled.
@property (nonatomic, getter=isEnabled) BOOL enabled;

/// The current filter values.
/// @discussion When not set default values specified in the attributes dictionary will be used.
@property (nonatomic, strong, readonly) NSMutableDictionary * values;

/// Reset the values clearing them.
- (void)reset;

/// @name Read-only Properties

/// The filter type (ex. NBUFilterTypeBrightness).
@property (nonatomic, readonly)         NSString * type;

/// A complete description of the filter.
@property (nonatomic, readonly)         NSDictionary * attributes;

/// @name Convenience Methods for Retrieving Values

/// Return the value for a given key from either values or attributes' default values.
/// @param valueKey The value's key.
- (id)effectiveValueForKey:(NSString *)valueKey;

/// Get a value as a float number.
/// @param valueKey The value's key.
- (CGFloat)floatValueForKey:(NSString *)valueKey;

/// Get the maximum float value for a given value key.
/// @param valueKey The value's key.
- (CGFloat)maxFloatValueForKey:(NSString *)valueKey;

/// Get the minimum float value for a given value key.
/// @param valueKey The value's key.
- (CGFloat)minFloatValueForKey:(NSString *)valueKey;

/// Get a value as a boolean number.
/// @param valueKey The value's key.
- (BOOL)boolValueForKey:(NSString *)valueKey;

/// Get a value as a file URL number.
/// @param valueKey The value's key.
- (NSURL *)fileURLForKey:(NSString *)valueKey;

/// Get an UIImage from a given value.
/// @param valueKey The value's key.
- (UIImage *)imageForKey:(NSString *)valueKey;

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

