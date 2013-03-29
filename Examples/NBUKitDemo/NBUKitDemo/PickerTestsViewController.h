//
//  PickerTestsViewController.h
//  NBUKitDemo
//
//  Created by 利辺羅 on 2012/11/13.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PickerTestsViewController : NBUViewController

// Outlets
@property (assign, nonatomic) IBOutlet UIImageView * imageView;

// Actions
- (IBAction)startPicker:(id)sender;
- (IBAction)segmentControlChanged:(id)sender;
- (IBAction)toggleCamera:(id)sender;
- (IBAction)toggleLibrary:(id)sender;
- (IBAction)toggleCrop:(id)sender;
- (IBAction)toggleFilters:(id)sender;
- (IBAction)toggleConfirmation:(id)sender;

@end

