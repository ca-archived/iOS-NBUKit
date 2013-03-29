//
//  NBUAssetsLibrary.m
//  NBUKit
//
//  Created by 利辺羅 on 2012/08/01.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import "NBUAssetsLibrary.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>
#import "NBUAsset.h"
#import "NBUAssetsGroup.h"
#import "NSURL+RKAdditions.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_CAMERA_ASSETS

NSString * const NBUAssetsErrorDomain = @"NBUAssetsErrorDomain";

static NBUAssetsLibrary * _sharedLibrary = nil;

@implementation NBUAssetsLibrary
{
    NSMutableDictionary * _directories;
}

@synthesize ALAssetsLibrary = _ALAssetsLibrary;

#pragma mark - Initialization

+ (NBUAssetsLibrary *)sharedLibrary
{
    if (!_sharedLibrary)
    {
        [NBUAssetsLibrary new];
    }
    return _sharedLibrary;
}

+ (void)setSharedLibrary:(NBUAssetsLibrary *)library
{
    _sharedLibrary = library;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _ALAssetsLibrary = [ALAssetsLibrary new];
        _directories = [NSMutableDictionary dictionary];
        
        // Set the first object as the singleton
        if (!_sharedLibrary)
        {
            _sharedLibrary = self;
        }
        
        // Observe library changes
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(libraryChanged:)
                                                     name:ALAssetsLibraryChangedNotification
                                                   object:nil];
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

- (void)registerDirectoryGroupforURL:(NSURL *)directoryURL
                                name:(NSString *)name
{
    _directories[directoryURL] = name ? name : [NSNull null];
}

- (void)libraryChanged:(NSNotification *)notification
{
    NBULogVerbose(@"Library changed: %@ userInfo: %@", notification, notification.userInfo);
}

#pragma mark - Access permissions

