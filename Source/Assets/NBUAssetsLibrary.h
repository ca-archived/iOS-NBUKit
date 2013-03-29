//
//  NBUAssetsLibrary.h
//  NBUKit
//
//  Created by 利辺羅 on 2012/08/01.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

@class NBUAssetsGroup, NBUAsset, ALAssetsLibrary;

/// Supported image asset extensions.
#define kNBUImageFileExtensions @[@"png", @"jpg", @"jpeg", @"tiff", @"tif", @"gif", @"bmp", @"bmpf", @"ico", @"cur", @"xbm"]

/// NBUAsset return block types.
typedef void (^NBUAssetsGroupsResultBlock)(NSArray * groups, NSError * error);
typedef void (^NBUAssetsGroupResultBlock)(NBUAssetsGroup * group, NSError * error);
typedef void (^NBUAssetsResultBlock)(NSArray * assets, NSError * error);
typedef void (^NBUAssetResultBlock)(NBUAsset * imageAsset, NSError * error);
typedef void (^NBUAssetURLResultBlock)(NSURL * assetURL, NSError * error);

/// NBUAsset types.
enum
{
    NBUAssetTypeUnknown     = 0,
    NBUAssetTypeImage       = 1 << 0,
    NBUAssetTypeVideo       = 1 << 1,
    NBUAssetTypeAny         = (NBUAssetTypeImage |
                               NBUAssetTypeVideo)
};
typedef NSInteger NBUAssetType;

/// NBUAssetsGroup types.
enum
{
    NBUAssetsGroupTypeUnknown       = 0,
    
    // Groups from ALAssetsLibrary
    NBUAssetsGroupTypeLibrary       = 1 << 0,       // ALAssetsGroupLibrary
    NBUAssetsGroupTypeAlbum         = 1 << 1,       // ALAssetsGroupAlbum
    NBUAssetsGroupTypeEvent         = 1 << 2,       // ALAssetsGroupEvent
    NBUAssetsGroupTypeFaces         = 1 << 3,       // ALAssetsGroupFaces
    NBUAssetsGroupTypeSavedPhotos   = 1 << 4,       // ALAssetsGroupSavedPhotos
    NBUAssetsGroupTypePhotoStream   = 1 << 5,       // ALAssetsGroupPhotoStream
    NBUAssetsGroupTypeAllALGroups   = 0xFFFF,       // All ALAssetsGroups
    
    // Groups from file directories
    NBUAssetsGroupTypeDirectory     = 1 << 16,
    
    NBUAssetsGroupTypeAll           = 0xFFFFFFFF    // All groups
};
typedef NSInteger NBUAssetsGroupType;

/// Error constants.
extern NSString * const NBUAssetsErrorDomain;
enum
{
    NBUAssetsFeatureNotAvailableInSystem4   = -101,
    NBUAssetsGroupAlreadyExists             = -102,
    NBUAssetsCouldntRetrieveSomeAssets      = -103
};

/**
 Wrapper to ease acces to the device ALAssetsLibrary media library.
 
 - Asynchronous and fully block-based.
 - Groups and assets are always valid.
 - Groups and images can be retrieved by URL even on iOS4.
 - Read and write access on iOS5+.
 - Create albums, add assets to a given album on iOS5+.
 - Detect permission restrictions on iOS6+.
 */
@interface NBUAssetsLibrary : NSObject

/// @name Shared Assets Library

/// Return a shared NBUAssetsLibrary singleton object.
+ (NBUAssetsLibrary *)sharedLibrary;

/// Set the shared library singleton object.
/// @param library The new shared library. Use nil to release the current object.
+ (void)setSharedLibrary:(NBUAssetsLibrary *)library;

/// @name Properties

/// Associated ALAssetsLibrary.
@property (strong, nonatomic, readonly)     ALAssetsLibrary * ALAssetsLibrary;

/// Register a local directory to automatically create and present a NBUAssetsGroup.
/// @discussion The library will use [NBUAssetsGroup groupForDirectoryURL:name:] to create the group.
/// @param directoryURL The target directory's URL.
/// @param name The optional name to be used for the NBUAssetsGroup.
- (void)registerDirectoryGroupforURL:(NSURL *)directoryURL
                                name:(NSString *)name;

/// @name Access Permissions

/// Whether the user has actively denied access to the library.
@property (nonatomic, readonly)             BOOL userDeniedAccess;

/// Whether parental controls have denied access to the library.
@property (nonatomic, readonly)             BOOL restrictedAccess;

/// @name Asset Groups

