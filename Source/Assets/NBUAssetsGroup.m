//
//  NBUAssetsGroup.m
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

#import "NBUAssetsGroup.h"
#import "NBUKitPrivate.h"
#import <AssetsLibrary/AssetsLibrary.h>

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_CAMERA_ASSETS

// Private classes
@interface NBUALAssetsGroup : NBUAssetsGroup

- (id)initWithALAssetsGroup:(ALAssetsGroup *)ALAssetsGroup;

@end

@interface NBUDirectoryAssetsGroup : NBUAssetsGroup

- (id)initWithDirectoryURL:(NSURL *)directoryURL
                      name:(NSString *)name;

@end


@implementation NBUAssetsGroup

+ (NBUAssetsGroup *)groupForALAssetsGroup:(ALAssetsGroup *)ALAssetsGroup
{
    return [[NBUALAssetsGroup alloc] initWithALAssetsGroup:ALAssetsGroup];
}

+ (NBUAssetsGroup *)groupForDirectoryURL:(NSURL *)directoryURL
                                    name:(NSString *)name
{
    return [[NBUDirectoryAssetsGroup alloc] initWithDirectoryURL:directoryURL
                                                            name:name];
}

// *** Implement in subclasses if needed ***

- (NSString *)name { return nil; }

- (BOOL)isEditable { return NO; }

- (NSURL *)URL { return nil; }

- (UIImage *)posterImage { return nil; }

- (NBUAssetsGroupType)type { return NBUAssetsGroupTypeUnknown; }

- (ALAssetsGroup *)ALAssetsGroup { return nil; }

- (void)assetsWithTypes:(NBUAssetType)types
              atIndexes:(NSIndexSet *)indexSet
           reverseOrder:(BOOL)reverseOrder
    incrementalLoadSize:(NSUInteger)loadSize
            resultBlock:(NBUAssetsResultBlock)resultBlock {}

- (void)stopLoadingAssets {}

- (void)addAssetWithURL:(NSURL *)assetURL
            resultBlock:(void (^)(BOOL))resultBlock {}

- (BOOL)addAsset:(NBUAsset *)asset { return NO; }

- (NSUInteger)assetsCount { return 0; }

- (NSUInteger)imageAssetsCount { return 0; }

- (NSUInteger)videoAssetsCount { return 0; }

@end


@implementation NBUALAssetsGroup
{
    NSString * _persistentID;
    BOOL _stopLoadingAssets;
    NSUInteger _lastAssetsCount;
}

@synthesize name = _name;
@synthesize editable = _editable;
@synthesize URL = _URL;
@synthesize type = _type;
@synthesize ALAssetsGroup = _ALAssetsGroup;

- (id)initWithALAssetsGroup:(ALAssetsGroup *)ALAssetsGroup
{
    self = [super init];
    if (self)
    {
        if (ALAssetsGroup)
        {
            self.ALAssetsGroup = ALAssetsGroup;
            
            // Observe library changes
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(libraryChanged:)
                                                         name:ALAssetsLibraryChangedNotification
                                                       object:nil];
        }
        else
        {
            // Group is required
            self = nil;
        }
    }
    return self;
}

- (void)dealloc
{
    // Stop observing
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; %@; editable = %@>",
            NSStringFromClass([self class]), self, _ALAssetsGroup, NBUStringFromBOOL(_editable)];
}

