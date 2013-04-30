//
//  NBUMediaInfoTests.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2013/04/26.
//  Copyright (c) 2013 CyberAgent Inc.
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

#import "NBUMediaInfoTests.h"

@implementation NBUMediaInfoTests

- (void)test0EditedImageFallbackToOriginal;
{
    NBUMediaInfo * mediaInfo = [NBUMediaInfo new];
    
    // Set original
    UIImage * image = [self imageNamed:@"photo.jpg"];
    mediaInfo.originalImage = image;
    
    // Edited should fallback to the original
    UIImage * editedImage = mediaInfo.editedImage;
    STAssertEqualObjects(image, editedImage, @"Edited image %@ should fallback to the original image %@", editedImage, image);
}

- (void)test1PurgeMemory;
{
    NBUMediaInfo * mediaInfo = [NBUMediaInfo new];
    
    // Set original
    UIImage * image = [self imageNamed:@"photo.jpg"];
    mediaInfo.originalImage = image;
    
    // Set edited
    UIImage * editedImage = [image imageCroppedToFill:CGSizeMake(100.0, 100.0)];
    mediaInfo.editedImage = editedImage;
    
    // Trigger purge images as memory warning would do
    [mediaInfo purgeImagesFromMemory];
    
    // Check if correctly purged
    STAssertNil(mediaInfo.attributes[NBUMediaInfoOriginalMediaKey], @"Original image was not purged");
    STAssertNil(mediaInfo.attributes[NBUMediaInfoEditedMediaKey], @"Edited image was not purged");
    
    // Check for temporary files' URLs
    STAssertNotNil(mediaInfo.attributes[NBUMediaInfoOriginalMediaURLKey], @"Original image was not saved to disk");
    STAssertNotNil(mediaInfo.attributes[NBUMediaInfoEditedMediaURLKey], @"Edited image was not saved to disk");
    
    // Check if original is correctly reloaded
    UIImage * reloadedImage = mediaInfo.originalImage;
    STAssertNotNil(reloadedImage, @"Couldn't reload the original image");
    STAssertTrue(CGSizeEqualToSize(image.size, reloadedImage.size),
                 @"Reloaded and original images' sizes don't match: %@ != %@",
                 NSStringFromCGSize(image.size), NSStringFromCGSize(reloadedImage.size));
    
    // Check if edited is correctly reloaded
    UIImage * reloadedEdited = mediaInfo.editedImage;
    STAssertNotNil(reloadedEdited, @"Couldn't reload the original image");
    STAssertTrue(CGSizeEqualToSize(editedImage.size, reloadedEdited.size),
                 @"Reloaded and original images' sizes don't match: %@ != %@",
                 NSStringFromCGSize(editedImage.size), NSStringFromCGSize(reloadedEdited.size));
}

@end

