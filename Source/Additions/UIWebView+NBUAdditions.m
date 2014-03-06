//
//  UIWebView+NBUAdditions.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/09/25.
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

#import "UIWebView+NBUAdditions.h"
#import "NBUKitPrivate.h"

static NSString * _systemDefaultUserAgent;

@implementation UIWebView (NBUAdditions)

+ (NSString *)systemDefaultUserAgent
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIWebView * tmpWebView = [UIWebView new];
        _systemDefaultUserAgent = tmpWebView.userAgent;
    });
    return _systemDefaultUserAgent;
}

+ (void)setDefaultUserAgent:(NSString *)userAgent
{
    NBULogInfo(@"setDefaultUserAgent: %@", userAgent);
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent" : userAgent}];
}

- (NSString *)title
{
    return [self stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (NSString *)userAgent
{
    return [self stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
}

- (void)fireEvent:(NSString *)event
{
    NBULogVerbose(@"fireEvent: %@", event);
    
    [self stringByEvaluatingJavaScriptFromString:
     [NSString stringWithFormat:@"try{cordova.fireDocumentEvent('%@');}catch(e){console.log('Exception firing %@ event');};",
      event, event]];
}

- (void)fireEvent:(NSString *)event
   withDictionary:(NSDictionary *)dictionary
{
    NBULogVerbose(@"fireEvent: %@ withDictionary: %@", event, dictionary);
    
    [self stringByEvaluatingJavaScriptFromString:
     [NSString stringWithFormat:@"try{cordova.fireDocumentEvent('%@',%@);}catch(e){console.log('Exception firing %@ event');};",
      event, [self convertToJavaScriptDictionary:dictionary], event]];
}

- (NSString *)convertToJavaScriptDictionary:(NSDictionary *)dictionary
{
    return [[[dictionary description]
             stringByReplacingOccurrencesOfString:@"=" withString:@":"]
            stringByReplacingOccurrencesOfString:@";" withString:@","];
}

@end

