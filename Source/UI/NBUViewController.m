//
//  NBUViewController.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/11/09.
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

#import "NBUViewController.h"
#import "NBUKitPrivate.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_UI

@implementation NBUViewController

@synthesize supportedInterfaceOrientations = _supportedInterfaceOrientations;

- (void)commonInit
{
    // *** Override in subclasses and call [super commonInit] ***
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

#pragma mark - Interface orientations

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (_supportedInterfaceOrientations == 0)
    {
        // iOS6+
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
        {
            _supportedInterfaceOrientations = [super supportedInterfaceOrientations];
        }
        
        // Else deduce from plist
        else
        {
            NSString * supportedInterfaceOrientationsKey = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ?
                                                            @"UISupportedInterfaceOrientations" :
                                                            @"UISupportedInterfaceOrientations~ipad");
            NSArray * orientations = [[NSBundle mainBundle] infoDictionary][supportedInterfaceOrientationsKey];
            NSUInteger mask = 0;
            for (NSString * orientation in orientations)
            {
                if ([orientation isEqualToString:@"UIInterfaceOrientationPortrait"])
                    mask = UIInterfaceOrientationMaskPortrait;
                else if ([orientation isEqualToString:@"UIInterfaceOrientationLandscapeRight"])
                    mask = UIInterfaceOrientationMaskLandscapeRight;
                else if ([orientation isEqualToString:@"UIInterfaceOrientationLandscapeLeft"])
                    mask = UIInterfaceOrientationMaskLandscapeLeft;
                else if ([orientation isEqualToString:@"UIInterfaceOrientationPortraitUpsideDown"])
                    mask = UIInterfaceOrientationMaskPortraitUpsideDown;
                
                _supportedInterfaceOrientations |= mask;
            }
            
            // Still not decided? Set default mask
            if (_supportedInterfaceOrientations == 0)
            {
                _supportedInterfaceOrientations = UIInterfaceOrientationMaskPortrait;
            }
        }
    }
    
    NBULogVerbose(@"%@ %@ %@", NSStringFromClass([self class]), THIS_METHOD, @(_supportedInterfaceOrientations));
    return _supportedInterfaceOrientations;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    /*
     UIInterfaceOrientationMaskPortrait = (1 << UIInterfaceOrientationPortrait),
     UIInterfaceOrientationMaskLandscapeLeft = (1 << UIInterfaceOrientationLandscapeLeft),
     UIInterfaceOrientationMaskLandscapeRight = (1 << UIInterfaceOrientationLandscapeRight),
     UIInterfaceOrientationMaskPortraitUpsideDown = (1 << UIInterfaceOrientationPortraitUpsideDown)
     */
    return self.supportedInterfaceOrientations & (1 << orientation);
}

@end

