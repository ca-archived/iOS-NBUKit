//
//  NBUMockHelper.h
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/08/09.
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

typedef void (^NBUMockObjectConfigurationBlock)(id object, int recursivityLevel);

/**
 A block-configurable generator of mock objects for fast prototyping.
 
 Supports generation of general and CoreData mock objects.
 
 Sample usage:
 
     NBUMockHelper * mockHelper = [NBUMockHelper sharedHelper];
     
     // Generate from 4 to 10 NSObject's
     NSLog(@"%@", [mockHelper generateFrom:4
                                        to:10
                               mockObjects:@"NSObject"]);
     
     // Generate 5 NSMutableString and configure them wiht a configuration block
     
     [mockHelper setConfigurationBlock: 
        ^(NSMutableString * string, int recursivityLevel) // Modified from ^(id object, int recursivityLevel) to avoid castings
         {
             // Set a random string
             [string setString:[NSString stringWithFormat:@"String #%d", (arc4random() % 100)]];
         }
                         forClassNamed:@"NSMutableString"];
     
     NSLog(@"%@", [mockHelper generate:5
                           mockObjects:@"NSMutableString"]);
 
 Prints:
 
     (
         "<NSObject: 0x8e64c70>",
         "<NSObject: 0x8e631d0>",
         "<NSObject: 0x8e63aa0>",
         "<NSObject: 0x8e67590>",
         "<NSObject: 0x8e675a0>",
         "<NSObject: 0x8e642f0>",
         "<NSObject: 0x8e67ec0>",
         "<NSObject: 0x8e67ed0>",
         "<NSObject: 0x8e67ee0>",
         "<NSObject: 0x8e63c60>"
     )
     
     (
         "String #79",
         "String #62",
         "String #43",
         "String #86",
         "String #80"
     )
 */
@interface NBUMockHelper : NSObject

/// @ Getting a Helper

/// Return a shared NBUMockHelper singleton object.
+ (NBUMockHelper *)sharedHelper;

/// Set the shared NBUMockHelper singleton object.
/// @param helper The new shared helper. Use nil to release the current object.
+ (void)setSharedHelper:(NBUMockHelper *)helper;

/// @name Configure the Helper

/// Sets a block to be used to configure newly created blocks of a given class.
/// @param block The block that receives the new object of a given class and a recursivityLevel integer to
/// avoid infinity loops.
/// @param name The name of the class of the target mock object.
/// @note The recursivityLevel is not yet used.
- (void)setConfigurationBlock:(NBUMockObjectConfigurationBlock)block
                forClassNamed:(NSString *)name;

/// @name Configure the Helper for CoreData Objects

/// The NSManagedObjectContext to be used to create new CoreData mock objects.
@property (nonatomic, strong) NSManagedObjectContext * managedObjectContext;

/// Sets a block to be used to configure newly created blocks of a given CoreData entity.
/// @param block The block that receives the new managed object of a given antity and a recursivityLevel integer to
/// avoid infinity loops.
/// @param name The name of the CoreData entity of the target mock object.
/// @note The recursivityLevel is not yet used.
- (void)setConfigurationBlock:(NBUMockObjectConfigurationBlock)block
               forEntityNamed:(NSString *)name;

/// @name Using the Helper

/// Generate one mock object of a given class or CoreData entity.
/// @param nameOfClassOrEntity The name of the class or CoreData entity.
- (id)generateMockObject:(NSString *)nameOfClassOrEntity;

/// Generate several mock objects of a given class or CoreData entity.
/// @param count The number of mock objects to be created.
/// @param nameOfClassOrEntity The name of the class or CoreData entity.
- (NSArray *)generate:(NSUInteger)count
          mockObjects:(NSString *)nameOfClassOrEntity;

/// Generate several mock objects of a given class or CoreData entity.
/// @param minCount The minimum number of mock objects to be created.
/// @param maxCount The maximum number of mock objects to be created.
/// @param nameOfClassOrEntity The name of the class or CoreData entity.
- (NSArray *)generateFrom:(NSUInteger)minCount
                       to:(NSUInteger)maxCount
              mockObjects:(NSString *)nameOfClassOrEntity;

/// @name Utilities

/// Generate _Lorem Impsum_ mock text of a given lenght.
/// @param length The desired mock text lenght.
+ (NSString *)mockTextWithLenght:(NSUInteger)length;

@end

