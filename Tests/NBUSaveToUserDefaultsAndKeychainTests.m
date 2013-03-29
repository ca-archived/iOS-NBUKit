//
//  NBUSaveToUserDefaultsAndKeychainTests.m
//  NBUKit
//
//  Created by 利辺羅 on 2012/09/21.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import "NBUSaveToUserDefaultsAndKeychainTests.h"

@implementation NBUSaveToUserDefaultsAndKeychainTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (NSString *)createString
{
    return [NSString stringWithFormat:@"test string %d", arc4random() % 11];
}

- (NSArray *)createArray
{
    return [NSArray arrayWithObjects:[self createString], [self createString], [self createString], [self createString], [self createString], nil];
}

- (NSDictionary *)createDictionary
{
    return [NSDictionary dictionaryWithObjects:[self createArray]
                                       forKeys:[NSArray arrayWithObjects:@"key 1", @"key 2", @"key 3", @"key 4", @"key 5", nil]];
}

- (id)createObjectTree
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [self createString], @"key 1",
            [[self createArray] arrayByAddingObject:[self createArray]], @"key 2",
            [self createDictionary], @"key 3",
            [self createData], @"key 4",
            [[self createArray] arrayByAddingObject:[self createData]], @"key 5",
            nil];
}

- (NSData *)createData
{
    NSBundle * bundle = [NSBundle bundleForClass:[self class]];
    NSString * imagePath = [bundle pathForResource:@"Icon"
                                            ofType:@"png"];
    UIImage * testImage = [UIImage imageWithContentsOfFile:imagePath];
    STAssertNotNil(testImage, @"Test image could not me read");
    NSData * data = UIImagePNGRepresentation(testImage);
    STAssertNotNil(data, @"Test data could be created");
    return data;
}

#pragma mark - Normal save

- (void)testSaveReadAndDeleteString
{
    // Save
    NSString * original = [self createString];
    [UIApplication setObject:original
                      forKey:@"test key"];
    
    // Read
    NSString * saved = [UIApplication objectForKey:@"test key"];
    STAssertTrue([original isEqualToString:saved],
                 @"Original and saved strings are not equal!: %@ != %@", original, saved);
    
    // Delete
    [UIApplication setObject:nil
                      forKey:@"test key"];
    saved = [UIApplication objectForKey:@"test key"];
    STAssertNil(saved, @"Object was not deleted");
}

- (void)testSaveReadAndDeleteArray
{
    // Save
    NSArray * original = [self createArray];
    [UIApplication setObject:original
                      forKey:@"test key"];
    
    // Read
    NSArray * saved = [UIApplication objectForKey:@"test key"];
    STAssertTrue([original isEqualToArray:saved],
                 @"Original and saved arrays are not equal!: %@ != %@", original, saved);
    
    // Delete
    [UIApplication setObject:nil
                      forKey:@"test key"];
    saved = [UIApplication objectForKey:@"test key"];
    STAssertNil(saved, @"Object was not deleted");
}

- (void)testSaveReadAndDeleteDictionary
{
    // Save
    NSDictionary * original = [self createDictionary];
    [UIApplication setObject:original
                      forKey:@"test key"];
    
    // Read
    NSDictionary * saved = [UIApplication objectForKey:@"test key"];
    STAssertTrue([original isEqualToDictionary:saved],
                 @"Original and saved arrays are not equal!: %@ != %@", original, saved);
    
    // Delete
    [UIApplication setObject:nil
                      forKey:@"test key"];
    saved = [UIApplication objectForKey:@"test key"];
    STAssertNil(saved, @"Object was not deleted");
}

- (void)testSaveReadAndDeleteData
{
    // Save
    NSData * original = [self createData];
    [UIApplication setObject:original
                      forKey:@"test key"];
    
    // Read
    NSData * saved = [UIApplication objectForKey:@"test key"];
    STAssertTrue([original isEqualToData:saved],
                 @"Original and saved data are not equal!: %@ != %@", original, saved);
    
    // Delete
    [UIApplication setObject:nil
                      forKey:@"test key"];
    saved = [UIApplication objectForKey:@"test key"];
    STAssertNil(saved, @"Object was not deleted");
}

