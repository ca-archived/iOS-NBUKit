//
//  NSArray+NBUAdditions.h
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

/**
 Convenience NSArray methods to retrieve the previous/next elements with/without wrapping.
 */
@interface NSArray (NBUAdditions)

/// @name Retrieve Objects

/// Get the previous object without wrap.
/// @param object The reference object.
/// @return The previous object or `nil` if not found.
- (id)objectBefore:(id)object;

/// Get the previous object with ot without wrap.
/// @param object The reference object.
/// @param wrap Whether to cirularly wrap the array to get the previous element.
/// @return The previous object or `nil` if not found.
- (id)objectBefore:(id)object
              wrap:(BOOL)wrap;

/// Get the next object without wrap.
/// @param object The reference object.
/// @return The next object or `nil` if not found.
- (id)objectAfter:(id)object;

/// Get the next object with ot without wrap.
/// @param object The reference object.
/// @param wrap Whether to cirularly wrap the array to get the next element.
/// @return The next object or `nil` if not found.
- (id)objectAfter:(id)object
             wrap:(BOOL)wrap;

/// A "shorter" description method that tries avoid spanning into multiple lines.
- (NSString *)shortDescription;

@end

