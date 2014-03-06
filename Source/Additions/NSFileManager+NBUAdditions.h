//
//  NSFileManager+NBUAdditions.h
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

/**
 Convenience methods for file and directory handling.
 */
@interface NSFileManager (NBUAdditions)

/// Retrieve all the non-hidden, first level URLs matching a given set of extensions
/// searching among several directories.
/// @param extensions An array of file extensions.
/// @param directories An array of directories to be searched.
- (NSArray *)URLsForFilesWithExtensions:(NSArray *)extensions
                  searchInDirectoryURLs:(NSArray *)directories;

/// Retrieve all the subdirectories of a given directory.
/// @param directory The directory to search for.
- (NSArray *)URLsForSubdirectoriesOfDirectory:(NSURL *)directory;

/// Create a file URL in a given directory following a file name string format to
/// avoid overriding existing files.
/// @param directory The target directory where the new file would be saved.
/// @param fileNameFormat The name format the new file would have. Default `@"file%02d"`.
+ (NSURL *)URLForNewFileAtDirectory:(NSURL *)directory
                 fileNameWithFormat:(NSString *)fileNameFormat;

@end

