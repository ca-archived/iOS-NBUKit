//
//  PullToRefreshViewController.m
//  NBUKitDemo
//
//  Created by Ernesto Rivera on 2012/09/11.
//  Copyright (c) 2012-2017 CyberAgent Inc.
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

#import "PullToRefreshViewController.h"

@implementation PullToRefreshViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configure the refresh control
    self.refreshControl = [NBURefreshControl controlForScrollView:self.view.subviews[0]
                                                          fromNib:@"CustomRefreshControl"
                                                       withTarget:self
                                                           action:@selector(refresh:)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Adjust scrollview
    UIScrollView * scrollView = self.view.subviews[1]; // Now the refresh control is at index 0
    [scrollView autoAdjustContentSize];
    [scrollView autoAdjustInsets];
}

- (IBAction)refresh:(id)sender
{
    NBULogTrace();
    
    // *** Refresh your data here ***
    
    _label.text = @"Refreshing...";
    
    
    // *** ...and then notify the refresh control when finished ***
    
    double delayInSeconds = 5.0 + (arc4random() % 5) * 1.0; // Between 5 and 10sec
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        // Fail randomly
        if (arc4random() % 2)
        {
            _label.text = @"Failed to update (mock)";
            
            // Default message
            //[(NBURefreshControl *)sender failedToUpdate:self];
            
            // Custom message
            [(NBURefreshControl *)sender setStatus:NBURefreshStatusError
                                       withMessage:@"This is a custom error msg"];
        }
        else
        {
            _label.text = @"Successful update (mock)";
            
            // Default message
            //[(NBURefreshControl *)sender updated:self];
            
            // Custom message
            [(NBURefreshControl *)sender setStatus:NBURefreshStatusUpdated
                                       withMessage:@"Refreshed!!!!"];
        }
    });
}

- (void)testUpdated:(id)sender
{
    NBULogTrace();
    
    self.refreshControl.status = NBURefreshStatusUpdated;
}

- (void)testFailedToUpdate:(id)sender
{
    NBULogTrace();
    
    self.refreshControl.status = NBURefreshStatusError;
}

@end

