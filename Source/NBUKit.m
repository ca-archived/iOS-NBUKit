//
//  NBUKit.m
//  NBUKit
//
//  Created by 利辺羅 on 12/07/11.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import "NBUKit.h"

static NSBundle * _resourcesBundle;

@implementation NBUKit

+ (void)initialize
{
    NBULogInfo(@"NBUKit %@ initialized...", [self version]);
}

+ (NSString *)version
{
    return @"1.7.0";
}

+ (NSBundle *)resourcesBundle
{
    if (!_resourcesBundle)
    {
        NSString * resourcesPath = [[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:@"NBUKitResources.bundle"];
        _resourcesBundle = [NSBundle bundleWithPath:resourcesPath];
    }
    return _resourcesBundle;
}

@end