- (void)libraryChanged:(NSNotification *)notification
{
//    NBULogVerbose(@"Assets group %@ posterImage: %@", _name, _ALAssetsGroup.posterImage);
//    NBULogVerbose(@"Assets group %@ nAssets: %d", _name, _ALAssetsGroup.numberOfAssets);
//    NBULogVerbose(@"Assets group %@ ALAssetsGroupPropertyName: %@", _name, [_ALAssetsGroup valueForProperty:ALAssetsGroupPropertyName]);
//    NBULogVerbose(@"Assets group %@ ALAssetsGroupPropertyType: %@", _name, [_ALAssetsGroup valueForProperty:ALAssetsGroupPropertyType]);
//    NBULogVerbose(@"Assets group %@ ALAssetsGroupPropertyPersistentID: %@", _name, [_ALAssetsGroup valueForProperty:ALAssetsGroupPropertyPersistentID]);
    
    // Is ALAssetsGroup is still valid?
    if ([_ALAssetsGroup valueForProperty:ALAssetsGroupPropertyName])
    {
        // Assets count changed?
        NSUInteger newCount = self.imageAssetsCount;
        if (newCount != _lastAssetsCount)
        {
            NBULogVerbose(@"Assets group %@ count changed: %d -> %d", _name, _lastAssetsCount, newCount);
            
            _lastAssetsCount = newCount;
            [[NSNotificationCenter defaultCenter] postNotificationName:NBUObjectUpdatedNotification
                                                                object:self];
        }
        return;
    }
    
    // Not valid -> Reload ALAssetsGroup
    // iOS 5+
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
    {
        // Retrieve
        [[NBUAssetsLibrary sharedLibrary].ALAssetsLibrary groupForURL:_URL
                                                          resultBlock:^(ALAssetsGroup * ALAssetsGroup)
         {
             if (ALAssetsGroup)
             {
                 NBULogVerbose(@"Assets group %@ had to be reloaded", _name);
                 
                 NSUInteger oldCount = _lastAssetsCount;
                 _ALAssetsGroup = ALAssetsGroup;
                 
                 // Send update notification only if needed!
                 if (oldCount != _lastAssetsCount)
                 {
                     NBULogVerbose(@"Assets group %@ count changed: %d -> %d",
                                   _name, oldCount, self.imageAssetsCount);
                     
                     [[NSNotificationCenter defaultCenter] postNotificationName:NBUObjectUpdatedNotification
                                                                         object:self];
                 }
             }
             else
             {
                 NBULogWarn(@"Assets group %@ couldn't be reloaded. It may no longer exist", _name);
             }
         }
                                                         failureBlock:^(NSError * error)
         {
             NBULogError(@"Error while reloading assets group %@: %@", _name, error);
         }];
    }
    // iOS 4: We have to look for the group manually
    else
    {
        // Look among all the groups
        __block BOOL found = NO;
        [[NBUAssetsLibrary sharedLibrary].ALAssetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                                                        usingBlock:^(ALAssetsGroup * ALAssetsGroup,
                                                                                     BOOL * stop)
         {
             // Process next group
             if (ALAssetsGroup)
             {
                 if ([[ALAssetsGroup valueForProperty:ALAssetsGroupPropertyPersistentID] isEqualToString:_persistentID])
                 {
                     NBULogVerbose(@"Assets group %@ had to be reloaded", _name);
                     
                     NSUInteger oldCount = _lastAssetsCount;
                     _ALAssetsGroup = ALAssetsGroup;
                     found = YES;
                     *stop = YES;
                     
                     // Send update notification only if needed!
                     if (oldCount != _lastAssetsCount)
                     {
                         NBULogVerbose(@"Assets group %@ count changed: %d -> %d",
                                       _name, oldCount, self.imageAssetsCount);
                         
                         [[NSNotificationCenter defaultCenter] postNotificationName:NBUObjectUpdatedNotification
                                                                             object:self];
                     }
                 }
             }
             // Finished
             else
             {
                 if (!found)
                 {
                     NBULogWarn(@"Assets group %@ couldn't be reloaded. It may no longer exist", _name);
                 }
             }
         }
                                                                      failureBlock:^(NSError * error)
         {
             NBULogError(@"Error while reloading assets group %@: %@", _name, error);
         }];
    }
}

#pragma mark - Properties

- (void)setALAssetsGroup:(ALAssetsGroup *)ALAssetsGroup
{
    _ALAssetsGroup = ALAssetsGroup;
    
    _name = [_ALAssetsGroup valueForProperty:ALAssetsGroupPropertyName];
    _type = [[_ALAssetsGroup valueForProperty:ALAssetsGroupPropertyType] unsignedIntegerValue];
    _persistentID = [_ALAssetsGroup valueForProperty:ALAssetsGroupPropertyPersistentID];
    _lastAssetsCount = self.imageAssetsCount;
    
    // iOS 5.0+
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
    {
        _editable = _ALAssetsGroup.editable;
        _URL = [_ALAssetsGroup valueForProperty:ALAssetsGroupPropertyURL];
    }
    // iOS 4: Create a NSURL
    else
    {
        _editable = NO;
        _URL = [NSURL URLWithString:[NSString stringWithFormat:@"assets-library://group/?id=%@",
                                          _persistentID]];
        
        NBULogVerbose(@"URL had to be created (iOS4 device): %@", _URL);
    }
}

