//
//  PullToRefreshViewController.h
//  NBUKitDemo
//
//  Created by 利辺羅 on 2012/09/11.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PullToRefreshViewController : ScrollViewController

@property (assign, nonatomic) IBOutlet UILabel * label;

- (IBAction)refresh:(id)sender;

@end