- (BOOL)userDeniedAccess
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
    {
        // Check with ALAssetsLibrary
        return [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied;
    }
    else
    {
        // Check with ALAssetsLibrary
        return [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied;
    }
}

- (BOOL)restrictedAccess
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
    {
        // Check with ALAssetsLibrary
        return [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusRestricted;
    }
    else
    {
        // Check with ALAssetsLibrary
        return [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted;
    }
}

#pragma mark - Retrieving asset groups

- (void)directoryGroupsWithResultBlock:(NBUAssetsGroupsResultBlock)resultBlock
{
    dispatch_async(dispatch_get_current_queue(), ^
    {
        NSMutableArray * groups = [NSMutableArray array];
        id name;
        for (NSURL * directoryURL in _directories)
        {
            name = _directories[directoryURL];
            [groups addObject:[NBUAssetsGroup groupForDirectoryURL:directoryURL
                                                              name:name == [NSNull null] ? nil : name]];
        }
        resultBlock(groups, nil);
    });
}

- (void)allGroupsWithResultBlock:(NBUAssetsGroupsResultBlock)resultBlock
{
    NSMutableArray * groups = [NSMutableArray array];
    
    // First all directory groups
    [self directoryGroupsWithResultBlock:^(NSArray * directoryGroups,
                                           NSError * directoryError)
    {
        if (directoryGroups)
        {
            [groups addObjectsFromArray:directoryGroups];
        }
        
        // Then all AL albums
        [self albumGroupsWithResultBlock:^(NSArray * albumGroups,
                                           NSError * albumError)
        {
            if (albumGroups)
            {
                [groups addObjectsFromArray:albumGroups];
            }
            
            resultBlock(groups, albumError);
        }];
    }];
}

- (void)cameraRollGroupWithResultBlock:(NBUAssetsGroupResultBlock)resultBlock
{
    [self groupsWithTypes:ALAssetsGroupSavedPhotos
              resultBlock:^(NSArray * groups, NSError * error) { resultBlock([groups lastObject], error); }];
}

- (void)photoStreamGroupWithResultBlock:(NBUAssetsGroupResultBlock)resultBlock
{
    [self groupsWithTypes:ALAssetsGroupPhotoStream
              resultBlock:^(NSArray * groups, NSError * error) { resultBlock([groups lastObject], error); }];
}

- (void)photoLibraryGroupWithResultBlock:(NBUAssetsGroupResultBlock)resultBlock
{
    [self groupsWithTypes:ALAssetsGroupLibrary
              resultBlock:^(NSArray * groups, NSError * error) { resultBlock([groups lastObject], error); }];
}

- (void)albumGroupsWithResultBlock:(NBUAssetsGroupsResultBlock)resultBlock
{
    NSMutableArray * groups = [NSMutableArray array];
    
    // Add camera roll
    [self cameraRollGroupWithResultBlock:^(NBUAssetsGroup * cameraRollGroup, NSError * error1)
     {
         if (error1 && (error1.code == ALAssetsLibraryAccessUserDeniedError ||      // User denied access
                        error1.code == ALAssetsLibraryAccessGloballyDeniedError))   // Location is not enabled
         {
             // No need to continue
             resultBlock(nil, error1);
             return;
         }
         if (cameraRollGroup)
         {
             [groups addObject:cameraRollGroup];
         }
         
         // Add photostream
         [self photoStreamGroupWithResultBlock:^(NBUAssetsGroup * photoStreamGroup, NSError * error2)
          {
              if (photoStreamGroup)
              {
                  [groups addObject:photoStreamGroup];
              }
              
              // Add photo library
              [self photoLibraryGroupWithResultBlock:^(NBUAssetsGroup * photoLibraryGroup, NSError * error3)
               {
                   if (photoLibraryGroup)
                   {
                       [groups addObject:photoLibraryGroup];
                   }
                   
                   // Add albums
                   [self groupsWithTypes:ALAssetsGroupAlbum
                             resultBlock:^(NSArray * albumGroups, NSError * error4)
                    {
                        if (albumGroups)
                        {
                            [groups addObjectsFromArray:albumGroups];
                        }
                        
                        // Finally return groups using the result block
                        resultBlock(groups, nil);
                    }];
               }];
          }];
     }];
}

- (void)groupsWithTypes:(NBUAssetsGroupType)types
            resultBlock:(NBUAssetsGroupsResultBlock)resultBlock
{
    // Enumeration block
    NSMutableArray * groups = [NSMutableArray array];
    ALAssetsLibraryGroupsEnumerationResultsBlock enumerationBlock = ^(ALAssetsGroup * ALAssetsGroup,
                                                                      BOOL * stop)
    {
        // Process next group
        if (ALAssetsGroup)
        {
            NBUAssetsGroup * group = [NBUAssetsGroup groupForALAssetsGroup:ALAssetsGroup];
            [groups addObject:group];
        }
        
        // Finished
        else
        {
            NBULogInfo(@"Retrieved %d groups of type %d", groups.count, types);
            NBULogVerbose(@"Groups: %@", groups);
            resultBlock(groups, nil);
        }
    };
    
    // Failure block
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError * error)
    {
        NBULogError(@"Failed to retrieve type %d groups: %@", types, error);
        resultBlock(nil, error);
    };
    
    // Access library
    [_ALAssetsLibrary enumerateGroupsWithTypes:types
                                    usingBlock:enumerationBlock
                                  failureBlock:failureBlock];
}

- (void)groupForURL:(NSURL *)groupURL
        resultBlock:(NBUAssetsGroupResultBlock)resultBlock
{
    NBULogTrace();
    
    // iOS 5+
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
    {
        // Result block
        ALAssetsLibraryGroupResultBlock block = ^(ALAssetsGroup * ALAssetsGroup)
        {
            if (ALAssetsGroup)
            {
                NBUAssetsGroup * group = [NBUAssetsGroup groupForALAssetsGroup:ALAssetsGroup];
                NBULogVerbose(@"Retrieved group: %@", group);
                resultBlock(group, nil);
            }
            else
            {
                NBULogVerbose(@"No group with URL '%@' was found", groupURL);
                resultBlock(nil, nil);
            }
        };
        
        // Failure block
        ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError * error)
        {
            NBULogError(@"Failed to retrieve group with URL '%@': %@", groupURL, error);
            resultBlock(nil, error);
        };
        
        // Retrieve
        [_ALAssetsLibrary groupForURL:groupURL
                          resultBlock:block
                         failureBlock:failureBlock];
    }
    
    // iOS 4: We have to look for the group manually
    else
    {
        NBULogVerbose(@"Looking for group in iOS4");
        
        NSString * absoluteString = groupURL.absoluteString;
        
        // Look among all the groups
        [self groupsWithTypes:ALAssetsGroupAll
                  resultBlock:^(NSArray * groups, NSError * error)
         {
             if (error)
             {
                 resultBlock(nil, error);
                 return;
             }
             
             for (NBUAssetsGroup * group in groups)
             {
                 // Found?
                 if ([group.URL.absoluteString isEqualToString:absoluteString])
                 {
                     resultBlock(group, nil);
                     return;
                 }
             }
             
             // Not found
             NBULogVerbose(@"Looking for group in iOS4: Group for not found for '%@'", groupURL);
             resultBlock(nil, nil);
         }];
    }
}

