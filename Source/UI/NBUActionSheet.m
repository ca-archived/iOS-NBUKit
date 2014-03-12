//
//  NBUActionSheet.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/11/12.
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

#import "NBUActionSheet.h"
#import "NBUKitPrivate.h"

// Class extension
@interface NBUActionSheet () <UIActionSheetDelegate>

@end


@implementation NBUActionSheet

- (instancetype)initWithTitle:(NSString *)title
            cancelButtonTitle:(NSString *)cancelButtonTitle
       destructiveButtonTitle:(NSString *)destructiveButtonTitle
            otherButtonTitles:(NSArray *)otherButtonTitles
          selectedButtonBlock:(NBUActionSheetSelectedButtonBlock)selectedButtonBlock
            cancelButtonBlock:(NBUActionSheetCancelButtonBlock)cancelButtonBlock
{
    // Create an empty action sheet
    self = [super initWithTitle:title
                       delegate:nil
              cancelButtonTitle:nil
         destructiveButtonTitle:nil
              otherButtonTitles:nil];
    if (self)
    {
        // Add the destructive button
        if (destructiveButtonTitle)
        {
            self.destructiveButtonIndex = [self addButtonWithTitle:destructiveButtonTitle];
        }
        
        // Add the other buttons
        for (NSString * otherButtonTitle in otherButtonTitles)
        {
            [self addButtonWithTitle:otherButtonTitle];
        }
        
        // Add the cancel button
        if (DEVICE_IS_IPHONE_IDIOM && cancelButtonTitle)
        {
            self.cancelButtonIndex = [self addButtonWithTitle:cancelButtonTitle];
        }
        
        // Set the blocks
        self.selectedButtonBlock = selectedButtonBlock;
        self.cancelButtonBlock = cancelButtonBlock;
    }
    return self;
}

- (void)showFrom:(id)target
{
    if ([target isKindOfClass:[UIView class]])
    {
        [self showFromView:target];
    }
    else if ([target isKindOfClass:[UIViewController class]])
    {
        [self showFromView:((UIViewController *)target).view];
    }
    else
    {
        NBULogWarn(@"%@ can't be shown from '%@' target. Will show from key window instead.",
                   THIS_METHOD, NSStringFromClass([target class]));
        
        [self showFromView:[UIApplication sharedApplication].keyWindow];
    }
}

- (void)showFromView:(UIView *)view
{
    UIView * targetView = view;
    
    // iPhone? Try to use the topmost controller's view instead
    if (DEVICE_IS_IPHONE_IDIOM)
    {
        UIViewController * topmostController = view.viewController;
        
        if (topmostController.navigationController)
            topmostController = topmostController.navigationController;
        if (topmostController.tabBarController)
            topmostController = topmostController.tabBarController;
        
        targetView = topmostController.view;
    }
    
    [super showFromRect:targetView.bounds
                 inView:targetView
               animated:YES];
}

- (void)setDelegate:(id<UIActionSheetDelegate>)delegate
{
    if (delegate && delegate != self)
    {
        NBULogWarn(@"Delegate '%@' will be ignored. Set selectedButtonBlock and/or cancelButtonBlock instead.",
                   delegate);
    }
    super.delegate = self;
}

- (void)showInView:(UIView *)view
{
    self.delegate = self;
    
    [super showInView:view];
}

- (void)showFromRect:(CGRect)rect
              inView:(UIView *)view
            animated:(BOOL)animated
{
    self.delegate = self;
    
    [super showFromRect:rect
                 inView:view
               animated:animated];
}

- (void)showFromToolbar:(UIToolbar *)view
{
    self.delegate = self;
    
    [super showFromToolbar:view];
}

- (void)showFromTabBar:(UITabBar *)view
{
    self.delegate = self;
    
    [super showFromTabBar:view];
}

- (void)showFromBarButtonItem:(UIBarButtonItem *)item
                     animated:(BOOL)animated
{
    self.delegate = self;
    
    [super showFromBarButtonItem:item
                        animated:animated];
}

#pragma mark - Delegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NBULogVerbose(@"%@ %@ cancel: %@", THIS_METHOD, @(buttonIndex), @(self.cancelButtonIndex));
    if (buttonIndex == self.cancelButtonIndex)
    {
        NBULogVerbose(@"Canceled");
        
        if (_cancelButtonBlock) _cancelButtonBlock();
    }
    else
    {
        NSInteger selectedIndex = self.cancelButtonIndex == 0 ? buttonIndex - 1 : buttonIndex;
        
        NBULogVerbose(@"Selected button at index: %@", @(selectedIndex));
        
        if (_selectedButtonBlock) _selectedButtonBlock(selectedIndex);
    }
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    NBULogTrace();
    
    if (_cancelButtonBlock) _cancelButtonBlock();
}

@end

