//
//  NBUFilterGroup.m
//  NBUKit
//
//  Created by 利辺羅 on 2013/03/05.
//  Copyright (c) 2013年 CyberAgent Inc. All rights reserved.
//

#import "NBUFilterGroup.h"
#import "NBUFilterProvider.h"

NSString * const NBUFilterTypeGroup = @"NBUFilterTypeGroup";

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

