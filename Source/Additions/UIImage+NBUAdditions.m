//
//  UIImage+NBUAdditions.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/06/01.
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

#import "UIImage+NBUAdditions.h"
#import "NBUKitPrivate.h"

@implementation UIImage (NBUAdditions)

#pragma mark - Crop

- (UIImage *)imageCroppedToRect:(CGRect)cropArea
{
    cropArea = CGRectMake(nearbyintf(cropArea.origin.x),
                          nearbyintf(cropArea.origin.y),
                          nearbyintf(cropArea.size.width),
                          nearbyintf(cropArea.size.height));
    
    UIGraphicsBeginImageContextWithOptions(cropArea.size,
                                           YES,         // Opaque
                                           self.scale); // Use image scale
    
    [self drawInRect:CGRectMake(-cropArea.origin.x,
                                -cropArea.origin.y,
                                self.size.width,
                                self.size.height)];
    UIImage * croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    NBULogInfo(@"Image %@ %@ cropped to %@ %@",
               self,
               NSStringFromCGSize(self.size),
               croppedImage,
               NSStringFromCGSize(croppedImage.size));
    
    return croppedImage;
}

- (UIImage *)imageCroppedToFill:(CGSize)size
{
    CGFloat factor = MAX(size.width / self.size.width,
                         size.height / self.size.height);
    
    UIGraphicsBeginImageContextWithOptions(size,
                                           YES,                     // Opaque
                                           self.scale);             // Use image scale
    
    CGRect rect = CGRectMake((size.width - nearbyintf(self.size.width * factor)) / 2.0,
                             (size.height - nearbyintf(self.size.height * factor)) / 2.0,
                             nearbyintf(self.size.width * factor),
                             nearbyintf(self.size.height * factor));
    [self drawInRect:rect];
    UIImage * croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    NBULogInfo(@"Image %@ %@ cropped to %@ %@",
               self,
               NSStringFromCGSize(self.size),
               croppedImage,
               NSStringFromCGSize(croppedImage.size));
    
    return croppedImage;
}

#pragma mark - Downsize

- (UIImage *)imageDonwsizedToFill:(CGSize)size
{
    return [self imageDownsizedByFactor:MAX(size.width / self.size.width,
                                            size.height / self.size.height)];
}

- (UIImage *)imageDonwsizedToFit:(CGSize)size
{
    return [self imageDownsizedByFactor:MIN(size.width / self.size.width,
                                            size.height / self.size.height)];
}

- (UIImage *)imageDownsizedByFactor:(CGFloat)factor
{
    // No need to downsize?
    if (factor >= 1.0)
        return self;
    
    // Downsize
    CGRect target = CGRectMake(0.0,
                               0.0,
                               nearbyintf(self.size.width * factor),
                               nearbyintf(self.size.height * factor));
    
    UIGraphicsBeginImageContextWithOptions(target.size,
                                           YES,         // Opaque
                                           self.scale); // Use image scale
    
    [self drawInRect:target];
    UIImage * downsizedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    NBULogVerbose(@"Image %@ %@ downsized to %@ %@",
               self,
               NSStringFromCGSize(self.size),
               downsizedImage,
               NSStringFromCGSize(downsizedImage.size));
    
    return downsizedImage;
}

#pragma mark - Creating thumbnails

- (UIImage *)thumbnailWithSize:(CGSize)size
{
    // Manually set to double size for retina?
    CGFloat screenScale = [UIScreen mainScreen].scale;
    if (self.scale < screenScale)
    {
        size = CGSizeMake(size.width * screenScale,
                          size.height * screenScale);
    }
    
    return [self imageCroppedToFill:size];
}

#pragma mark - Flatten

- (UIImage *)imageFlattened
{
    UIGraphicsBeginImageContextWithOptions(self.size,
                                           YES,         // Opaque
                                           self.scale); // Use image scale
    
    [self drawInRect:CGRectMake(0.0,
                                0.0,
                                self.size.width,
                                self.size.height)];
    UIImage * flattenedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    NBULogVerbose(@"Image %@ %@ flattened to %@ %@",
               self,
               NSStringFromCGSize(self.size),
               flattenedImage,
               NSStringFromCGSize(flattenedImage.size));
    
    return flattenedImage;
}

#pragma mark - Save/load from Disk

- (NSURL *)writeToFile:(NSString *)path
{
    // Success?
    NSError * error;
    if ([UIImageJPEGRepresentation(self, 0.8) writeToFile:path
                                                  options:NSDataWritingAtomic
                                                    error:&error])
    {
        NSURL * url = [NSURL fileURLWithPath:path];
        NBULogInfo(@"Image saved to: %@", url);
        return url;
    }
    // Failure
    else
    {
        NBULogError(@"Error saving to file '%@': %@", path, error);
        return nil;
    }
}

- (NSURL *)writeToTemporaryDirectory
{
    // Find a suitable path
    NSFileManager * manager = [NSFileManager new];
    NSString * directory = [NSTemporaryDirectory() stringByStandardizingPath];
    NSString * path;
    NSUInteger i = 1;
    do
    {
        path = [NSString stringWithFormat:@"%@/image%03ld.jpg", directory, (long)i++];
    }
    while ([manager fileExistsAtPath:path]);
    
    // Write it
    return [self writeToFile:path];
}

+ (UIImage *)imageWithContentsOfFileURL:(NSURL *)fileURL
{
    return [self imageWithContentsOfFile:fileURL.path];
}

// From: http://stackoverflow.com/questions/5427656/ios-uiimagepickercontroller-result-image-orientation-after-upload
- (UIImage *)imageWithOrientationUp
{
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end

