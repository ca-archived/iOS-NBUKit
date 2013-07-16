//
//  NBUFilter.m
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

#import "NBUFilter.h"
#import "NBUKitPrivate.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_IMAGE

// Attributes' keys
NSString * const NBUFilterValueDescriptionKey   = @"description";
NSString * const NBUFilterValueTypeKey          = @"valueType";
NSString * const NBUFilterDefaultValueKey       = @"defaultValue";
NSString * const NBUFilterIdentityValueKey      = @"identityValue";
NSString * const NBUFilterMinimumValueKey       = @"minValue";
NSString * const NBUFilterMaximumValueKey       = @"maxValue";

// Types
NSString * const NBUFilterValueTypeFloat        = @"float";
NSString * const NBUFilterValueTypeBool         = @"bool";
NSString * const NBUFilterValueTypeImage        = @"pathOrImage";
NSString * const NBUFilterValueTypeFile         = @"path";
NSString * const NBUFilterValueTypeUnknown      = @"unknown";

@implementation NBUFilter
{
    NBUConfigureFilterBlock _configureFilterBlock;
}

@dynamic configurationDictionary;
@synthesize name = _name;
@synthesize type = _type;
@synthesize enabled = _enabled;
@synthesize values = _values;
@synthesize attributes = _attributes;
@synthesize provider = _provider;
@synthesize concreteFilter = _concreteFilter;

+ (id)filterWithName:(NSString *)name
                type:(NSString *)type
              values:(NSDictionary *)values
          attributes:(NSDictionary *)attributes
            provider:(Class<NBUFilterProvider>)provider
configureFilterBlock:(NBUConfigureFilterBlock)block
{
    return [[self alloc] initWithName:name
                                 type:type
                               values:values
                           attributes:attributes
                             provider:provider
                 configureFilterBlock:block];
}



- (id)initWithName:(NSString *)name
              type:(NSString *)type
            values:(NSDictionary *)values
        attributes:(NSDictionary *)attributes
          provider:(Class<NBUFilterProvider>)provider
configureFilterBlock:(NBUConfigureFilterBlock)block
{
    self = [super init];
    if (self)
    {
        _enabled = YES;
        _name = name ? name : [[type
                                stringByReplacingOccurrencesOfString:@"NBUFilterType"
                                withString:@""]
                               stringByReplacingOccurrencesOfString:@"FilterType"
                               withString:@""];
        _type = type;
        _values = [values isKindOfClass:[NSMutableDictionary class]] ? values : [NSMutableDictionary dictionaryWithDictionary:values];
        _attributes = attributes;
        _provider = provider;
        _configureFilterBlock = block;
    }
    return self;
}

//- (NSMutableDictionary *)values
//{
//    // Enough values?
//    if (_values.count >= _defaultValues.count)
//    {
//        // Too many, some will be ignored
//        if (_values.count > _defaultValues.count)
//        {
//            NBULogWarn(@"The last %d values () will be ignored by filter %@",
//                       _values.count - _defaultValues.count, self);
//        }
//        return _values;
//    }
//    
//    // No values at all?
//    if (_values.count == 0)
//    {
//        return _defaultValues;
//    }
//    
//    // A mix of values
//    NSRange defaultValuesRange = NSMakeRange(_values.count,
//                                             _defaultValues.count - _values.count);
//    NSArray * values = [_values arrayByAddingObjectsFromArray:[_defaultValues subarrayWithRange:defaultValuesRange]];
//    return values;
//}

- (void)reset
{
    [_values removeAllObjects];
}

- (id)concreteFilter
{
    // Create/configure
//    _concreteFilter = _configureFilterBlock(self, _concreteFilter);
    _concreteFilter = _configureFilterBlock(self, nil);
    
    return _concreteFilter;
}

- (NSString *)description
{
    if (_enabled)
    {
        return [NSString stringWithFormat:
                @"<%@ %p: %@ (%@ - %@)\n  values: %@\n  attributes:%@>",
                [self class], self, _name, _type, _provider,
                _values,
                [[_attributes.description  stringByReplacingOccurrencesOfString:@"\n"
                                                                     withString:@""] stringByReplacingOccurrencesOfString:@"  "
                 withString:@""]];
    }
    else
    {
        return [NSString stringWithFormat:
                @"<%@ %p: %@ (%@ - %@) [disabled]>",
                [self class], self, _name, _type, _provider];
    }
}

- (id)effectiveValueForKey:(NSString *)valueKey
{
    id value = _values[valueKey];
    return value ? value : _attributes[valueKey][NBUFilterDefaultValueKey];
}

#pragma mark - Serialization

- (void)setConfigurationDictionary:(NSDictionary *)configurationDictionary
{
    if (configurationDictionary[@"name"])
    {
        _name = configurationDictionary[@"name"];
    }
    if (configurationDictionary[@"values"])
    {
        _values = configurationDictionary[@"values"];
    }
    if (configurationDictionary[@"enabled"])
    {
        _enabled = [configurationDictionary[@"enabled"] boolValue];
    }
}

- (NSDictionary *)configurationDictionary
{
    return @{@"name"    : _name ? _name : @"",
             @"type"    : _type,
             @"values"  : self.values ? self.values : @[],
             @"enabled" : @(_enabled)};
}

#pragma mark - Float values

- (CGFloat)floatValueForKey:(NSString *)valueKey
{
    return [[self effectiveValueForKey:valueKey] floatValue];
}

- (CGFloat)maxFloatValueForKey:(NSString *)valueKey
{
    return [_attributes[valueKey][NBUFilterMaximumValueKey] floatValue];
}

- (CGFloat)minFloatValueForKey:(NSString *)valueKey
{
    return [_attributes[valueKey][NBUFilterMinimumValueKey] floatValue];
}

#pragma mark - Booleans

- (BOOL)boolValueForKey:(NSString *)valueKey
{
    return [[self effectiveValueForKey:valueKey] boolValue];
}

#pragma mark - File URLs

- (NSURL *)fileURLForKey:(NSString *)valueKey
{
    id pathOrURL = [self effectiveValueForKey:valueKey];
    
    // Already an NSURL?
    if ([pathOrURL isKindOfClass:[NSURL class]])
    {
        return pathOrURL;
    }
    
    // First try inside the bundle
    NSString * path = pathOrURL;
    NSURL * fileURL = [[NSBundle mainBundle].bundleURL URLByAppendingPathComponent:path];
    
    // Else assume absolute path
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileURL.path])
    {
        fileURL = [NSURL fileURLWithPath:path];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileURL.path])
    {
        NBULogError(@"Couldn't determine fileURL for '%@'", path);
    }
    return fileURL;
}

#pragma mark - Images

- (UIImage *)imageForKey:(NSString *)valueKey
{
    id imageOrPath = [self effectiveValueForKey:valueKey];
    
    // Already an image?
    if ([imageOrPath isKindOfClass:[UIImage class]])
    {
        return imageOrPath;
    }
    
    // Try to load the image
    UIImage * image = [UIImage imageNamed:imageOrPath];
    if (!image)
    {
        image = [UIImage imageWithContentsOfFile:[self fileURLForKey:valueKey].path];
    }
    if (!image)
    {
        NBULogError(@"Couldn't load image for %@", imageOrPath);
    }
    return image;
}

@end

