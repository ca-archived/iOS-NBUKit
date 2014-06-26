//
//  UIScrollView+NBUAdditions.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/10/17.
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

#import "UIScrollView+NBUAdditions.h"
#import "NBUKitPrivate.h"

@implementation UIScrollView (NBUAdditions)

#pragma mark - Scroll to edges

- (void)scrollToTopAnimated:(BOOL)animated
{
    [self scrollRectToVisible:CGRectMake(self.contentOffset.x,
                                         0.0,
                                         1.0,
                                         1.0)
                     animated:animated];
}

- (IBAction)scrollToTop:(id)sender
{
    [self scrollToTopAnimated:YES];
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
    [self scrollRectToVisible:CGRectMake(self.contentOffset.x,
                                         self.contentSize.height - 1.0,
                                         1.0,
                                         1.0)
                     animated:animated];
}

- (void)scrollToLeftAnimated:(BOOL)animated
{
    [self scrollRectToVisible:CGRectMake(0.0,
                                         self.contentOffset.y,
                                         1.0,
                                         1.0)
                     animated:animated];
}

- (void)scrollToRightAnimated:(BOOL)animated
{
    [self scrollRectToVisible:CGRectMake(self.contentSize.width - 1.0,
                                         self.contentOffset.y,
                                         1.0,
                                         1.0)
                     animated:animated];
}

#pragma mark - Auto-adjusting

- (void)autoAdjustContentSize
{
    // Make sure to make the origin CGPointZero
    UIView * firstSubview = self.subviews[0];
    CGRect requiredFrame = CGRectMake(0.0,
                                      0.0,
                                      CGRectGetMaxX(firstSubview.frame),
                                      CGRectGetMaxY(firstSubview.frame));
    
    NBULogDebug(@"%@ -> %@", THIS_METHOD, NSStringFromCGSize(requiredFrame.size));
    self.contentSize = requiredFrame.size;
}

- (void)autoAdjustInsets
{
    UIEdgeInsets insets = self.contentInset;
    
    // Inside a controller?
    UIViewController * controller = self.viewController;
    if (controller)
    {
        CGRect frame = [controller.view convertRect:self.bounds
                                           fromView:self];
        if (self == controller.view)
            frame.origin = CGPointZero;
        CGFloat topLayoutGuide = [controller respondsToSelector:@selector(topLayoutGuide)] ? controller.topLayoutGuide.length : 0.0;
        CGFloat bottomLayoutGuide = [controller respondsToSelector:@selector(bottomLayoutGuide)] ? controller.bottomLayoutGuide.length : 0.0;
        insets.top = MAX(topLayoutGuide - frame.origin.y,
                         0.0);
        insets.bottom = MAX(bottomLayoutGuide - (CGRectGetMaxY(controller.view.bounds) - CGRectGetMaxY(frame)),
                            0.0);
    }
    // Else just reset insets
    else
    {
        insets.top = 0.0;
        insets.bottom = 0.0;
    }
    
    // Adjust
    if (!UIEdgeInsetsEqualToEdgeInsets(self.contentInset, insets))
    {
        // Also adjust offset
        CGPoint offset = self.contentOffset;
        offset.y -= (insets.top - self.contentInset.top);
        
        NBULogDebug(@"%@ %@ -> %@ offset : %@ -> %@",
                    THIS_METHOD,
                    NSStringFromUIEdgeInsets(self.contentInset),
                    NSStringFromUIEdgeInsets(insets),
                    NSStringFromCGPoint(self.contentOffset),
                    NSStringFromCGPoint(offset));
        
        self.contentInset = insets;
        self.scrollIndicatorInsets = insets;
        self.contentOffset = offset;
    }
}

@end

