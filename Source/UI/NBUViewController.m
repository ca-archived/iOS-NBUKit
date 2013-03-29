//
//  NBUViewController.m
//  NBUKit
//
//  Created by 利辺羅 on 2012/11/09.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import "NBUViewController.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_UI

@implementation NBUViewController

@dynamic navigationItem;
@synthesize supportedInterfaceOrientations = _supportedInterfaceOrientations;

- (void)commonInit
{
    // *** Override in subclasses and call [super commonInit] ***
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

#pragma mark - Interface orientations

- (void)setSupportedInterfaceOrientations:(NSUInteger)supportedInterfaceOrientations
{
    if (!UIDeviceOrientationIsValidInterfaceOrientation(supportedInterfaceOrientations))
    {
        NBULogError(@"'%d' is not a valid interface orientation mask!", supportedInterfaceOrientations);
        return;
    }
    _supportedInterfaceOrientations = supportedInterfaceOrientations;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (_supportedInterfaceOrientations == 0)
    {
        // iOS6+
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
        {
            _supportedInterfaceOrientations = [super supportedInterfaceOrientations];
        }
        
        // Else deduce from plist
        else
        {
            NSArray * orientations = [[[NSBundle mainBundle] infoDictionary] objectForKey:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ?
                                                                                           @"UISupportedInterfaceOrientations" :
                                                                                           @"UISupportedInterfaceOrientations~ipad")];
            NSUInteger mask = 0;
            for (NSString * orientation in orientations)
            {
                if ([orientation isEqualToString:@"UIInterfaceOrientationPortrait"])
                    mask = UIInterfaceOrientationMaskPortrait;
                else if ([orientation isEqualToString:@"UIInterfaceOrientationLandscapeRight"])
                    mask = UIInterfaceOrientationMaskLandscapeRight;
                else if ([orientation isEqualToString:@"UIInterfaceOrientationLandscapeLeft"])
                    mask = UIInterfaceOrientationMaskLandscapeLeft;
                else if ([orientation isEqualToString:@"UIInterfaceOrientationPortraitUpsideDown"])
                    mask = UIInterfaceOrientationMaskPortraitUpsideDown;
                
                _supportedInterfaceOrientations |= mask;
            }
            
            // Still not decided? Set default mask
            if (_supportedInterfaceOrientations == 0)
            {
                _supportedInterfaceOrientations = UIInterfaceOrientationMaskPortrait;
            }
        }
    }
    
    NBULogVerbose(@"%@ %@ %d", NSStringFromClass([self class]), THIS_METHOD, _supportedInterfaceOrientations);
    return _supportedInterfaceOrientations;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    /*
     UIInterfaceOrientationMaskPortrait = (1 << UIInterfaceOrientationPortrait),
     UIInterfaceOrientationMaskLandscapeLeft = (1 << UIInterfaceOrientationLandscapeLeft),
     UIInterfaceOrientationMaskLandscapeRight = (1 << UIInterfaceOrientationLandscapeRight),
     UIInterfaceOrientationMaskPortraitUpsideDown = (1 << UIInterfaceOrientationPortraitUpsideDown)
    */
    return self.supportedInterfaceOrientations & (1 << orientation);
}

@end

