//
//  NBUAsset.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/08/01.
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

#import "NBUAsset.h"
#import "NBUKit.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_CAMERA_ASSETS

// Private classes
@interface NBUALAsset : NBUAsset

- (id)initWithALAsset:(ALAsset *)ALAsset;

@end

@interface NBUFileAsset : NBUAsset

- (id)initWithFileURL:(NSURL *)fileURL;

@end


@implementation NBUAsset

+ (NBUAsset *)assetForALAsset:(ALAsset *)ALAsset
{
    return [[NBUALAsset alloc] initWithALAsset:ALAsset];
}

+ (NBUAsset *)assetForFileURL:(NSURL *)fileURL
{
    return [[NBUFileAsset alloc] initWithFileURL:fileURL];
}

// *** Implement in subclasses if needed ***

- (NSURL *)URL { return nil; }

- (NBUAssetOrientation)orientation { return NBUAssetOrientationUnknown; }

- (BOOL)isEditable { return NO; }

- (CLLocation *)location { return nil; }

- (NSDate *)date { return nil; }

- (NBUAssetType)type { return NBUAssetTypeUnknown; }

- (ALAsset *)ALAsset { return nil; }

- (UIImage *)thumbnailImage { return nil; }

- (UIImage *)fullScreenImage { return nil; }

- (UIImage *)fullResolutionImage { return nil; }

@end


@implementation NBUALAsset
{
    ALAssetRepresentation * _defaultRepresentation;
}

@synthesize URL = _URL;
@synthesize orientation = _orientation;
@synthesize editable = _editable;
@synthesize location = _location;
@synthesize date = _date;
@synthesize type = _type;
@synthesize ALAsset = _ALAsset;

- (id)initWithALAsset:(ALAsset *)ALAsset
{
    self = [super init];
    if (self)
    {
        if (ALAsset)
        {
            self.ALAsset = ALAsset;
            
            // Observe library changes
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(libraryChanged:)
                                                         name:ALAssetsLibraryChangedNotification
                                                       object:nil];
        }
        else
        {
            self = nil; // Asset is required
        }
    }
    return self;
}

- (void)dealloc
{
    // Stop observing
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:ALAssetsLibraryChangedNotification
                                                  object:nil];
}

- (void)libraryChanged:(NSNotification *)notification
{
//    NBULogVerbose(@"Asset thumbnail: %@", _ALAsset.thumbnail);
//    NBULogVerbose(@"Asset defaultRepresentation: %@", _ALAsset.defaultRepresentation);
//    NBULogVerbose(@"Asset ALAssetPropertyType: %@", [_ALAsset valueForProperty:ALAssetPropertyType]);
//    NBULogVerbose(@"Asset ALAssetPropertyOrientation: %@", [_ALAsset valueForProperty:ALAssetPropertyOrientation]);
//    NBULogVerbose(@"Asset ALAssetPropertyDate: %@", [_ALAsset valueForProperty:ALAssetPropertyDate]);
//    NBULogVerbose(@"Asset ALAssetPropertyRepresentations: %@", [_ALAsset valueForProperty:ALAssetPropertyRepresentations]);
    
    // Is ALAsset is still valid?
    if (_ALAsset.defaultRepresentation)
        return;
    
    // Not valid -> Reload ALAsset
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [[NBUAssetsLibrary sharedLibrary].ALAssetsLibrary assetForURL:_URL
                                                          resultBlock:^(ALAsset * ALAsset)
         {
             if (ALAsset)
             {
                 NBULogVerbose(@"Asset %p had to be reloaded", self);
                 self.ALAsset = ALAsset;
                 // Send notification?
             }
             else
             {
                 NBULogWarn(@"Asset %p couldn't be reloaded. It may no longer exist", self);
                 // Send notification?
             }
         }
                                                         failureBlock:^(NSError * error)
         {
             NBULogError(@"Error while reloading asset %p: %@", self, error);
             // Send notification?
         }];
    });
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; %@>",
            NSStringFromClass([self class]), self, _ALAsset];
}

#pragma mark- Properties

- (void)setALAsset:(ALAsset *)ALAsset
{
    _ALAsset = ALAsset;
    _defaultRepresentation = nil;
    
    // Get URL
    NSArray * URLs = ((NSDictionary *)[_ALAsset valueForProperty:ALAssetPropertyURLs]).allValues;
    if (URLs.count > 0)
    {
        _URL = URLs[0];
        if (URLs.count != 1)
        {
            NBULogInfo(@"Asset %@ doesn't have a single URL, we chosed one: %@ -> %@",
                       self, [_ALAsset valueForProperty:ALAssetPropertyURLs], _URL);
        }
    }
    else
    {
        NBULogError(@"Can't find a URL for the asset %@", ALAsset);
    }
}

