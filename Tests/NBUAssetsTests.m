//
//  NBUAssetsTests.m
//  NBUKit
//
//  Created by 利辺羅 on 2013/02/20.
//  Copyright (c) 2013年 CyberAgent Inc. All rights reserved.
//

#import "NBUAssetsTests.h"

static NSMutableArray * _assetURLs;

@implementation NBUAssetsTests

+ (void)initialize
{
    _assetURLs = [NSMutableArray array];
}

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    [DDLog flushLog];
    
    [super tearDown];
}

- (void)waitBlockUntilFinished:(void(^)(BOOL * finished))block
{
    BOOL finished = NO;
    
    block(&finished);
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !finished){};
}

- (UIImage *)imageNamed:(NSString *)name
{
    NSBundle * bundle = [NSBundle bundleForClass:[self class]];
    NSString * imagePath = [bundle pathForResource:name
                                            ofType:nil];
    UIImage * testImage = [UIImage imageWithContentsOfFile:imagePath];
    STAssertNotNil(testImage, @"Test image couldn't be read");
    
    return testImage;
}

#pragma mark - NBUAssetsLibrary

- (void)test0SaveImageToCameraRoll
{
    [self waitBlockUntilFinished:^(BOOL * finished)
    {
        [[NBUAssetsLibrary sharedLibrary] saveImageToCameraRoll:[self imageNamed:@"photo.jpg"]
                                                       metadata:nil
                                                    resultBlock:^(NSURL * assetURL,
                                                                  NSError * error)
         {
             STAssertNil(error, @"Error saving image %@", error);
             STAssertNotNil(assetURL, @"No assetURL was returned");
             [_assetURLs addObject:assetURL];
             
             * finished = YES;
         }];
    }];
}

- (void)test0SaveImageToCameraRollAndAddToAssetsGroup
{
    [self waitBlockUntilFinished:^(BOOL * finished)
     {
         [[NBUAssetsLibrary sharedLibrary] saveImageToCameraRoll:[self imageNamed:@"photo.jpg"]
                                                        metadata:nil
                                        addToAssetsGroupWithName:@"NBUKitTests"
                                                     resultBlock:^(NSURL * assetURL,
                                                                   NSError * error)
          {
              STAssertNil(error, @"Error saving image %@", error);
              STAssertNotNil(assetURL, @"No assetURL was returned");
              [_assetURLs addObject:assetURL];
              
              * finished = YES;
          }];
     }];
}

- (void)test1RetrieveAsset
{
    STAssertTrue(_assetURLs.count >= 1, @"No assetURLs defined");
    
    [self waitBlockUntilFinished:^(BOOL * finished)
     {
         [[NBUAssetsLibrary sharedLibrary] assetForURL:_assetURLs[0]
                                           resultBlock:^(NBUAsset * imageAsset,
                                                         NSError * error)
          {
              STAssertNil(error, @"Error retrieving image: %@", error);
              STAssertNotNil(imageAsset, @"No imageAsset was returned");
              
              * finished = YES;
          }];
     }];
}

- (void)test1RetrieveAssetWithInvalidURL
{
    [self waitBlockUntilFinished:^(BOOL * finished)
     {
         [[NBUAssetsLibrary sharedLibrary] assetForURL:[NSURL URLWithString:@"assets-library://invalid/url"]
                                           resultBlock:^(NBUAsset * imageAsset,
                                                         NSError * error)
          {
              STAssertNil(error, @"Error retrieving image with invalid URL: %@", error);
              STAssertNil(imageAsset, @"Asset returned for invalid URL: %@", imageAsset);
              
              * finished = YES;
          }];
     }];
}

- (void)test1RetrieveMultipleAssets
{
    STAssertTrue(_assetURLs.count >= 2, @"Not enough assetURLs defined: %@", _assetURLs);
    
    [self waitBlockUntilFinished:^(BOOL * finished)
     {
         [[NBUAssetsLibrary sharedLibrary] assetsForURLs:_assetURLs
                                             resultBlock:^(NSArray * assets,
                                                           NSError * error)
          {
              STAssertNil(error, @"Error retrieving images: %@", error);
              STAssertTrue(assets.count, @"No assets were returned");
              STAssertTrue(assets.count == _assetURLs.count,
                           @"Not all assets were returned (received %d, expected %d)",
                           assets.count, _assetURLs.count);
              
              * finished = YES;
          }];
     }];
}

@end