- (void)createAlbumGroupWithName:(NSString *)name
                     resultBlock:(NBUAssetsGroupResultBlock)resultBlock
{
    // Failure block
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError * error)
    {
        NBULogWarn(@"Couldn't create group named '%@': %@", name, error);
        if (resultBlock) resultBlock(nil, error);
    };
    
    // Fail on iOS 4
    if (SYSTEM_VERSION_LESS_THAN(@"5.0"))
    {
        failureBlock([NSError errorWithDomain:NBUAssetsErrorDomain
                                         code:NBUAssetsFeatureNotAvailableInSystem4
                                     userInfo:@{NSLocalizedDescriptionKey : @"Can't create albums on iOS 4"}]);
        return;
    }
    
    // Result block
    ALAssetsLibraryGroupResultBlock block = ^(ALAssetsGroup * ALAssetsGroup)
    {
        if (ALAssetsGroup)
        {
            NBUAssetsGroup * group = [NBUAssetsGroup groupForALAssetsGroup:ALAssetsGroup];
            NBULogInfo(@"Created new group: %@", group);
            if (resultBlock) resultBlock(group, nil);
        }
        else
        {
            failureBlock([NSError errorWithDomain:NBUAssetsErrorDomain
                                             code:NBUAssetsGroupAlreadyExists
                                         userInfo:@{NSLocalizedDescriptionKey : [NSString stringWithFormat:
                                                                                 @"Group '%@' already exists", name]}]);
        }
    };
    
    // Try to create
    [_ALAssetsLibrary addAssetsGroupAlbumWithName:name
                                      resultBlock:block
                                     failureBlock:failureBlock];
}

- (void)groupWithName:(NSString *)name
          resultBlock:(NBUAssetsGroupResultBlock)resultBlock
{
    // Enumeration block
    __block BOOL found = NO;
    ALAssetsLibraryGroupsEnumerationResultsBlock enumerationBlock = ^(ALAssetsGroup * ALAssetsGroup,
                                                                      BOOL * stop)
    {
        // Process next group
        if (ALAssetsGroup)
        {
            // Check name
            if ([(NSString *)[ALAssetsGroup valueForProperty:ALAssetsGroupPropertyName] isEqualToString:name])
            {
                NBUAssetsGroup * group = [NBUAssetsGroup groupForALAssetsGroup:ALAssetsGroup];
                NBULogVerbose(@"Retrieved group %@", group);
                *stop = YES;
                found = YES;
                resultBlock(group, nil);
            }
        }
        // Finished
        else
        {
            // Wasn't found?
            if (!found)
            {
                NBULogVerbose(@"No group with name '%@' was found", name);
                resultBlock(nil, nil);
            }
        }
    };
    
    // Failure block
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError * error)
    {
        NBULogError(@"Failed to search group named '%@': %@", name, error);
        resultBlock(nil, error);
    };
    
    // Access library
    [_ALAssetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                    usingBlock:enumerationBlock
                                  failureBlock:failureBlock];
}

