//
//  NBUKitTests.m
//  NBUKitTests
//
//  Created by Ernesto Rivera on 2012/12/14.
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

#import "NBUKitTests.h"

@implementation NBUKitTests

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

- (void)waitBlockUntilFinished:(void (^)(BOOL * finished))block
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

@end

