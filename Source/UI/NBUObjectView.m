//
//  NBUObjectView.m
//  NBUKit
//
//  Created by 利辺羅 on 2012/11/15.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import "NBUObjectView.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_UI

NSString * const NBUObjectUpdatedNotification   = @"NBUObjectUpdatedNotification";
NSString * const NBUObjectUpdatedTypeKey        = @"NBUObjectUpdatedTypeKey";
NSString * const NBUObjectUpdatedTypeNewObject  = @"NBUObjectUpdatedTypeNewObject";
NSString * const NBUObjectUpdatedOldObjectKey         = @"NBUObjectUpdatedOldObjectKey";

@implementation NBUObjectView

@dynamic object;
@synthesize ignoresObjectUpdates = _ignoresObjectUpdates;

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

