//
//  NBUCore.m
//  NBUCore
//
//  Created by Ernesto Rivera on 2012/12/06.
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

#import "NBUCore.h"

UIInterfaceOrientation UIInterfaceOrientationFromValidDeviceOrientation(UIDeviceOrientation orientation)
{
    /*
     UIInterfaceOrientationPortrait           = UIDeviceOrientationPortrait,
     UIInterfaceOrientationPortraitUpsideDown = UIDeviceOrientationPortraitUpsideDown,
     UIInterfaceOrientationLandscapeLeft      = UIDeviceOrientationLandscapeRight,
     UIInterfaceOrientationLandscapeRight     = UIDeviceOrientationLandscapeLeft
     */
    switch (orientation)
    {
        case UIDeviceOrientationLandscapeLeft:      return UIInterfaceOrientationLandscapeRight;
        case UIDeviceOrientationLandscapeRight:     return UIInterfaceOrientationLandscapeLeft;
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:
        default:                                    return (UIInterfaceOrientation)orientation;
    }
}

/// Check if a given UIInterfaceOrientation is supported by a UIInterfaceOrientationMask.
BOOL UIInterfaceOrientationIsSupportedByInterfaceOrientationMask(UIInterfaceOrientation orientation,
                                                                        UIInterfaceOrientationMask mask)
{
    /*
     UIInterfaceOrientationMaskPortrait = (1 << UIInterfaceOrientationPortrait),
     UIInterfaceOrientationMaskLandscapeLeft = (1 << UIInterfaceOrientationLandscapeLeft),
     UIInterfaceOrientationMaskLandscapeRight = (1 << UIInterfaceOrientationLandscapeRight),
     UIInterfaceOrientationMaskPortraitUpsideDown = (1 << UIInterfaceOrientationPortraitUpsideDown)
     */
    return (mask & (1 << orientation)) ? YES : NO;
}

#ifdef DEBUG

#include <assert.h>
#include <stdbool.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/sysctl.h>

BOOL AmIBeingDebugged(void)
// Returns true if the current process is being debugged (either
// running under the debugger or has a debugger attached post facto).
{
    int                 junk;
    int                 mib[4];
    struct kinfo_proc   info;
    size_t              size;
    
    // Initialize the flags so that, if sysctl fails for some bizarre
    // reason, we get a predictable result.
    
    info.kp_proc.p_flag = 0;
    
    // Initialize mib, which tells sysctl the info we want, in this case
    // we're looking for information about a specific process ID.
    
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PID;
    mib[3] = getpid();
    
    // Call sysctl.
    
    size = sizeof(info);
    junk = sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);
    assert(junk == 0);
    
    // We're being debugged if the P_TRACED flag is set.
    
    return ( (info.kp_proc.p_flag & P_TRACED) != 0 );
}

#else

BOOL AmIBeingDebugged(void)
{
    return NO;
}

#endif


