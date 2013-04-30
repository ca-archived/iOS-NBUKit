//
//  NBUConfigurationPicker.m
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

#import "NBUConfigurationPicker.h"
#import "NBUActionSheet.h"

NSString * const NBUConfigurationNameKey                = @"NBUConfigurationNameKey";
NSString * const NBUConfigurationChangedNotification    = @"NBUConfigurationChangedNotification";

// Private class
@interface NBUConfigurationPickerButton : UIButton

@property (nonatomic) Class pickerClass;

@end

static NSDictionary * _currentConfiguration;

@implementation NBUConfigurationPicker

+(NSArray *)availableConfigurations
{
    // *** Implement in subclass ***
    return nil;
}

+ (BOOL)requiresRestart
{
    // *** Implement in subclass if needed ***
    return YES;
}

+ (NSDictionary *)currentConfiguration
{
    if (!_currentConfiguration)
    {
        _currentConfiguration = [UIApplication objectForKey:@"NBUConfigurationPickerConfiguration"];
    }
    return _currentConfiguration;
}

+ (void)setCurrentConfigurationAtIndex:(NSUInteger)index
{
    [self setCurrentConfiguration:self.availableConfigurations[index]];
}

+ (void)setCurrentConfiguration:(NSDictionary *)configuration
{
    NBULogInfo(@"Changing configuration to: %@", configuration);
    
    _currentConfiguration = configuration;
    [UIApplication setObject:configuration
                      forKey:@"NBUConfigurationPickerConfiguration"];
    [[NSNotificationCenter defaultCenter] postNotificationName:NBUConfigurationChangedNotification
                                                        object:configuration];
}

+ (NSString *)currentConfigurationName
{
    return self.currentConfiguration[NBUConfigurationNameKey];
}

+ (void)show
{
    NBULogTrace();
    
    NSArray * configurations = self.availableConfigurations;
    NSString * title = [NSString stringWithFormat:@"Current: %@", self.currentConfigurationName];
    NBUActionSheet * sheet = [[NBUActionSheet alloc] initWithTitle:title
                                                          delegate:nil
                                                 cancelButtonTitle:self.currentConfiguration ? @"Cancel" : nil
                                            destructiveButtonTitle:nil
                                                 otherButtonTitles:nil];
    for (NSDictionary * configuration in configurations)
    {
        [sheet addButtonWithTitle:configuration[NBUConfigurationNameKey]];
    }
    sheet.selectedButtonBlock = ^(NSInteger buttonIndex)
    {
        NSDictionary * configuration = configurations[buttonIndex];
        self.currentConfiguration = configuration;
        
        if (![self requiresRestart])
            return;
        
        // Restart
        NSString * title2 = [NSString stringWithFormat:@"Set: %@", configuration[NBUConfigurationNameKey]];
        NBUActionSheet * restartSheet = [[NBUActionSheet alloc] initWithTitle:title2
                                                                     delegate:nil
                                                            cancelButtonTitle:nil
                                                       destructiveButtonTitle:@"Restart"
                                                            otherButtonTitles:nil];
        restartSheet.selectedButtonBlock = ^(NSInteger buttonIndex2)
        {
            exit(EXIT_SUCCESS);
        };
        [restartSheet showInView:[UIApplication sharedApplication].keyWindow];
    };
    [sheet showInView:[UIApplication sharedApplication].keyWindow];
}

+ (UIButton *)pickerButtonWithTitle:(NSString *)title
{
    NBUConfigurationPickerButton * button = [NBUConfigurationPickerButton new];
    button.title = title;
    button.pickerClass = [self class];
    return button;
}

@end

@implementation NBUConfigurationPickerButton

@synthesize pickerClass = _pickerClass;

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setTitleColor:[UIColor blueColor]
                   forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:11];
        [self addTarget:self
                 action:@selector(showConfigurationPicker:)
       forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (IBAction)showConfigurationPicker:(id)sender
{
    [_pickerClass show];
}

@end

