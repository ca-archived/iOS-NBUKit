//
//  CameraViewController.m
//  NBUKitDemo
//
//  Created by Ernesto Rivera on 2012/10/15.
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

#import "CameraViewController.h"

@implementation CameraViewController

@synthesize shootButton = _shootButton;
@synthesize slideView = _slideView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configure the slide view
    _slideView.targetObjectViewSize = CGSizeMake(46.0, 46.0);
    _slideView.margin = CGSizeMake(2.0, 2.0);
    
    // Configure the camera view
    //self.cameraView.shouldAutoRotateView = YES;
    self.cameraView.targetResolution = CGSizeMake(640.0, 640.0); // The minimum resolution we want
    self.cameraView.captureResultBlock = ^(UIImage * image,
                                           NSError * error)
    {
        if (!error)
        {
            // *** Only used to update the slide view ***
            UIImage * thumbnail = [image thumbnailWithSize:_slideView.targetObjectViewSize];
            NSMutableArray * tmp = [NSMutableArray arrayWithArray:_slideView.objectArray];
            [tmp insertObject:thumbnail atIndex:0];
            _slideView.objectArray = tmp;
        }
    };
    self.cameraView.flashButtonConfigurationBlock = [self.cameraView buttonConfigurationBlockWithTitleFrom:
                                                    @[@"Flash Off", @"Flash On", @"Flash Auto"]];
    self.cameraView.focusButtonConfigurationBlock = [self.cameraView buttonConfigurationBlockWithTitleFrom:
                                                    @[@"Fcs Lckd", @"Fcs Auto", @"Fcs Cont"]];
    self.cameraView.exposureButtonConfigurationBlock = [self.cameraView buttonConfigurationBlockWithTitleFrom:
                                                        @[@"Exp Lckd", @"Exp Auto", @"Exp Cont"]];
    self.cameraView.whiteBalanceButtonConfigurationBlock = [self.cameraView buttonConfigurationBlockWithTitleFrom:
                                                            @[@"WB Lckd", @"WB Auto", @"WB Cont"]];
    
    // Optionally auto-save pictures to the library
    self.cameraView.saveResultBlock = ^(UIImage * image,
                                        NSDictionary * metadata,
                                        NSURL * url,
                                        NSError * error)
    {
        // *** Do something with the image and its URL ***
    };
    
    // Connect the shoot button
    self.cameraView.shootButton = _shootButton;
    [_shootButton addTarget:self.cameraView
                     action:@selector(takePicture:)
           forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Disconnect shoot button
    [_shootButton removeTarget:nil
                        action:@selector(takePicture:)
              forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Enable shootButton
    _shootButton.userInteractionEnabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Disable shootButton
    _shootButton.userInteractionEnabled = NO;
}

- (IBAction)customToggleFlash:(id)sender
{
    // We intentionally skip AVCaptureFlashModeAuto
    if (self.cameraView.currentFlashMode == AVCaptureFlashModeOff)
    {
        self.cameraView.currentFlashMode = AVCaptureFlashModeOn;
    }
    else
    {
        self.cameraView.currentFlashMode = AVCaptureFlashModeOff;
    }
}

@end

