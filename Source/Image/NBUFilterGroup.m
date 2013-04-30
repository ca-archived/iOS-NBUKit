//
//  NBUFilterGroup.m
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

#import "NBUFilterGroup.h"
#import "NBUFilterProvider.h"

@implementation NBUFilterGroup

@synthesize filters = _filters;

+ (id)filterGroupWithName:(NSString *)name
                     type:(NSString *)type
                  filters:(NSArray *)filters
{
    NBUFilterGroup * filterGroup = [NBUFilterGroup filterWithName:name
                                                             type:type ? type : NBUFilterTypeGroup
                                                           values:nil
                                                    defaultValues:nil
                                                   identityValues:nil
                                                       attributes:nil
                                                         provider:nil
                                             configureFilterBlock:NULL];
    filterGroup.filters = filters;
    
    return filterGroup;
}

- (NSString *)description
{
    NSString * description = super.description;
    
    if (self.enabled)
    {
        description = [description stringByReplacingOccurrencesOfString:@">"
                                                             withString:
                       [NSString stringWithFormat:@" %@>", _filters.shortDescription]];
    }
    
    return description;
}

- (void)setConfigurationDictionary:(NSDictionary *)configurationDictionary
{
    super.configurationDictionary = configurationDictionary;
    
    _filters = [NSMutableArray array];
    NSArray * filtersConfigurations = configurationDictionary[@"filters"];
    NBUFilter * filter;
    for (NSDictionary * configuration in filtersConfigurations)
    {
        filter = [NBUFilterProvider filterWithName:nil
                                              type:configuration[@"type"]
                                            values:nil];
        if (!filter)
        {
            NBULogWarn(@"A filter couldn't be created for configuration: %@", configuration);
            continue;
        }
        filter.configurationDictionary = configuration;
        
        [(NSMutableArray *)_filters addObject:filter];
    }
}

- (NSDictionary *)configurationDictionary
{
    NSMutableDictionary * configuration = [NSMutableDictionary dictionaryWithDictionary:super.configurationDictionary];
    
    // Add filters' configurations
    NSMutableArray * filtersConfiguration = [NSMutableArray arrayWithCapacity:_filters.count];
    for (NBUFilter * filter in _filters)
    {
        [filtersConfiguration addObject:filter.configurationDictionary];
    }
    configuration[@"filters"] = filtersConfiguration;
    
    return configuration;
}

@end