- (NBUAssetOrientation)orientation
{
    if (_orientation == NBUAssetOrientationUnknown)
    {
        ALAssetOrientation orientation = self.defaultRepresentation.orientation;
        
        // Portrait: ALAssetOrientationLeft, Right, LeftMirrored, RightMirrored
        if (orientation == ALAssetOrientationLeft ||
            orientation == ALAssetOrientationRight ||
            orientation == ALAssetOrientationLeftMirrored ||
            orientation == ALAssetOrientationRightMirrored)
        {
            _orientation = NBUAssetOrientationPortrait;
        }
        // Landscape: ALAssetOrientationUp, Down, UpMirrored, DownMirrored
        else
        {
            _orientation = NBUAssetOrientationLandscape;
        }
    }
    return _orientation;
}

- (BOOL)isEditable
{
    if (!_editable)
    {
        _editable = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0") ? _ALAsset.editable : NO;
    }
    return _editable;
}

- (NBUAssetType)type
{
    if (!_type)
    {
        NSString * typeString = [_ALAsset valueForProperty:ALAssetPropertyType];
        if ([typeString isEqualToString:ALAssetTypePhoto])
        {
            _type = NBUAssetTypeImage;
        }
        else if ([typeString isEqualToString:ALAssetTypeVideo])
        {
            _type = NBUAssetTypeVideo;
        }
    }
    return _type;
}

- (NSDate *)date
{
    if (!_date)
    {
        _date = [_ALAsset valueForProperty:ALAssetPropertyDate];
    }
    return _date;
}

- (CLLocation *)location
{
    if (!_location)
    {
        _location = [_ALAsset valueForProperty:ALAssetPropertyLocation];
    }
    return _location;
}

#pragma mark - Images

- (ALAssetRepresentation *)defaultRepresentation
{
    if (!_defaultRepresentation)
    {
        _defaultRepresentation = _ALAsset.defaultRepresentation;
    }
    return _defaultRepresentation;
}

- (UIImage *)thumbnailImage
{
    return [UIImage imageWithCGImage:_ALAsset.thumbnail];
}

- (UIImage *)fullScreenImage
{
    // "In iOS 5 and later, this method returns a fully cropped, rotated, and adjusted image—exactly as a user would see in Photos or in the image picker."
    UIImage * image = [UIImage imageWithCGImage:self.defaultRepresentation.fullScreenImage
                                          scale:self.defaultRepresentation.scale
                                    orientation:SYSTEM_VERSION_LESS_THAN(@"5.0") ? (UIImageOrientation)self.defaultRepresentation.orientation : UIImageOrientationUp];
    NBULogVerbose(@"fullScreenImage with size: %@ orientation %d",
               NSStringFromCGSize(image.size), image.imageOrientation);
    return image;
}

- (UIImage *)fullResolutionImage
{
    // "This method returns the biggest, best representation available, unadjusted in any way."
    UIImage * image = [UIImage imageWithCGImage:self.defaultRepresentation.fullResolutionImage
                                          scale:self.defaultRepresentation.scale
                                    orientation:(UIImageOrientation)self.defaultRepresentation.orientation];
    NBULogVerbose(@"fullResolutionImage with size: %@ orientation %d",
               NSStringFromCGSize(image.size), image.imageOrientation);
    return image;
}

@end


static CGSize _thumbnailSize;

@implementation NBUFileAsset

@synthesize URL = _URL;
@synthesize type = _type;
@synthesize thumbnailImage = _thumbnailImage;

+ (void)initialize
{
    _thumbnailSize = CGSizeMake(100.0, 100.0);
}

- (id)initWithFileURL:(NSURL *)fileURL
{
    self = [super init];
    if (self)
    {
        _URL = fileURL;
        _type = NBUAssetTypeImage; // For now
        _thumbnailImage = [self.fullScreenImage thumbnailWithSize:_thumbnailSize];
    }
    return self;
}

- (UIImage *)fullScreenImage
{
    return self.fullResolutionImage;
}

- (UIImage *)fullResolutionImage
{
    return [UIImage imageWithContentsOfFile:_URL.path];
}

@end

