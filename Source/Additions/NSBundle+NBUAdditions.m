//
//  NSBundle+NBUAdditions.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/08/13.
//  Copyright (c) 2012-2014 CyberAgent Inc.
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

#import "NSBundle+NBUAdditions.h"
#import "NBUKitPrivate.h"

NSString * const NBULocalizedStringNotFound = @"NBULocalizedStringNotFound";

@implementation NSBundle (NBUAdditions)

+ (NSString *)pathForResource:(NSString *)name
                       ofType:(NSString *)extension
{
    // First try with the main bundle
    NSBundle * mainBundle = [NSBundle mainBundle];
    NSString * path = [mainBundle pathForResource:name
                                           ofType:extension];
    if (path)
        return path;
    
    // Otherwise try with other bundles
    NSBundle * bundle;
    for (NSString * bundlePath in [mainBundle pathsForResourcesOfType:@"bundle"
                                                          inDirectory:nil])
    {
        bundle = [NSBundle bundleWithPath:bundlePath];
        path = [bundle pathForResource:name
                                ofType:extension];
        if (path)
            return path;
    }
    
    NBULogInfo(@"No path found for: %@ (.%@)", name, extension);
    return nil;
}

+ (UIImage *)imageNamed:(NSString *)name
{
    // First try with the main bundle
    UIImage * image = [UIImage imageNamed:name];
    
    if (image)
        return image;
    
    // Otherwise try with other bundles
    for (NSString * bundlePath in [[NSBundle mainBundle] pathsForResourcesOfType:@"bundle"
                                                                     inDirectory:nil])
    {
        image = [UIImage imageNamed:[NSString stringWithFormat:@"%@/%@", bundlePath.lastPathComponent, name]];
        
        if (image)
            return image;
    }
    
    NBULogWarn(@"No image found for name: %@", name);
    return nil;
}

+ (NSArray *)loadNibNamed:(NSString *)name
                    owner:(id)owner
                  options:(NSDictionary *)options
{
    // First try with the main bundle
    NSBundle * mainBundle = [NSBundle mainBundle];
    if ([mainBundle pathForResource:name
                             ofType:@"nib"])
    {
        NBULogVerbose(@"Loading Nib named: '%@' from mainBundle...", name);
        return [mainBundle loadNibNamed:name
                                  owner:owner
                                options:options];
    }
    
    // Otherwise try with other bundles
    NSBundle * bundle;
    for (NSString * bundlePath in [mainBundle pathsForResourcesOfType:@"bundle"
                                                          inDirectory:nil])
    {
        bundle = [NSBundle bundleWithPath:bundlePath];
        if ([bundle pathForResource:name
                             ofType:@"nib"])
        {
            NBULogVerbose(@"Loading Nib named: '%@' from bundle: '%@'...", name, bundle.bundleIdentifier);
            return [bundle loadNibNamed:name
                                  owner:owner
                                options:options];
        }
    }
    
    NBULogError(@"Couldn't load Nib named: %@", name);
    return nil;
}

+ (NSString *)localizedStringForKey:(NSString *)key
                              value:(NSString *)value
                              table:(NSString *)tableName
                       backupBundle:(NSBundle *)bundle
{
    // First try main bundle
    NSString * string = [[NSBundle mainBundle] localizedStringForKey:key
                                                               value:NBULocalizedStringNotFound
                                                               table:tableName];
    
    // Then try the backup bundle
    if ([string isEqualToString:NBULocalizedStringNotFound])
    {
        string = [bundle localizedStringForKey:key
                                         value:NBULocalizedStringNotFound
                                         table:tableName];
    }
    
    // Still not found?
    if ([string isEqualToString:NBULocalizedStringNotFound])
    {
        string = value.length > 0 ? value : key;
        
        NBULogWarn(@"No localized string for '%@' in '%@', will use '%@'", key, tableName, string);
    }
    
    return string;
}

@end

