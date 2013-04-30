//
//  MyConfigurationPicker.m
//  NBUCoreDemo
//
//  Created by Ernesto Rivera on 2013/01/30.
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

#ifndef PRODUCTION

#import "MyConfigurationPicker.h"

@implementation MyConfigurationPicker

+ (BOOL)requiresRestart
{
    return NO;
}

// ** Required method **
+ (NSArray *)availableConfigurations
{
    return @[
             
             // Development
             @{
                 NBUConfigurationNameKey        : @"Development",
                 @"server"                      : @"localhost:80",
                 @"apiServer"                   : @"api.localhost:80",
                 @"protocol"                    : @"http",
                 @"token"                       : @"1234",
                 @"anotherParameter"            : @[@"An", @"array"]
                 },
             
             // Staging
             @{
                 NBUConfigurationNameKey        : @"Staging",
                 @"server"                      : @"stg.cyberagent.co.jp",
                 @"apiServer"                   : @"stg.api.cyberagent.co.jp",
                 @"protocol"                    : @"https",
                 @"token"                       : @"834-234982-34",
                 @"anotherParameter"            : @[@"Another", @"array"]
                 },
             
             // Production
             @{
                 NBUConfigurationNameKey        : ProductionConfigurationName,
                 @"server"                      : ProductionConnectionServer,
                 @"apiServer"                   : ProductionConnectionAPIServer,
                 @"protocol"                    : ProductionConnectionProtocol,
                 @"token"                       : ProductionConnectionToken,
                 @"anotherParameter"            : ProductionAnotherGlobalParameter
                 },
             
             ];
}

+ (NSString *)server
{
    return self.currentConfiguration[@"server"];
}

+ (NSString *)apiServer
{
    return self.currentConfiguration[@"apiServer"];
}

+ (NSString *)protocol
{
    return self.currentConfiguration[@"protocol"];
}

+ (NSString *)token
{
    return self.currentConfiguration[@"token"];
}

+ (NSArray *)anotherParameter
{
    return self.currentConfiguration[@"anotherParameter"];
}

@end

#endif

