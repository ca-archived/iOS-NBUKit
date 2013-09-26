//
//  MotionOrientation.h
//
//  Created by Sangwon Park on 5/3/12.
//  Copyright (c) 2012 tastyone@gmail.com. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import <CoreGraphics/CoreGraphics.h>

extern NSString* const MotionOrientationChangedNotification;
extern NSString* const MotionOrientationInterfaceOrientationChangedNotification;

extern NSString* const kMotionOrientationKey;

@interface MotionOrientation : NSObject

@property (readonly) UIInterfaceOrientation interfaceOrientation;
@property (readonly) UIDeviceOrientation deviceOrientation;
@property (readonly) CGAffineTransform affineTransform;

+ (void)initialize;
+ (MotionOrientation *)sharedInstance;

@end
