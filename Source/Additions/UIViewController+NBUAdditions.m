//
//  UIViewController+NBUAdditions.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2013/04/12.
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

#import "UIViewController+NBUAdditions.h"
#import "NBUKitPrivate.h"

@implementation UIViewController (NBUAdditions)

@dynamic navigationItem;

- (IBAction)dismiss:(id)sender
{
    NBULogTrace();
    
    [self dismissViewControllerAnimated:YES
                             completion:NULL];
}

- (void)forceOrientationRefresh
{
    // Force orientation refresh
    [self presentViewController:[UIViewController new]
                       animated:NO
                     completion:NULL];
    [self dismissViewControllerAnimated:NO
                             completion:NULL];
}

@end

