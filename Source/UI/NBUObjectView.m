//
//  NBUObjectView.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/11/15.
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

#import "NBUObjectView.h"
#import "NBUKitPrivate.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_UI

NSString * const NBUObjectUpdatedNotification   = @"NBUObjectUpdatedNotification";
NSString * const NBUObjectUpdatedTypeKey        = @"NBUObjectUpdatedType";
NSString * const NBUObjectUpdatedTypeNewObject  = @"NBUObjectUpdatedTypeNewObject";
NSString * const NBUObjectUpdatedOldObjectKey   = @"NBUObjectUpdatedOldObject";

@implementation NBUObjectView

@dynamic object;

#pragma mark - Handle object updates

- (void)objectUpdated:(NSDictionary *)userInfo
{
    // *** Override this method to update the UI ***
    
    NBULogVerbose(@"objectUpdated (%@ %p): userInfo: %@", NSStringFromClass([self class]), self, userInfo);
}

#pragma mark - Handle listening to object notifications

- (void)setObject:(id)object
{
    if (self.object == object)
        return;
    
    // Stop observing previous object
    [self stopObservingUpdates];
    
    id oldObject = self.object;
    super.object = object;
    
    // Update the object
    [self objectUpdated:oldObject ? @{
        NBUObjectUpdatedTypeKey : NBUObjectUpdatedTypeNewObject,
        NBUObjectUpdatedOldObjectKey : oldObject
     } : @{
        NBUObjectUpdatedTypeKey : NBUObjectUpdatedTypeNewObject
     }];
    
    // Start observing new object
    if (!_ignoresObjectUpdates && object)
    {
        [self startObservingUpdates];
    }
}

- (void)setIgnoresObjectUpdates:(BOOL)ignoresObjectUpdates
{
    if (_ignoresObjectUpdates == ignoresObjectUpdates)
        return;
    
    _ignoresObjectUpdates = ignoresObjectUpdates;
    
    if (!ignoresObjectUpdates)
    {
        [self startObservingUpdates];
    }
    else
    {
        [self stopObservingUpdates];
    }
}

- (void)startObservingUpdates
{
    if (self.object)
    {
        // Add observer
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_objectUpdated:)
                                                     name:NBUObjectUpdatedNotification
                                                   object:self.object];
    }
    else
    {
        NBULogError(@"Can't start observing object updates with a %@ object!", self.object);
    }
}

- (void)_objectUpdated:(NSNotification *)notification
{
    [self objectUpdated:notification.userInfo];
}

- (void)stopObservingUpdates
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NBUObjectUpdatedNotification
                                                  object:self.object];
}

- (void)dealloc
{
    // Remove observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