#pragma mark - Retrieve assets

- (void)allAssetsWithTypes:(NBUAssetType)types
               resultBlock:(NBUAssetsResultBlock)resultBlock;
{
    NBULogVerbose(@"All assets with type %d...", types);
    
    NSMutableArray * assets = [NSMutableArray array];
    
    // Add camera roll assets
    [self cameraRollGroupWithResultBlock:^(NBUAssetsGroup * cameraRollGroup,
                                           NSError * error1)
     {
         if (error1 && (error1.code == ALAssetsLibraryAccessUserDeniedError ||      // User denied access
                        error1.code == ALAssetsLibraryAccessGloballyDeniedError))   // Location is not enabled
         {
             // No need to continue
             resultBlock(nil, error1);
             return;
         }
         if (cameraRollGroup)
         {
             [cameraRollGroup assetsWithTypes:types
                                    atIndexes:nil
                                 reverseOrder:NO
                          incrementalLoadSize:0
                                  resultBlock:^(NSArray * cameraRollAssets,
                                                NSError * error2)
              {
                  NBULogVerbose(@"All assets: adding %d from camera roll...", cameraRollAssets.count);
                  [assets addObjectsFromArray:cameraRollAssets];
                  
                  // Add photo library assets
                  [self photoLibraryGroupWithResultBlock:^(NBUAssetsGroup * photoLibraryGroup,
                                                           NSError * error3)
                   {
                       if (photoLibraryGroup)
                       {
                           [photoLibraryGroup assetsWithTypes:types
                                                    atIndexes:nil
                                                 reverseOrder:NO
                                          incrementalLoadSize:0
                                                  resultBlock:^(NSArray * photoLibraryAssets,
                                                                NSError * error4)
                            {
                                NBULogVerbose(@"All assets: adding %d from photo library...", photoLibraryAssets.count);
                                [assets addObjectsFromArray:photoLibraryAssets];
                                
                                // Finally return the assets
                                NBULogVerbose(@"All assets: Returning %d assets", assets.count);
                                resultBlock(assets, nil);
                            }];
                       }
                   }];
              }];
         }
     }];
}

- (void)allAssetsWithResultBlock:(NBUAssetsResultBlock)resultBlock
{
    [self allAssetsWithTypes:NBUAssetTypeAny
                 resultBlock:resultBlock];
}

- (void)allImageAssetsWithResultBlock:(NBUAssetsResultBlock)resultBlock
{
    [self allAssetsWithTypes:NBUAssetTypeImage
                 resultBlock:resultBlock];
}

- (void)allVideoAssetsWithResultBlock:(NBUAssetsResultBlock)resultBlock
{
    [self allAssetsWithTypes:NBUAssetTypeVideo
                 resultBlock:resultBlock];
}

- (void)assetForURL:(NSURL *)assetURL
        resultBlock:(NBUAssetResultBlock)resultBlock
{
    // Result block
    ALAssetsLibraryAssetForURLResultBlock block = ^(ALAsset * ALAsset)
    {
        if (ALAsset)
        {
            NBUAsset * asset = [NBUAsset assetForALAsset:ALAsset];
            NBULogVerbose(@"Retrieved asset: %@", asset);
            resultBlock(asset, nil);
        }
        else
        {
            NBULogVerbose(@"No asset for URL '%@' was found", assetURL);
            resultBlock(nil ,nil);
        }
    };
    
    // Failure block
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError * error)
    {
        NBULogError(@"Failed to retrieve asset for URL '%@': %@", assetURL, error);
        resultBlock(nil, error);
    };
    
    // Retrieve
    [_ALAssetsLibrary assetForURL:assetURL
                      resultBlock:block
                     failureBlock:failureBlock];
}

