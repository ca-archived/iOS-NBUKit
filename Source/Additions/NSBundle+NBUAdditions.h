//
//  NSBundle+NBUAdditions.h
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

extern NSString * const NBULocalizedStringNotFound;

/**
 NSBundle category to handle subbundles.
 */
@interface NSBundle (NBUAdditions)

/// Search for a resource first in the main bundle and then in its subbundles.
/// @param name The name of the resource.
/// @param extension The resource's extension.
+ (NSString *)pathForResource:(NSString *)name
                       ofType:(NSString *)extension;

/// Load an image trying first on the main bundle and then on its subbundles.
/// @param name The name of the image.
+ (UIImage *)imageNamed:(NSString *)name;

/// Load a Nib file trying first with the main bundle and then its subbundles.
/// @param name The name of the Nib file.
/// @param owner The owner object.
/// @param options Loading options.
+ (NSArray *)loadNibNamed:(NSString *)name
                    owner:(id)owner
                  options:(NSDictionary *)options;

/// Search for a localized string first in the mainBundle, then in the backupBundle.
/// @param key The key for the string.
/// @param value The value to return if key is `nil`.
/// @param tableName The table to search for.
/// @param bundle The bundle to search for in case the string was not found
/// in the mainBundle.
+ (NSString *)localizedStringForKey:(NSString *)key
                              value:(NSString *)value
                              table:(NSString *)tableName
                       backupBundle:(NSBundle *)bundle;

@end

