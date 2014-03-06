//
//  NSArray+NBUAdditions.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/10/16.
//  Copyright (c) 2012-2014 CyberAgent Inc.
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

#import "NSArray+NBUAdditions.h"
#import "NBUKitPrivate.h"

@implementation NSArray (NBUAdditions)

#pragma mark - Retrieve objects

- (id)objectBefore:(id)object
{
    return [self objectBefore:object
                         wrap:NO];
}

- (id)objectBefore:(id)object
              wrap:(BOOL)wrap
{
    NSUInteger index = [self indexOfObject:object];
    
    if (index == NSNotFound ||                  // Not found?
        (!wrap && index == 0))                  // Or no wrap and was first object?
        return nil;
    
    index = (index - 1 + self.count) % self.count;
    return self[index];
}

- (id)objectAfter:(id)object
{
    return [self objectAfter:object
                        wrap:NO];
}

- (id)objectAfter:(id)object
             wrap:(BOOL)wrap
{
    NSUInteger index = [self indexOfObject:object];
    
    if (index == NSNotFound ||                  // Not found?
        (!wrap && index == self.count - 1))     // Or no wrap and was last object?
        return nil;
    
    index = (index + 1) % self.count;
    return self[index];
}

- (NSString *)shortDescription
{
    return [NSString stringWithFormat:@"(%@)", [self componentsJoinedByString:@", "]];
}

@end

