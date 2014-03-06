//
//  NBUBadgeView.m
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/04/20.
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

#import "NBUBadgeView.h"
#import "NBUKitPrivate.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_UI

@implementation NBUBadgeView

@dynamic value;

+ (NBUBadgeView *)badge
{
    return [NSBundle loadNibNamed:@"NBUBadgeView"
                            owner:nil
                          options:nil][0];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    // Even when created programatically we load from Nib!
    NBUBadgeView * badge = [NBUBadgeView badge];
    badge.origin = frame.origin;
    return badge;
}

- (void)commonInit
{
    [super commonInit];
    
    self.userInteractionEnabled = NO;
}

- (BOOL)isEmpty
{
    return !self.value || self.value.length == 0;
}

- (void)setObject:(NSString *)badgeValue
{
    [super setObject:badgeValue];
    
    if (!self.isEmpty)
    {
        _label.text = badgeValue;
        [self sizeToFit];
    }
}

- (void)sizeToFit
{
    CGRect originalFrame = self.frame;
    
    [super sizeToFit];
    
    // Center the view
    if ((self.autoresizingMask & UIViewAutoresizingFlexibleLeftMargin) &&
        (self.autoresizingMask & UIViewAutoresizingFlexibleRightMargin))
    {
        self.center = CGPointMake(CGRectGetMidX(originalFrame),
                                  CGRectGetMidY(originalFrame));
    }
    
    // Grow to the left
    else if (self.autoresizingMask & UIViewAutoresizingFlexibleLeftMargin)
    {
        self.origin = CGPointMake(self.origin.x - (self.size.width - originalFrame.size.width),
                                  self.origin.y);
    }
    
    // Otherwise we just grow to the right
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(MAX([_label sizeThatFits:CGSizeMake(CGFLOAT_MAX,
                                                          CGFLOAT_MAX)].width + 16.0,
                          self.originalSize.width),
                      self.originalSize.height);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [UIView animateWithDuration:self.animated ? 0.2 : 0.0
                     animations:^{
                         
                         self.alpha = self.isEmpty ? 0.0 : 1.0;
                         
                     }];
}

@end

