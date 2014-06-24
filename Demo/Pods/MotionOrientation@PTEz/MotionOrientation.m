//
//  MotionOrientation.m
//
//  Created by Sangwon Park on 5/3/12.
//  Copyright (c) 2012 tastyone@gmail.com. All rights reserved.
//

#import "MotionOrientation.h"

#define MO_degreesToRadian(x) (M_PI * (x) / 180.0)

NSString* const MotionOrientationChangedNotification = @"MotionOrientationChangedNotification";
NSString* const MotionOrientationInterfaceOrientationChangedNotification = @"MotionOrientationInterfaceOrientationChangedNotification";

NSString* const kMotionOrientationKey = @"kMotionOrientationKey";

@interface MotionOrientation ()
@property (strong) CMMotionManager* motionManager;
@property (strong) NSOperationQueue* operationQueue;
@end


@implementation MotionOrientation

@synthesize interfaceOrientation = _interfaceOrientation;
@synthesize deviceOrientation = _deviceOrientation;

@synthesize motionManager = _motionManager;
@synthesize operationQueue = _operationQueue;

+ (void)initialize
{
    [MotionOrientation sharedInstance];
}

+ (MotionOrientation *)sharedInstance
{
    static MotionOrientation *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MotionOrientation alloc] init];
    });
    return sharedInstance;
}

- (void)_initialize
{
    self.operationQueue = [[NSOperationQueue alloc] init];
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = 0.1;
    if ( ![self.motionManager isAccelerometerAvailable] ) {
        NSLog(@"MotionOrientation - Accelerometer is NOT available");
#if TARGET_IPHONE_SIMULATOR
        [self affineTransform];
#endif
        return;
    }
    [self.motionManager startAccelerometerUpdatesToQueue:self.operationQueue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        [self accelerometerUpdateWithData:accelerometerData error:error];
    }];
}

- (id)init
{
    self = [super init];
    if ( self ) {
        [self _initialize];
    }
    return self;
}

- (CGAffineTransform)affineTransform
{
    int rotationDegree = 0;
    
    switch (self.interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
            rotationDegree = 0;
            break;
            
        case UIInterfaceOrientationLandscapeLeft:
            rotationDegree = 90;
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            rotationDegree = 180;
            break;
            
        case UIInterfaceOrientationLandscapeRight:
            rotationDegree = 270;
            break;
            
        default:
            break;
    }
    NSLog(@"affineTransform degree: %d", rotationDegree);
    return CGAffineTransformMakeRotation(MO_degreesToRadian(rotationDegree));
}

- (void)accelerometerUpdateWithData:(CMAccelerometerData *)accelerometerData error:(NSError *)error
{
    if ( error ) {
        NSLog(@"accelerometerUpdateERROR: %@", error);
        return;
    }
    
    CMAcceleration acceleration = accelerometerData.acceleration;
    
    // Get the current device angle
	float xx = -acceleration.x;
	float yy = acceleration.y;
    float z = acceleration.z;
	float angle = atan2(yy, xx); 
    float absoluteZ = (float)fabs(acceleration.z);
    
	// Add 1.5 to the angle to keep the label constantly horizontal to the viewer.
    //	[interfaceOrientationLabel setTransform:CGAffineTransformMakeRotation(angle+1.5)]; 
    
	// Read my blog for more details on the angles. It should be obvious that you
	// could fire a custom shouldAutorotateToInterfaceOrientation-event here.
    UIInterfaceOrientation newInterfaceOrientation = self.interfaceOrientation;
    UIDeviceOrientation newDeviceOrientation = self.deviceOrientation;
    
#ifdef DEBUG
    NSString* orientationString = nil;
#endif
    if(absoluteZ > 0.8f)
    {
        if ( z > 0.0f ) {
            newDeviceOrientation = UIDeviceOrientationFaceDown;
#ifdef DEBUG
            orientationString = @"MotionOrientation - FaceDown";
#endif
        } else {
            newDeviceOrientation = UIDeviceOrientationFaceUp;
#ifdef DEBUG
            orientationString = @"MotionOrientation - FaceUp";
#endif
        }
	}
    else if(angle >= -2.0 && angle <= -1.0) // (angle >= -2.25 && angle <= -0.75)
	{
        newInterfaceOrientation = UIInterfaceOrientationPortrait;
        newDeviceOrientation = UIDeviceOrientationPortrait;
        //self.captureVideoOrientation = AVCaptureVideoOrientationPortrait;
#ifdef DEBUG
        orientationString = @"MotionOrientation - Portrait";
#endif
	}
	else if(angle >= -0.5 && angle <= 0.5) // (angle >= -0.75 && angle <= 0.75)
	{
        newInterfaceOrientation = UIInterfaceOrientationLandscapeLeft;
        newDeviceOrientation = UIDeviceOrientationLandscapeLeft;
        //self.captureVideoOrientation = AVCaptureVideoOrientationLandscapeRight;
#ifdef DEBUG
        orientationString = @"MotionOrientation - Left";
#endif
	}
	else if(angle >= 1.0 && angle <= 2.0) // (angle >= 0.75 && angle <= 2.25)
	{
        newInterfaceOrientation = UIInterfaceOrientationPortraitUpsideDown;
        newDeviceOrientation = UIDeviceOrientationPortraitUpsideDown;
        //self.captureVideoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
#ifdef DEBUG
        orientationString = @"MotionOrientation - UpsideDown";
#endif
	}
	else if(angle <= -2.5 || angle >= 2.5) // (angle <= -2.25 || angle >= 2.25)
	{
        newInterfaceOrientation = UIInterfaceOrientationLandscapeRight;
        newDeviceOrientation = UIDeviceOrientationLandscapeRight;
        //self.captureVideoOrientation = AVCaptureVideoOrientationLandscapeLeft;
#ifdef DEBUG
        orientationString = @"MotionOrientation - Right";
#endif
	} else {
        
    }

    BOOL deviceOrientationChanged = NO;
    BOOL interfaceOrientationChanged = NO;
    
    if ( newDeviceOrientation != self.deviceOrientation ) {
        deviceOrientationChanged = YES;
        _deviceOrientation = newDeviceOrientation;
    }
    
    if ( newInterfaceOrientation != self.interfaceOrientation ) {
        interfaceOrientationChanged = YES;
        _interfaceOrientation = newInterfaceOrientation;
    }

    // post notifications
    if ( deviceOrientationChanged ) {
        dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:MotionOrientationChangedNotification 
                                                            object:nil 
                                                          userInfo:@{kMotionOrientationKey: self}];
        });
#ifdef DEBUG
        NSLog(@"didAccelerate: absoluteZ: %f angle: %f (x: %f, y: %f, z: %f), orientationString: %@", 
              absoluteZ, angle, 
              acceleration.x, acceleration.y, acceleration.z, 
              orientationString);
#endif
    }
    if ( interfaceOrientationChanged ) {
        dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:MotionOrientationInterfaceOrientationChangedNotification 
                                                            object:nil 
                                                          userInfo:@{kMotionOrientationKey: self}];
        });
    }
}

// Simulator support
#if TARGET_IPHONE_SIMULATOR

- (void)simulatorInit
{
    // Simulator
    NSLog(@"MotionOrientation - Simulator in use. Using UIDevice instead");
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)deviceOrientationChanged:(NSNotification *)notification
{
    _deviceOrientation = [UIDevice currentDevice].orientation;
    [[NSNotificationCenter defaultCenter] postNotificationName:MotionOrientationChangedNotification
                                                        object:nil
                                                      userInfo:@{kMotionOrientationKey: self}];
}

- (void)dealloc
{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

#endif

@end
