//
//  UIResponder+NBUAdditions.m
//  NBUKit
//
//  Created by Wirth Caesar on 2012/08/08.
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

#import "UIResponder+NBUAdditions.h"
#import "NBUKitPrivate.h"

@implementation UIResponder (NBUAdditions)

- (BOOL)sendAction:(SEL)action
              from:(id)sender
          forEvent:(UIEvent*)event
{
    if([self canPerformAction:action withSender:sender]) {
        // This is fishy, so it needs some explanation
        // ARC performs its magic in part based on method names
        // ie. newObject vs object determines whether it retains it or not
        // Since we are passing in an unknown selector, the compiler doesn't know
        // if it has to deal with the memory.
        // Without the diagnostic ignores, you will get a warning:
        // "PerformSelector may cause a leak because its selector is unknown"
        // So as long as you don't call methods that it has to release/autorelease the output of,
        // you should be OK
        // Source: http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:action withObject:sender];
#pragma clang diagnostic pop
        return YES;
    } 
    // Try the next one if there is one
    else if(self.nextResponder) {
        return [self.nextResponder sendAction:action from:sender forEvent:event];
    }
    
    // Otherwise it cannot be handled
    return NO;
}

@end

