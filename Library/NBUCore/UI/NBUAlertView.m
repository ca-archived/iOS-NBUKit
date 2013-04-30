//
//  NBUAlertView.m
//  NBUCore
//
//  Created by Ernesto Rivera on 2012/10/31.
//  Copyright (c) 2012 CyberAgent Inc.
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

// Private category
@interface NBUAlertView (Private) <UIAlertViewDelegate>

@end


@implementation NBUAlertView

@synthesize selectedButtonBlock = _selectedButtonBlock;
@synthesize cancelButtonBlock = _cancelButtonBlock;

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
        NBULogVerbose(@"Selected button at index: %d", buttonIndex);
        if (_selectedButtonBlock) _selectedButtonBlock(buttonIndex);
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

