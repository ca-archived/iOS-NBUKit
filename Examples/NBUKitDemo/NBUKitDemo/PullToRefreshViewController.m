//
//  PullToRefreshViewController.m
//  NBUKitDemo
//
//  Created by 利辺羅 on 2012/09/11.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import "PullToRefreshViewController.h"

@implementation PullToRefreshViewController

@synthesize label = _label;

- (IBAction)refresh:(id)sender
{
    NBULogTrace();
    
    // *** Refresh your data here ***
    
    _label.text = @"Refreshing...";
    
    
    // *** ...and then notify the refresh control when finished ***
    
    double delayInSeconds = 1.0 + (arc4random() % 5) * 1.0; // Between 1 and 5sec
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

- (void)viewDidUnload
{
    [self setLabel:nil];
    [super viewDidUnload];
}

@end

