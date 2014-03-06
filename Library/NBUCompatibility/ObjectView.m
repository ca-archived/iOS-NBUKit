//
//  ObjectView.m
//  NBUCompatibility
//
//  Created by Ernesto Rivera on 2012/02/07.
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

#import "ObjectView.h"
#import "NBUKitPrivate.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_COMPATIBILITY

NSString * const ObjectDeletedNotification = @"ObjectDeletedNotification";

// Private class
@interface ObjectViewMask : ActiveView
@end

@implementation ObjectView

// *** Override to avoid unexpected objects ***
- (Class)expectedClass
{
    return [NSObject class];
}

- (void)setObject:(id)object
{
    _object = object;
    
    [self setNeedsLayout];
}

- (void)reset
{
    // *** Implement in subclasses ***
}

// Override if needed
- (BOOL)isEmpty
{
    return !_object;
}

#pragma mark - Actions

- (void)pushObjectWithNibName:(NSString *)nibName
                        title:(NSString *)title
{
#ifdef NBUCOMPATIBILITY
    ObjectViewController * controller = [[ObjectViewController alloc] initWithObject:_object
                                                                nibNameForObjectView:nibName];
    [self pushObjectWithController:controller
                             title:title];
#endif
}

- (void)pushObjectWithController:(ObjectViewController *)controller
                           title:(NSString *)title
{
#ifdef NBUCOMPATIBILITY
    controller.object = _object;
    if (title)
    {
        controller.title = title;
    }
    
    if (self.viewController.navigationController)
    {
        [self.viewController.navigationController pushViewController:controller
                                                            animated:YES];
    } else {
        [self.viewController.navigationController pushViewController:controller
                                                            animated:YES];
    }
#endif
}

- (void)hiddenMask
{
    if (_isShowMask == YES)
    {
        _isShowMask = NO;
        
        [UIView animateWithDuration:0.1
                         animations:^{_mask.alpha = 0.0;}];
    }
}

- (void)swiped:(id)sender
{
    [super swiped:sender];
    
    if (_isShowMask == YES) 
    {
        [self hiddenMask];
    }
    else 
    {
        _isShowMask = YES;
        
        if (!_mask)
        {
            _mask = [NSBundle loadNibNamed:@"ObjectViewMask"
                                      owner:self
                                    options:nil][0];
            _mask.frame = self.bounds;
            [self addSubview:_mask];
            
        }
        
        [self bringSubviewToFront:_mask];
        _mask.alpha = 1.0;
    }
    
}

- (void)promptDelete:(id)sender
{
    _deleteActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                     delegate:self
                                            cancelButtonTitle:@"キャンセル"             // buttonIndex 1
                                       destructiveButtonTitle:@"削除"                 // buttonIndex 0
                                            otherButtonTitles:nil];
    [_deleteActionSheet showFromRect:self.bounds
                              inView:self
                            animated:YES];
}

- (void)deleteObject:(id)sender
{
    // *** Delete from server in subclass ***
    
    [self hiddenMask];
    
    // Send deleted notification
    [[NSNotificationCenter defaultCenter] postNotificationName:ObjectDeletedNotification
                                                        object:_object];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet == _deleteActionSheet)
    {
        // Cancelled?
        if (buttonIndex == 1)
            return;
    
        [self deleteObject:actionSheet];
    }
}

@end


@implementation ObjectViewMask

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        self.recognizeTap = YES;
        self.doNotHighlightOnTap = YES;
    }
    return self;
}

- (void)tapped:(id)sender
{
    [super tapped:sender];
    
    [UIView animateWithDuration:0.1
                     animations:^{self.alpha = 0.0;}];
}

@end

