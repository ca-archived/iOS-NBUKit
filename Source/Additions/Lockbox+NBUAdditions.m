//
//  Lockbox+NBUAdditions.m
//  NBUCore
//
//  Created by Ernesto Rivera on 12/06/20.
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

#import "Lockbox+NBUAdditions.h"
#import "NBUCorePrivate.h"

@implementation Lockbox (NBUAdditions)

+ (BOOL)setDictionary:(NSDictionary *)value forKey:(NSString *)key
{
    NSMutableArray * keysAndValues = [NSMutableArray arrayWithArray:value.allKeys];
    [keysAndValues addObjectsFromArray:value.allValues];
    
    return [Lockbox setArray:keysAndValues
                      forKey:key];
}

+ (NSDictionary *)dictionaryForKey:(NSString *)key
{
    NSArray * keysAndValues = [Lockbox arrayForKey:key];
    
    if (!keysAndValues || keysAndValues.count == 0)
        return nil;
    
    if ((keysAndValues.count % 2) != 0)
    {
        NBULogWarn(@"Dictionary for %@ was not saved properly to keychain", key);
        return nil;
    }
    
    NSUInteger half = keysAndValues.count / 2;
    NSRange keys = NSMakeRange(0, half);
    NSRange values = NSMakeRange(half, half);
    return [NSDictionary dictionaryWithObjects:[keysAndValues subarrayWithRange:values] 
                                       forKeys:[keysAndValues subarrayWithRange:keys]];
}

@end