- (void)testSaveReadAndDeleteObjectTree
{
    // Save
    id original = [self createObjectTree];
    [UIApplication setObject:original
                      forKey:@"test key"];
    
    // Read
    id saved = [UIApplication objectForKey:@"test key"];
    STAssertTrue([original isEqual:saved],
                 @"Original and saved object tree are not equal!: %@ != %@", original, saved);
    
    // Delete
    [UIApplication setObject:nil
                      forKey:@"test key"];
    saved = [UIApplication objectForKey:@"test key"];
    STAssertNil(saved, @"Object was not deleted");
}

#pragma mark - Secure save

- (void)testSecureSaveReadAndDeleteString
{
    // Save
    NSString * original = [self createString];
    [UIApplication setSecureObject:original
                            forKey:@"test key"];
    
    // Read
    NSString * saved = [UIApplication secureObjectForKey:@"test key"];
    STAssertTrue([original isEqualToString:saved],
                 @"Original and saved strings are not equal!: %@ != %@", original, saved);
    
    // Delete
    [UIApplication setSecureObject:nil
                            forKey:@"test key"];
    saved = [UIApplication objectForKey:@"test key"];
    STAssertNil(saved, @"Object was not deleted");
}

- (void)TODOtestSecureSaveReadAndDeleteArray
{
    // Save
    NSArray * original = [self createArray];
    [UIApplication setSecureObject:original
                            forKey:@"test key"];
    
    // Read
    NSArray * saved = [UIApplication secureObjectForKey:@"test key"];
    STAssertTrue([original isEqualToArray:saved],
                 @"Original and saved arrays are not equal!: %@ != %@", original, saved);
    
    // Delete
    [UIApplication setSecureObject:nil
                            forKey:@"test key"];
    saved = [UIApplication objectForKey:@"test key"];
    STAssertNil(saved, @"Object was not deleted");
}

- (void)TODOtestSecureSaveReadAndDeleteDictionary
{
    // Save
    NSDictionary * original = [self createDictionary];
    [UIApplication setSecureObject:original
                            forKey:@"test key"];
    
    // Read
    NSDictionary * saved = [UIApplication secureObjectForKey:@"test key"];
    STAssertTrue([original isEqualToDictionary:saved],
                 @"Original and saved arrays are not equal!: %@ != %@", original, saved);
    
    // Delete
    [UIApplication setSecureObject:nil
                            forKey:@"test key"];
    saved = [UIApplication objectForKey:@"test key"];
    STAssertNil(saved, @"Object was not deleted");
}

- (void)TODOtestSecureSaveReadAndDeleteData
{
    // Save
    NSData * original = [self createData];
    [UIApplication setSecureObject:original
                            forKey:@"test key"];
    
    // Read
    NSData * saved = [UIApplication secureObjectForKey:@"test key"];
    STAssertTrue([original isEqualToData:saved],
                 @"Original and saved data are not equal!: %@ != %@", original, saved);
    
    // Delete
    [UIApplication setSecureObject:nil
                            forKey:@"test key"];
    saved = [UIApplication objectForKey:@"test key"];
    STAssertNil(saved, @"Object was not deleted");
}

- (void)TODOtestSecureSaveReadAndDeleteObjectTree
{
    // Save
    id original = [self createObjectTree];
    [UIApplication setSecureObject:original
                            forKey:@"test key"];
    
    // Read
    id saved = [UIApplication secureObjectForKey:@"test key"];
    STAssertTrue([original isEqual:saved],
                 @"Original and saved object tree are not equal!: %@ != %@", original, saved);
    
    // Delete
    [UIApplication setSecureObject:nil
                            forKey:@"test key"];
    saved = [UIApplication objectForKey:@"test key"];
    STAssertNil(saved, @"Object was not deleted");
}

@end

