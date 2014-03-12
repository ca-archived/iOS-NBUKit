//
//  NBUAlertView.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/10/31.
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

#import "NBUAlertView.h"
#import "NBUKitPrivate.h"

// Class extension
@interface NBUAlertView () <UIAlertViewDelegate>

@end


@implementation NBUAlertView

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSArray *)otherButtonTitles
          selectedButtonBlock:(NBUAlertSelectedButtonBlock)selectedButtonBlock
            cancelButtonBlock:(NBUAlertCancelButtonBlock)cancelButtonBlock
{
    self = [super initWithTitle:title
                        message:message
                       delegate:self
              cancelButtonTitle:cancelButtonTitle
              otherButtonTitles:nil];
    if (self)
    {
        for (NSString * otherButtonTitle in otherButtonTitles)
        {
            [self addButtonWithTitle:otherButtonTitle];
        }
        self.selectedButtonBlock = selectedButtonBlock;
        self.cancelButtonBlock = cancelButtonBlock;
    }
    return self;
}

- (void)setDelegate:(id<UIAlertViewDelegate>)delegate
{
    if (delegate && delegate != self)
    {
        NBULogWarn(@"Delegate '%@' will be ignored. Set selectedButtonBlock and/or cancelButtonBlock instead.",
                   delegate);
    }
    super.delegate = self;
}

- (void)show
{
    self.delegate = self;
    
    [super show];
}

#pragma mark - Delegate methods

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != self.cancelButtonIndex)
    {
        NSInteger selectedIndex = self.cancelButtonIndex == 0 ? buttonIndex - 1 : buttonIndex;
        
        NBULogVerbose(@"Selected button at index: %@", @(selectedIndex));
        
        if (_selectedButtonBlock) _selectedButtonBlock(selectedIndex);
    }
    else
    {
        NBULogVerbose(@"Canceled");
        
        if (_cancelButtonBlock) _cancelButtonBlock();
    }
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
    NBULogTrace();
    
    if (_cancelButtonBlock) _cancelButtonBlock();
}

@end

