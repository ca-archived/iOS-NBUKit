//
//  NBUCropView.m
//  NBUKit
//
//  Created by エルネスト 利辺羅 on 12/04/16.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "NBUCropView.h"
#import "UIImage+NBUAdditions.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_IMAGE

// Private categories and classes
@interface NBUCropView (Private) <UIScrollViewDelegate>

@end

@interface CropGuideView : UIView

@end


@implementation NBUCropView
{
    CGPoint _cropOrigin;
    CGFloat _aspectFillFactor;
    CGFloat _aspectFitFactor;
    BOOL _ignoreLayout; // Needed for iOS4
}
@synthesize image = _image;
@synthesize cropGuideSize = _cropGuideSize;
@synthesize maximumScaleFactor = _maximumScaleFactor;
@synthesize allowAspectFit = _allowAspectFit;
@synthesize scrollView = _scrollView;
@synthesize viewToCrop = _viewToCrop;
@synthesize cropGuideView = _cropGuideView;

- (void)commonInit
{
    [super commonInit];
    
    _maximumScaleFactor = 1.5;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    
    // Update view to crop
    self.viewToCrop.image = image;
    
    // Update layout
    [self setNeedsLayout];
    _ignoreLayout = NO;
}

- (UIImage *)image
{
    if (!_image)
        return nil;
    
    UIImage * image = _viewToCrop.image;
    
    // UI crop area
    CGRect cropArea = [_viewToCrop convertRect:CGRectMake(_cropOrigin.x + _scrollView.origin.x,
                                                          _cropOrigin.y + _scrollView.origin.y,
                                                          _cropGuideSize.width,
                                                          _cropGuideSize.height)
                                      fromView:self];
    
    NBULogInfo(@"Crop %@ from %@)",
              NSStringFromCGRect(cropArea),
              NSStringFromCGRect(_viewToCrop.bounds));
    
    // The image crop area
    CGFloat factor = image.size.width / _viewToCrop.bounds.size.width;
    cropArea = CGRectMake(cropArea.origin.x * factor,
                          cropArea.origin.y * factor,
                          cropArea.size.width * factor,
                          cropArea.size.height * factor);
    
    return [image imageCroppedToRect:cropArea];
}

#pragma mark - Subviews

- (UIView<UIImageView> *)viewToCrop
{
    if (!_viewToCrop)
    {
        // Create a view if needed
        _viewToCrop = [UIImageView new];
        [self.scrollView addSubview:_viewToCrop];
    }
    return _viewToCrop;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView)
    {
        // Create a view if needed
        _scrollView = [UIScrollView new];
        _scrollView.autoresizingMask = (UIViewAutoresizingFlexibleHeight |
                                        UIViewAutoresizingFlexibleWidth);
        _scrollView.clipsToBounds = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.frame = self.bounds;
        [self insertSubview:_scrollView
                    atIndex:0];
    }
    return _scrollView;
}

- (UIView *)cropGuideView
{
    // Create a crop guide view if nil and cropSize is set
    if (!_cropGuideView &&
        !CGSizeEqualToSize(_cropGuideSize, CGSizeZero))
    {
        self.cropGuideView = [[CropGuideView alloc] initWithFrame:CGRectMake(0.0,
                                                                             0.0,
                                                                             _cropGuideSize.width,
                                                                             _cropGuideSize.height)];
        _cropGuideView.opaque = NO;
        [self addSubview:_cropGuideView];
    }
    return _cropGuideView;
}

