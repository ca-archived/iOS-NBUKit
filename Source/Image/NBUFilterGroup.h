//
//  NBUFilterGroup.h
//  NBUKit
//
//  Created by Ernesto Rivera on 2013/03/05.
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

#import "NBUFilter.h"

/**
 A container for a group of NBUFilter objects.
 */
@interface NBUFilterGroup : NBUFilter

/// Create a new NBUFilterGroup of a given type, optionally setting a given name and initial filters.
/// @param name An optional filter group name.
/// @param type An optional filter group type.
/// @param filters The optional initial filters.
+ (id)filterGroupWithName:(NSString *)name
                     type:(NSString *)type
                  filters:(NSArray *)filters;

/// The group's filters.
@property (strong, nonatomic) NSArray * filters;

@end

