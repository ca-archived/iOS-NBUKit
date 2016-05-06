//
//  NBULogContextDescription.h
//  NBULog
//
//  Created by Ernesto Rivera on 2013/10/09.
//  Copyright (c) 2012-2015 CyberAgent Inc.
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

#import "NBULog.h"

/// NBULogContextDescription blocks.
typedef DDLogLevel (^NBULogContextLevelBlock)();
typedef void (^NBULogSetContextLevelBlock)(DDLogLevel level);
typedef DDLogLevel (^NBULogContextLevelForModuleBlock)(int module);
typedef void (^NBULogSetContextLevelForModuleBlock)(int module, DDLogLevel level);

/**
 A log context description object used to describe its modules.
 
 A context description alows to have a description string and to specify blocks of code
 that can be used to dynamically modify log levels.
 */
@interface NBULogContextDescription : NSObject

/// @name Creating a Context Description

/// Create a new description object.
/// @param name The context name.
/// @param logContext The context constant value.
/// @param modulesAndNames An optional dictionary of modules constants and their descriptive names.
/// @param contextLevel A block used to retrieve the context's current log level.
/// @param setContextLevel A block used to set the contextLevel.
/// @param contextLevelForModule An optional block used to retrieve a context module's current log level.
/// @param setContextLevelForModule An optional block used to set a context module's log level.
+ (NBULogContextDescription *)descriptionWithName:(NSString *)name
                                          context:(int)logContext
                                  modulesAndNames:(NSDictionary *)modulesAndNames
                                contextLevelBlock:(NBULogContextLevelBlock)contextLevel
                             setContextLevelBlock:(NBULogSetContextLevelBlock)setContextLevel
                       contextLevelForModuleBlock:(NBULogContextLevelForModuleBlock)contextLevelForModule
                    setContextLevelForModuleBlock:(NBULogSetContextLevelForModuleBlock)setContextLevelForModule;

/// @name Properties

/// A context's descriptive name.
@property (strong, nonatomic, readonly) NSString * name;

/// The context's constant value.
@property (nonatomic, readonly)         int logContext;

/// The registered context's modules and their descriptive names.
@property (strong, nonatomic, readonly) NSDictionary * modulesAndNames;

/// An ordered array of module's constants.
@property (strong, nonatomic, readonly) NSArray * orderedModules;

/// The block to get the context's current log level.
@property (copy, nonatomic, readonly)   NBULogContextLevelBlock contextLevel;

/// The block to set the context's log level.
@property (copy, nonatomic, readonly)   NBULogSetContextLevelBlock setContextLevel;

/// The block used to retrieve a context module's current log level.
@property (copy, nonatomic, readonly)   NBULogContextLevelForModuleBlock contextLevelForModule;

/// The block used to set a context module's log level.
@property (copy, nonatomic, readonly)   NBULogSetContextLevelForModuleBlock setContextLevelForModule;

@end