- (UIImage *)posterImage
{
    return [UIImage imageWithCGImage:[_ALAssetsGroup posterImage]];
}

#pragma mark - Assets

- (void)stopLoadingAssets
{
    _stopLoadingAssets = YES;
}

- (void)assetsWithTypes:(NBUAssetType)types
              atIndexes:(NSIndexSet *)indexSet
           reverseOrder:(BOOL)reverseOrder
    incrementalLoadSize:(NSUInteger)loadSize
            resultBlock:(NBUAssetsResultBlock)resultBlock
{
    // Set the group's asset filter
    ALAssetsFilter * filter;
    NSUInteger countToReach;
    switch (types)
    {
        case NBUAssetTypeImage:
        {
            filter = [ALAssetsFilter allPhotos];
            countToReach = self.imageAssetsCount;
            break;
        }
        case NBUAssetTypeVideo:
        {
            filter = [ALAssetsFilter allVideos];
            countToReach = self.videoAssetsCount;
            break;
        }
        default:
        {
            filter = nil;
            countToReach = self.assetsCount;
            break;
        }
    }
    [_ALAssetsGroup setAssetsFilter:filter];
    
    // Incremental load size
    loadSize = loadSize ? loadSize : NSUIntegerMax;
    
    // Enumeration block
    _stopLoadingAssets = NO;
    NSMutableArray * assets = [NSMutableArray array];
    ALAssetsGroupEnumerationResultsBlock block = ^(ALAsset * ALAsset,
                                                   NSUInteger index,
                                                   BOOL * stop)
    {
        // Should we stop?
        if (_stopLoadingAssets)
        {
            * stop = YES;
            return;
        }
        
        // Process next asset
        if (ALAsset)
        {
            NBUAsset * asset = [NBUAsset assetForALAsset:ALAsset];
            [assets addObject:asset];
            
            // Incremental load reached?
            if ((assets.count % loadSize) == 0 &&
                assets.count != countToReach)
            {
                NBULogVerbose(@"%@ Incrementally loaded: %d assets", _name, assets.count);
                
                resultBlock(assets, nil);
            }
        }
        
        // Finish
        else
        {
            if (_stopLoadingAssets)
            {
                NBULogInfo(@"Stoppped retrieving assets");
            }
            else
            {
                NBULogVerbose(@"Loading %@ finished: %d assets with filter %@", _name, assets.count, filter);
                
                resultBlock(assets, nil);
            }
        }
    };
    
    // Enumerate
    NBULogVerbose(@"Start loading %@ assets...", _name);
    if (!indexSet)
    {
        [_ALAssetsGroup enumerateAssetsWithOptions:reverseOrder ? NSEnumerationReverse : 0
                                        usingBlock:block];
    }
    else
    {
        [_ALAssetsGroup enumerateAssetsAtIndexes:indexSet
                                         options:reverseOrder ? NSEnumerationReverse : 0
                                      usingBlock:block];
     }
}

- (NSUInteger)assetsCount
{
    [_ALAssetsGroup setAssetsFilter:nil];
    return (NSUInteger)[_ALAssetsGroup numberOfAssets];
}

- (NSUInteger)imageAssetsCount
{
    [_ALAssetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
    return (NSUInteger)[_ALAssetsGroup numberOfAssets];
}

- (NSUInteger)videoAssetsCount
{
    [_ALAssetsGroup setAssetsFilter:[ALAssetsFilter allVideos]];
    return (NSUInteger)[_ALAssetsGroup numberOfAssets];
}

- (BOOL)addAsset:(NBUAsset *)asset
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
    {
        if ([_ALAssetsGroup addAsset:asset.ALAsset])
        {
            NBULogInfo(@"Added asset: %@ to group: %@", asset, self);
            return YES;
        }
        else
        {
            NBULogWarn(@"Failed to add asset: %@ to group: %@", asset, self);
        }
    }
    else
    {
        NBULogInfo(@"Can't add assets to groups in iOS 4.x");
    }
    return NO;
}

