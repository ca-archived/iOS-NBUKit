//
//  NBUObjectViewController.m
//  NBUKit
//
//  Created by 利辺羅 on 2012/11/15.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import "NBUObjectViewController.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_UI

@implementation NBUObjectViewController
{
    BOOL _updatedNeeded;
    NSDictionary * _lastUserInfo;
}

@synthesize object = _object;
@synthesize ignoresObjectUpdates = _ignoresObjectUpdates;

#pragma mark - Handle object updates

- (void)objectUpdated:(NSDictionary *)userInfo
{
    // *** Override this method to update the UI ***
    // *** When this method is called both the object and the UI have been set ***
    
    NBULogVerbose(@"objectUpdated (%@ %p): userInfo: %@", NSStringFromClass([self class]), self, userInfo);
    _updatedNeeded = NO;
    _lastUserInfo = nil;
}

#pragma mark - Handle listening to object notifications

- (void)setObject:(id)object
{
    if (_object == object)
        return;
    
    // Stop observing previous object
    [self stopObservingUpdates];
    
    id oldObject = _object;
    _object = object;
    
    // Update the object
    if (self.isViewLoaded)
    {
        [self objectUpdated:oldObject ? @{
             NBUObjectUpdatedTypeKey : NBUObjectUpdatedTypeNewObject,
             NBUObjectUpdatedOldObjectKey : oldObject
         } : @{
             NBUObjectUpdatedTypeKey : NBUObjectUpdatedTypeNewObject
         }];
    }
    else
    {
        // Can't be done now...
        _updatedNeeded = YES;
        _lastUserInfo = @{@"updateType" : @"newObject"};
    }
    
    // Start observing new object
    if (!_ignoresObjectUpdates)
    {
        [self startObservingUpdates];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Update needed?
    if (_updatedNeeded)
    {
        [self objectUpdated:_lastUserInfo];
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
    if (_object)
    {
        // Add observer
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_objectUpdated:)
                                                     name:NBUObjectUpdatedNotification
                                                   object:_object];
    }
}

- (void)_objectUpdated:(NSNotification *)notification
{
    // Update the object
    if (self.isViewLoaded)
    {
        [self objectUpdated:notification.userInfo];
    }
    else
    {
        // Can't be done now...
        _updatedNeeded = YES;
        
        // Merge userInfo dictonaries?
        if (_lastUserInfo)
        {
            NSMutableDictionary * tmp = [NSMutableDictionary dictionaryWithDictionary:_lastUserInfo];
            [tmp addEntriesFromDictionary:notification.userInfo];
            _lastUserInfo = tmp;
        }
        else
        {
            _lastUserInfo = notification.userInfo;
        }
    }
}

- (void)stopObservingUpdates
{
    if (_object)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NBUObjectUpdatedNotification
                                                      object:_object];
    }
}

- (void)dealloc
{
    // Remove observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end

