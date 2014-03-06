//
//  NBUAlertView.h
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

/// Result blocks.
typedef void (^NBUAlertSelectedButtonBlock)(NSInteger buttonIndex);
typedef void (^NBUAlertCancelButtonBlock)();

/**
 Block-based UIAlertView subclass.
 
 @note The delegate parameter will be ignored.
 */
@interface NBUAlertView : UIAlertView

/// @name Creating and Configuring an Alert View

/// Initialize an alert view.
/// @param title An optional title.
/// @param message An optional alert message.
/// @param cancelButtonTitle An optional cancel button title.
/// @param otherButtonTitles Optional additional buttons.
/// @param selectedButtonBlock The optional block to be called when the user chooses
/// a non-cancel button.
/// @param cancelButtonBlock The optional block to be called if the user cancels the
/// action sheet.
- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSArray *)otherButtonTitles
          selectedButtonBlock:(NBUAlertSelectedButtonBlock)selectedButtonBlock
            cancelButtonBlock:(NBUAlertCancelButtonBlock)cancelButtonBlock;

/// The optional block to be called if a non-cancel button is selected.
/// @note The cancel button index is ignored.
@property (nonatomic, copy) NBUAlertSelectedButtonBlock selectedButtonBlock;

/// The optional block to be called if the cancel button is selected.
@property (nonatomic, copy) NBUAlertCancelButtonBlock cancelButtonBlock;

@end

