//
//  NSFileManager+NBUAdditions.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2013/03/12.
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

#import "NSFileManager+NBUAdditions.h"
#import "NBUKitPrivate.h"

@implementation NSFileManager (NBUAdditions)

- (NSArray *)URLsForFilesWithExtensions:(NSArray *)extensions
                  searchInDirectoryURLs:(NSArray *)directories
{
    NSMutableArray * fileURLs = [NSMutableArray array];
    NSMutableArray * errors = [NSMutableArray array];
    NSArray * contents;
    NSError * error;
    
    // Check every directory
    for (NSURL * directory in directories)
    {
        contents = [self contentsOfDirectoryAtURL:directory
                       includingPropertiesForKeys:nil
                                          options:NSDirectoryEnumerationSkipsHiddenFiles
                                            error:&error];
        if (error)
        {
            [errors addObject:error];
            error = nil;
        }
        
        // Check every fileURL in contents
        BOOL isDirectory;
        for (NSURL * fileURL in contents)
        {
            // Skip directories
            isDirectory = NO;
            if ([self fileExistsAtPath:fileURL.path
                           isDirectory:&isDirectory] && isDirectory)
            {
                continue;
            }
            
            // No need to check extension?
            if (extensions.count == 0)
            {
                [fileURLs addObject:fileURL];
                continue;
            }
            
            // Check
            else
            {
                for (NSString * extension in extensions)
                {
                    if ([fileURL.pathExtension caseInsensitiveCompare:extension] == NSOrderedSame)
                    {
                        [fileURLs addObject:fileURL];
                        continue;
                    }
                }
            }
        }
    }
    
    if (errors.count > 0)
    {
        NBULogError(@"Some error(s) ocurred while searching searching for files with extensions %@ in directories %@. Error(s): %@",
                    extensions.shortDescription, directories, errors);
    }
    
    NBULogInfo(@"Found %@ files with extensions %@", @(fileURLs.count), extensions.shortDescription);
    
    return fileURLs;
}

- (NSArray *)URLsForSubdirectoriesOfDirectory:(NSURL *)directory
{
    NSMutableArray * subdirectories = [NSMutableArray array];
    
    NSError * error;
    NSArray * contents = [self contentsOfDirectoryAtURL:directory
                             includingPropertiesForKeys:nil
                                                options:NSDirectoryEnumerationSkipsHiddenFiles
                                                  error:&error];
    if (error)
    {
        NBULogError(@"%@ %@", THIS_METHOD, error);
    }
    
    BOOL isDirectory;
    for (NSURL * fileURL in contents)
    {
        isDirectory = NO;
        if ([self fileExistsAtPath:fileURL.path
                       isDirectory:&isDirectory] && isDirectory)
        {
            [subdirectories addObject:fileURL];
        }
    }
    
    return subdirectories;
}

+ (NSURL *)URLForNewFileAtDirectory:(NSURL *)directory
                 fileNameWithFormat:(NSString *)fileNameFormat
{
    NSFileManager * manager = [self defaultManager];
    NSString * pathFormat = [NSString stringWithFormat:@"%@/%@",
                             directory.path,
                             fileNameFormat ? fileNameFormat : @"file%02d"];
    NSString * path;
    NSUInteger i = 1;
    do
    {
        path = [NSString stringWithFormat:pathFormat, i++];
    }
    while ([manager fileExistsAtPath:path]);
    
    return [NSURL fileURLWithPath:path];
}

@end

