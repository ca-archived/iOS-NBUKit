//
//  UIApplication+NBUAdditions.m
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

#import "UIApplication+NBUAdditions.h"
#import "NBUKitPrivate.h"
#import <Lockbox/Lockbox.h>

@implementation UIApplication (NBUAdditions)

- (NSString *)applicationName
{
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
}

- (NSString *)applicationVersion
{
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
}

- (NSString *)applicationBuild
{
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
}

- (NSURL *)documentsDirectory
{
    NSError * error;
    NSURL * url = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                         inDomain:NSUserDomainMask
                                                appropriateForURL:nil
                                                           create:YES
                                                            error:&error];
    if (error)
    {
        NBULogError(@"Can't find the %@: %@", THIS_METHOD, error);
    }
    return url;
}

- (NSURL *)cachesDirectory
{
    NSError * error;
    NSURL * url = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory
                                                         inDomain:NSUserDomainMask
                                                appropriateForURL:nil
                                                           create:YES
                                                            error:&error];
    if (error)
    {
        NBULogError(@"Can't find the %@: %@", THIS_METHOD, error);
    }
    return url;
}

- (NSURL *)temporaryDirectory
{
    return [NSURL fileURLWithPath:NSTemporaryDirectory()
                      isDirectory:YES];
}

- (NSURL *)libraryDirectory
{
    NSError * error;
    NSURL * url = [[NSFileManager defaultManager] URLForDirectory:NSLibraryDirectory
                                                         inDomain:NSUserDomainMask
                                                appropriateForURL:nil
                                                           create:YES
                                                            error:&error];
    if (error)
    {
        NBULogError(@"Can't find the %@: %@", THIS_METHOD, error);
    }
    return url;
}

#pragma mark - NSUserDefaults

+ (void)setObject:(id)object
           forKey:(NSString *)key
{
    // Set?
    if (object)
    {
        [[NSUserDefaults standardUserDefaults] setObject:object
                                                  forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    // Clear
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (id)objectForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

#pragma mark - Keychain

+ (void)setSecureObject:(NSString *)object
                 forKey:(NSString *)key
{
    // TODO: make object a plist string
    if (![Lockbox setString:[object description]
                     forKey:key])
    {
        NBULogError(@"Couldn't set secure object '%@' for key '%@'",
                   object, key);
    }
}

+ (NSString *)secureObjectForKey:(NSString *)key
{
    // TODO:    return [[Lockbox stringForKey:key] propertyList];
    return [Lockbox stringForKey:key];
}

@end

