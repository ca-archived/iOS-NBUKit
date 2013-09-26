//
//  NBUConfigurationPicker.h
//  NBUCore
//
//  Created by Ernesto Rivera on 2013/01/23.
//  Copyright (c) 2013 CyberAgent Inc.
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

/// Configuration changed notification.
extern NSString * const NBUConfigurationChangedNotification;

/// Configuration name key.
extern NSString * const NBUConfigurationNameKey;

/**
 Abstract configuration picker for switching application parameters (development, staging, etc.).
 
 - Subclasses should override the availableConfigurations method.
 - The current configuration is saved to NSUserDefaults.
 
 @warning To be used only for testing purposes.
 @warning Do not save production settings in NSUserDefaults.
 */
@interface NBUConfigurationPicker : NSObject

/// @name Methods to Override in Subclasses.

/// All the available configurations.
/// @discussion Each configuration should be a NSDictionay with at least one object for with the key NBUConfigurationNameKey.
+ (NSArray *)availableConfigurations;

/// Whether changing settings requires restarting the application. Default `YES`.
+ (BOOL)requiresRestart;

/// @name Showing the Picker

/// Show the picker.
+ (void)show;

/// Create a UIButton configured to display the picker.
/// @param title The desired button title.
+ (UIButton *)pickerButtonWithTitle:(NSString *)title;

/// @name Managing the Current Configuration

/// The current configuration.
+ (NSDictionary *)currentConfiguration;

/// The current configuration's name.
+ (NSString *)currentConfigurationName;

/// Set the current configuration manually.
/// @discussion You can use `exit(EXIT_SUCCESS)` to terminate the application.
/// @param configuration The desired configuration.
+ (void)setCurrentConfiguration:(NSDictionary *)configuration;

/// Set the current configuration at a given index manually.
/// @discussion You can use `exit(EXIT_SUCCESS)` to terminate the application.
/// @param index The index of the desired configuration.
+ (void)setCurrentConfigurationAtIndex:(NSUInteger)index;

@end

