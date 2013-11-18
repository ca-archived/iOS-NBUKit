//
//  NBULogContextDescription.m
//  NBULog
//
//  Created by Ernesto Rivera on 2013/10/09.
//  Copyright (c) 2012-2013 CyberAgent Inc.
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

#import "NBULogContextDescription.h"

@implementation NBULogContextDescription

+ (NBULogContextDescription *)descriptionWithName:(NSString *)name
                                          context:(int)logContext
                                  modulesAndNames:(NSDictionary *)modulesAndNames
                                contextLevelBlock:(NBULogContextLevelBlock)contextLevel
                             setContextLevelBlock:(NBULogSetContextLevelBlock)setContextLevel
                       contextLevelForModuleBlock:(NBULogContextLevelForModuleBlock)contextLevelForModule
                    setContextLevelForModuleBlock:(NBULogSetContextLevelForModuleBlock)setContextLevelForModule
{
    NBULogContextDescription * description = [NBULogContextDescription new];
    description->_name = name;
    description->_logContext = logContext;
    description->_modulesAndNames = modulesAndNames;
    description->_orderedModules = [modulesAndNames.allKeys sortedArrayUsingSelector:@selector(compare:)];
    description->_contextLevel = contextLevel;
    description->_setContextLevel = setContextLevel;
    description->_contextLevelForModule = contextLevelForModule;
    description->_setContextLevelForModule = setContextLevelForModule;
    return description;
}

@end

