//
//  UIApplication+NBUAdditions.h
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/07/26.
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

/**
 Convenience UIApplication methods.
 
 - Retrieve application version and build information.
 - Get the documents and caches directories.
 */
@interface UIApplication (NBUAdditions)

/// @name Application Properties

/// Convenience method to retrive the application display name.
@property (nonatomic, readonly) NSString * applicationName;

/// Convinience method to retrive the application version.
@property (nonatomic, readonly) NSString * applicationVersion;

/// Convinience method to retrive the application build.
@property (nonatomic, readonly) NSString * applicationBuild;

/// Convinience method to retrive the application documents directory.
@property (nonatomic, readonly) NSURL * documentsDirectory;

/// Convinience method to retrive the application caches directory.
@property (nonatomic, readonly) NSURL * cachesDirectory;

/// Convinience method to retrive the application temporary directory.
@property (nonatomic, readonly) NSURL * temporaryDirectory;

/// Convinience method to retrive the application library directory.
@property (nonatomic, readonly) NSURL * libraryDirectory;

/// @name Set/Get Values in NSDefaults/Keychain

/// Retrieve a saved object from NSUserDefaults.
/// @param key The associated key.
/// @return An NSData, NSString, NSNumber, NSDate, NSArray, NSDictionary or nil@ object.
+ (id)objectForKey:(NSString *)key;

/// Save an object in NSUserDefaults.
/// @param object An NSData, NSString, NSNumber, NSDate, NSArray, or NSDictionary object.
/// @param key The associated key.
+ (void)setObject:(id)object
           forKey:(NSString *)key;

/// Retrieve a saved object from the device Keychain.
/// @note For now limited to strings.
/// @param key The associated key.
/// @return An NSString object.
+ (NSString *)secureObjectForKey:(NSString *)key;

/// Save an object in the device Keychain.
/// @note For now limited to strings.
/// @param object A NSString object.
/// @param key The associated key.
+ (void)setSecureObject:(NSString *)object
                 forKey:(NSString *)key;

@end

