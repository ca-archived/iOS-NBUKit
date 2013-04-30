//
//  NSArray+NBUAdditionsTests.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/10/18.
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

#import "NSArray+NBUAdditionsTests.h"
#import "NSArray+NBUAdditions.h"

@implementation NSArray_NBUAdditionsTests
{
    NSArray * _emptyArray;
    NSArray * _testArray;
}

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    _testArray = @[@"0", @"1", @"2", @"3"];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

#pragma mark - Retrieve objects

- (void)test0NotFound
{
    STAssertNil([_testArray objectBefore:@"X"], @"Non existent object's previous object should be nil");
    STAssertNil([_testArray objectAfter:@"X"], @"Non existent object's next object should be nil");
}

- (void)test1RetriveObjectNoWrap
{
    STAssertEqualObjects([_testArray objectBefore:@"2"], @"1", @"Failed to retrieve previous object");
    STAssertEqualObjects([_testArray objectBefore:@"0"], nil, @"First object's previous should be nil");
    STAssertEqualObjects([_testArray objectAfter:@"2"], @"3", @"Failed to retrieve next object");
    STAssertEqualObjects([_testArray objectAfter:@"3"], nil, @"Last object's next should be nil");
}

- (void)test2RetriveObjectWrap
{
    STAssertEqualObjects([_testArray objectBefore:@"2" wrap:YES], @"1", @"Failed to retrieve previous object");
    STAssertEqualObjects([_testArray objectBefore:@"0" wrap:YES], @"3", @"Failed to retrieve first object's previous object");
    STAssertEqualObjects([_testArray objectAfter:@"2" wrap:YES], @"3", @"Failed to retrieve next object");
    STAssertEqualObjects([_testArray objectAfter:@"3" wrap:YES], @"0", @"Failed to retrieve last object's next object");
}

@end