- (void)setCropGuideView:(UIView *)cropGuideView
{
    _cropGuideView = cropGuideView;
    
    // Configure it
    _cropGuideView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin |
                                       UIViewAutoresizingFlexibleBottomMargin);
    _cropGuideView.userInteractionEnabled = NO;
    
    // Set cropSize if not set
    if (CGSizeEqualToSize(_cropGuideSize, CGSizeZero))
    {
        _cropGuideSize = _cropGuideView.size;
    }
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Ignore layout on iOS4?
    if (SYSTEM_VERSION_LESS_THAN(@"5.0"))
    {
        if (_ignoreLayout)
        {
            return;
        }
        _ignoreLayout = YES;
    }
    
    // Reset scrollView
    _scrollView.delegate = self;
    _scrollView.minimumZoomScale = 1.0;
    _scrollView.maximumZoomScale = 1.0;
    _scrollView.zoomScale = 1.0;
    
    // Adjust the crop guide view
    self.cropGuideView.center = _scrollView.center;
    
    // Configure the viewToCrop
    _cropOrigin = CGPointMake((_scrollView.bounds.size.width - _cropGuideSize.width) / 2.0,
                              (_scrollView.bounds.size.height - _cropGuideSize.height) / 2.0);
    CGSize size = [_viewToCrop sizeThatFits:CGSizeMake(CGFLOAT_MAX,
                                                       CGFLOAT_MAX)];
    if (CGSizeEqualToSize(size, CGSizeZero))
        return;
    _viewToCrop.frame = CGRectMake(_cropOrigin.x,
                                   _cropOrigin.y,
                                   size.width,
                                   size.height);
    
    // Configure the scrollView
    _aspectFillFactor = MAX(_cropGuideSize.width / size.width,
                            _cropGuideSize.height / size.height);
    _aspectFitFactor = MIN(_cropGuideSize.width / size.width,
                           _cropGuideSize.height / size.height);
    _scrollView.minimumZoomScale = _allowAspectFit ? _aspectFitFactor : _aspectFillFactor;
    _scrollView.maximumZoomScale = _aspectFillFactor * _maximumScaleFactor;
    _scrollView.zoomScale = _aspectFillFactor;
    [self scrollViewDidZoom:_scrollView];
    
    // Center the scrollView
    [_scrollView scrollRectToVisible:CGRectMake((_scrollView.contentSize.width - _scrollView.bounds.size.width) / 2.0,
                                                (_scrollView.contentSize.height - _scrollView.bounds.size.height) / 2.0,
                                                _scrollView.bounds.size.width,
                                                _scrollView.bounds.size.height)
                            animated:NO];
    
    NBULogVerbose(@"layoutSubviews viewToCrop: %@ cropGuideView: %@ cropOrigin/size: %@/%@",
               NSStringFromCGRect(_viewToCrop.frame),
               NSStringFromCGRect(_cropGuideView.frame),
               NSStringFromCGPoint(_cropOrigin),
               NSStringFromCGSize(_cropGuideSize));
}

#pragma mark - ScrollView management/delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _viewToCrop;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    // Adjust scrollView contentSize
    _scrollView.contentSize = CGSizeMake(_viewToCrop.frame.size.width + (2.0 * _cropOrigin.x),
                                         _viewToCrop.frame.size.height + (2.0 * _cropOrigin.y));
    
    // Also adjust the viewToCrop's origin?
    if (_allowAspectFit)
    {
        // Normal
        if (_scrollView.zoomScale >= _aspectFillFactor)
        {
            _viewToCrop.origin = _cropOrigin;
        }
        // Centered
        else
        {
            BOOL landscape = _viewToCrop.size.width > _viewToCrop.size.height;
            _viewToCrop.origin = CGPointMake(_cropOrigin.x + (landscape ? 0.0 :(_cropGuideSize.width - _viewToCrop.size.width) / 2.0),
                                             _cropOrigin.y + (landscape ? (_cropGuideSize.height - _viewToCrop.size.height) / 2.0 : 0.0));
        }
    }
}

@end


@implementation CropGuideView

- (void)drawRect:(CGRect)rect
{
    // Settings
    UIColor * brightColor = [UIColor colorWithRed: 1.0 green: 1.0 blue: 1.0 alpha: 0.75];
    UIColor * darkColor = [UIColor colorWithRed: 0.5 green: 0.5 blue: 0.5 alpha: 0.75];
    CGFloat rectangleStrokeWidth = 4;
    CGFloat rectanglePattern[] = {4, 4, 4, 4};
    CGRect rectangleFrame = self.bounds;
    
    // Rectangle drawing
    UIBezierPath * rectanglePath = [UIBezierPath bezierPathWithRect: rectangleFrame];
    rectanglePath.lineWidth = rectangleStrokeWidth;
    [darkColor setStroke];
    [rectanglePath setLineDash:rectanglePattern count:4 phase:2];
    [rectanglePath stroke];
    
    // Dashed line drawing
    [brightColor setStroke];
    [rectanglePath setLineDash:rectanglePattern count:4 phase:6];
    [rectanglePath stroke];
}

@end