/// Retrieve all the groups that are associated to local directories.
/// @discussion Directories' URLs should first be registered using registerDirectoryGroupforURL:name:.
/// @param resultBlock The block to be called asynchronously with the results.
- (void)directoryGroupsWithResultBlock:(NBUAssetsGroupsResultBlock)resultBlock;

/// The group with all Camera Roll assets (ALAssetsGroupSavedPhotos).
/// @param resultBlock The block to be called asynchronously with the results.
- (void)cameraRollGroupWithResultBlock:(NBUAssetsGroupResultBlock)resultBlock;

/// The PhotoStream group with all Camera Roll assets (ALAssetsGroupPhotoStream).
/// @param resultBlock The block to be called asynchronously with the results.
- (void)photoStreamGroupWithResultBlock:(NBUAssetsGroupResultBlock)resultBlock;

/// The group with all iTunes synced assets (ALAssetsGroupLibrary).
/// @param resultBlock The block to be called asynchronously with the results.
- (void)photoLibraryGroupWithResultBlock:(NBUAssetsGroupResultBlock)resultBlock;

/// Album groups to mimic the device library (Camera Roll, PhotoStream, Photo Library and Albums).
/// @param resultBlock The block to be called asynchronously with the results.
- (void)albumGroupsWithResultBlock:(NBUAssetsGroupsResultBlock)resultBlock;

/// Retrieve all directory and AssetsLibrary assets groups in that order.
/// @param resultBlock The block to be called asynchronously with the results.
- (void)allGroupsWithResultBlock:(NBUAssetsGroupsResultBlock)resultBlock;

/// Retrieve the group of assets that correspons to a given URL.
/// @note Also works in iOS4.
/// @param groupURL A NSURL
/// @param resultBlock The block to be called asynchronously with the results.
- (void)groupForURL:(NSURL *)groupURL
        resultBlock:(NBUAssetsGroupResultBlock)resultBlock;

/// Retrieve a group by its name.
/// @param name The name of the group.
/// @param resultBlock The block to be called asynchronously with the results.
- (void)groupWithName:(NSString *)name
          resultBlock:(NBUAssetsGroupResultBlock)resultBlock;

/// Create a new group album (iOS5+). Returns an error if name already exists.
/// @param name The desired group name.
/// @param resultBlock The block to be called asynchronously with the results.
- (void)createAlbumGroupWithName:(NSString *)name
                     resultBlock:(NBUAssetsGroupResultBlock)resultBlock;

/// @name Retrieve Assets

/// Returns all assets in Camera Roll + Photo library.
/// @param resultBlock The block to be called asynchronously with the results.
- (void)allAssetsWithResultBlock:(NBUAssetsResultBlock)resultBlock;

/// Returns all image assets in Camera Roll + Photo library.
/// @param resultBlock The block to be called asynchronously with the results.
- (void)allImageAssetsWithResultBlock:(NBUAssetsResultBlock)resultBlock;

/// Returns all video assets in Camera Roll + Photo library.
/// @param resultBlock The block to be called asynchronously with the results.
- (void)allVideoAssetsWithResultBlock:(NBUAssetsResultBlock)resultBlock;

/// Retrieve the asset that corresponds to a given URL.
/// @param assetURL A NSURL.
/// @param resultBlock The block to be called asynchronously with the results.
/// @warning Make sure the URL does correspond to an image asset.
- (void)assetForURL:(NSURL *)assetURL
        resultBlock:(NBUAssetResultBlock)resultBlock;

/// Retrieve the assets that corresponds to the given URLs.
/// @param assetURLs An array of asset NSURL's.
/// @param resultBlock The block to be called asynchronously with the results.
/// @warning Make sure the URL does correspond to asset.
-(void)assetsForURLs:(NSArray*)assetURLs
         resultBlock:(NBUAssetsResultBlock)resultBlock;

/// @name Save Assets

/// Save an image to the Camera Roll.
/// @param image The image to save.
/// @param metadata Optional metadata dictionary.
/// @param resultBlock The block to be called asynchronously with the results.
- (void)saveImageToCameraRoll:(UIImage *)image
                     metadata:(NSDictionary *)metadata
                  resultBlock:(NBUAssetURLResultBlock)resultBlock;

/// Save an image to the Camera Roll and add to a given group (iOS5+).
/// @param image The image to save.
/// @param metadata Optional metadata dictionary.
/// @param name The target album's name. If an album with that name is not found a
/// new one may be created.
/// @param resultBlock The block to be called asynchronously with the results.
- (void)saveImageToCameraRoll:(UIImage *)image
                     metadata:(NSDictionary *)metadata
     addToAssetsGroupWithName:(NSString *)name
                  resultBlock:(NBUAssetURLResultBlock)resultBlock;

@end