- (void)addAssetWithURL:(NSURL *)assetURL
            resultBlock:(void (^)(BOOL))resultBlock
{
    [[NBUAssetsLibrary sharedLibrary] assetForURL:assetURL
                                           resultBlock:^(NBUAsset * imageAsset,
                                                         NSError * error)
    {
        if (!imageAsset)
        {
            if (resultBlock) resultBlock(NO);
        }
        else
        {
            BOOL success = [self addAsset:imageAsset];
            if (resultBlock) resultBlock(success);
        }
    }];
}

@end


static CGSize _thumbnailSize;

@implementation NBUDirectoryAssetsGroup
{
    NSArray * _directoryContents;
    BOOL _stopLoadingAssets;
}

+ (void)initialize
{
    _thumbnailSize = CGSizeMake(100.0, 100.0);
}

@synthesize name = _name;
@synthesize URL = _URL;
@synthesize type = _type;
@synthesize posterImage = _posterImage;

- (id)initWithDirectoryURL:(NSURL *)directoryURL
                      name:(NSString *)name
{
    self = [super init];
    if (self)
    {
        _name = name ? name : [directoryURL.lastPathComponent stringByDeletingPathExtension];
        _URL = directoryURL;
        _type = NBUAssetsGroupTypeDirectory;
        
        // Initialize
        [self refreshDirectoryContents];
        if (_directoryContents.count > 0)
        {
            NSURL * posterFileURL = _directoryContents[_directoryContents.count - 1];
            _posterImage = [[UIImage imageWithContentsOfFile:posterFileURL.path] thumbnailWithSize:_thumbnailSize];
        }
    }
    return self;
}

- (void)refreshDirectoryContents
{
    _directoryContents = [[NSFileManager defaultManager] URLsForFilesWithExtensions:kNBUImageFileExtensions
                                                              searchInDirectoryURLs:@[_URL]];
}

- (NSUInteger)assetsCount
{
    return _directoryContents.count;
}

- (NSUInteger)imageAssetsCount
{
    return self.assetsCount;
}

- (NSUInteger)videoAssetsCount
{
    return 0; // For now
}

- (void)stopLoadingAssets
{
    _stopLoadingAssets = YES;
}

- (void)assetsWithTypes:(NBUAssetType)types
              atIndexes:(NSIndexSet *)indexSet
           reverseOrder:(BOOL)reverseOrder
    incrementalLoadSize:(NSUInteger)loadSize
            resultBlock:(NBUAssetsResultBlock)resultBlock
{
    [self refreshDirectoryContents];
    
    // Adjust order and indexes (if any)
    NSArray * contents = reverseOrder ? _directoryContents.reverseObjectEnumerator.allObjects : _directoryContents;
    if (indexSet)
    {
        contents = [contents objectsAtIndexes:indexSet];
    }
    
    // Async create assets
    dispatch_async(dispatch_get_current_queue(), ^
    {
        [self assetsWithFileURLs:contents
             incrementalLoadSize:loadSize
                     resultBlock:resultBlock];
    });
}

- (void)assetsWithFileURLs:(NSArray *)fileURLs
       incrementalLoadSize:(NSUInteger)loadSize
               resultBlock:(NBUAssetsResultBlock)resultBlock
{
    NSMutableArray * assets = [NSMutableArray arrayWithCapacity:fileURLs.count];
    
    // Create assets for each item
    _stopLoadingAssets = NO;
    for (NSURL * fileURL in fileURLs)
    {
        // Stop?
        if (_stopLoadingAssets)
        {
            _stopLoadingAssets = NO;
            return;
        }
        
        [assets addObject:[NBUAsset assetForFileURL:fileURL]];
        
        // Return incrementally?
        if (loadSize &&
            (assets.count % loadSize) == 0 &&
            assets.count != fileURLs.count)
        {
            resultBlock(assets, nil);
        }
    }
    
    resultBlock(assets, nil);
}

@end

