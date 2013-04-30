//
//  NBUAssetsTests.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2013/02/20.
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

#import "NBUAssetsTests.h"

static NSMutableArray * _assetURLs;

@implementation NBUAssetsTests

+ (void)initialize
{
    _assetURLs = [NSMutableArray array];
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

- (void)test1SaveImageToCameraRollAndAddToAssetsGroup
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

- (void)test2RetrieveAsset
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

- (void)test3RetrieveAssetWithInvalidURL
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

- (void)test4RetrieveMultipleAssets
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


