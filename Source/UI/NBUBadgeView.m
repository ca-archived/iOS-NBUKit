//
//  NBUBadgeView.m
//  NBUKit
//
//  Created by エルネスト 利辺羅 on 12/04/20.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import "NBUBadgeView.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_UI

@implementation NBUBadgeView

@dynamic value;
@synthesize label = _label;

+ (NBUBadgeView *)badge
{
    return [[NSBundle loadNibNamed:@"NBUBadgeView"
                             owner:nil
                           options:nil] objectAtIndex:0];
}

- (id)initWithFrame:(CGRect)frame
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

