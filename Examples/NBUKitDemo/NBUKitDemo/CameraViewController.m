//
//  CameraViewController.m
//  NBUKitDemo
//
//  Created by 利辺羅 on 2012/10/15.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
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
    self.cameraView.shouldAutoAdjustOrientation = YES;
    self.cameraView.targetResolution = CGSizeMake(640.0, 640.0); // The minimum resolution we want
    self.cameraView.captureResultBlock = ^(UIImage * image,
                                           NSError * error)
    {
        if (!error)
        {
            // *** Only used to update the slide view ***
            CGFloat scale = [UIScreen mainScreen].scale; // Retina display?
            UIImage * thumbnail = [image imageCroppedToFill:
                                   CGSizeMake(_slideView.targetObjectViewSize.width * scale,
                                              _slideView.targetObjectViewSize.height * scale)];
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
    self.cameraView.savePicturesToLibrary = YES;
    self.cameraView.targetLibraryAlbumName = @"NBUKitDemo Album";
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

@end