-(void)assetsForURLs:(NSArray *)assetURLs
         resultBlock:(NBUAssetsResultBlock)resultBlock
{
    NSMutableArray * assets = [NSMutableArray array];
    NSMutableArray * errors = [NSMutableArray array];
    __block NSUInteger count = 0;
    for (NSURL * assetURL in assetURLs)
    {
        [self assetForURL:assetURL
              resultBlock:^(NBUAsset * imageAsset,
                            NSError * error)
        {
            if (!error)
                [assets addObject:imageAsset];
            else
                [errors addObject:error];
            
            // Finished?
            count++;
            if (count == assetURLs.count)
            {
                // Any errors encountered?
                NSError * resultError;
                if (errors.count > 0)
                {
                    resultError = [NSError errorWithDomain:NBUAssetsErrorDomain
                                                      code:NBUAssetsCouldntRetrieveSomeAssets
                                                  userInfo:@{NSLocalizedDescriptionKey : [NSString stringWithFormat:
                                                                                          @"%d error(s) during assets retrieval",
                                                                                          errors.count],
                                                             NSUnderlyingErrorKey      : errors}];
                }
                
                // Return
                resultBlock(assetURLs,
                            resultError);
            }
        }];
    }
}


#pragma mark - Save to library

- (void)saveImageToCameraRoll:(UIImage *)image
                     metadata:(NSDictionary *)metadata
                  resultBlock:(NBUAssetURLResultBlock)resultBlock
{
    [self saveImageToCameraRoll:image
                       metadata:metadata
       addToAssetsGroupWithName:nil
                    resultBlock:resultBlock];
}

- (void)saveImageToCameraRoll:(UIImage *)image
                     metadata:(NSDictionary *)metadata
     addToAssetsGroupWithName:(NSString *)name
                  resultBlock:(NBUAssetURLResultBlock)resultBlock
{
    // At least iOS 4.1 required
    if (SYSTEM_VERSION_LESS_THAN(@"4.1"))
    {
        NSError * error = [NSError errorWithDomain:NBUAssetsErrorDomain
                                              code:NBUAssetsFeatureNotAvailableInSystem4
                                          userInfo:@{NSLocalizedDescriptionKey : @"Can't save images on iOS 4.0"}];
        NBULogError(@"Failed to save image to Camera Roll. : %@", error);
        if (resultBlock) resultBlock(nil, error);
        return;
    }
    
    // Save to Camera Roll
    [[NBUAssetsLibrary sharedLibrary].ALAssetsLibrary writeImageToSavedPhotosAlbum:image.CGImage
                                                                          metadata:metadata
                                                                   completionBlock:^(NSURL * assetURL,
                                                                                     NSError * error)
     {
         // Failed?
         if (error)
         {
             NBULogError(@"Failed to save image to Camera Roll: %@", error);
             if (resultBlock) resultBlock(nil, error);
         }
         
         // Saved
         else
         {
             // Call result block
             NBULogInfo(@"Image saved to Camera Roll with assetURL: %@", assetURL);
             if (resultBlock) resultBlock(assetURL, nil);
             
             // Finished?
             if (name.length == 0)
                 return;
             
             // Check if group already exists
             [self groupWithName:name
                     resultBlock:^(NBUAssetsGroup * group,
                                   NSError * addToGroupError)
              {
                  // Exists?
                  if (group)
                  {
                      [group addAssetWithURL:assetURL
                                 resultBlock:NULL]; // No need to check result
                  }
                  
                  // Try to create a group
                  else
                  {
                      [self createAlbumGroupWithName:name
                                         resultBlock:^(NBUAssetsGroup * newGroup,
                                                       NSError * createGroupError)
                       {
                           if (newGroup)
                           {
                               [newGroup addAssetWithURL:assetURL
                                             resultBlock:NULL]; // No need to check result
                           }
                       }];
                  }
              }];
         }
     }];
}

@end

