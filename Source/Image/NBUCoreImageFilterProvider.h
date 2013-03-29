//
//  NBUCoreImageFilterProvider.h
//  NBUKit
//
//  Created by エルネスト 利辺羅 on 12/05/01.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import "NBUFilterProvider.h"

/**
 Wrapper NBUFilterProvider for CoreImage filters.
 
 iOS5+ filters:
 
     - CIAdditionCompositing,
     - CIAffineTransform,
     - CICheckerboardGenerator,
     - CIColorBlendMode,
     - CIColorBurnBlendMode,
     - CIColorControls,
     - CIColorCube,
     - CIColorDodgeBlendMode,
     - CIColorInvert,
     - CIColorMatrix,
     - CIColorMonochrome,
     - CIConstantColorGenerator,
     - CICrop,
     - CIDarkenBlendMode,
     - CIDifferenceBlendMode,
     - CIExclusionBlendMode,
     - CIExposureAdjust,
     - CIFalseColor,
     - CIGammaAdjust,
     - CIGaussianGradient,
     - CIHardLightBlendMode,
     - CIHighlightShadowAdjust,
     - CIHueAdjust,
     - CIHueBlendMode,
     - CILightenBlendMode,
     - CILinearGradient,
     - CILuminosityBlendMode,
     - CIMaximumCompositing,
     - CIMinimumCompositing,
     - CIMultiplyBlendMode,
     - CIMultiplyCompositing,
     - CIOverlayBlendMode,
     - CIRadialGradient,
     - CISaturationBlendMode,
     - CIScreenBlendMode,
     - CISepiaTone,
     - CISoftLightBlendMode,
     - CISourceAtopCompositing,
     - CISourceInCompositing,
     - CISourceOutCompositing,
     - CISourceOverCompositing,
     - CIStraightenFilter,
     - CIStripesGenerator,
     - CITemperatureAndTint,
     - CIToneCurve,
     - CIVibrance,
     - CIVignette,
     - CIWhitePointAdjust
 
 iOS6+ filters:
 
     - CIAffineClamp,
     - CIAffineTile,
     - CIBarsSwipeTransition,
     - CIBlendWithMask,
     - CIBloom,
     - CIBumpDistortion,
     - CIBumpDistortionLinear,
     - CICircleSplashDistortion,
     - CICircularScreen,
     - CIColorMap,
     - CIColorPosterize,
     - CICopyMachineTransition,
     - CIDisintegrateWithMaskTransition,
     - CIDissolveTransition,
     - CIDotScreen,
     - CIEightfoldReflectedTile,
     - CIFlashTransition,
     - CIFourfoldReflectedTile,
     - CIFourfoldRotatedTile,
     - CIFourfoldTranslatedTile,
     - CIGaussianBlur,
     - CIGlideReflectedTile,
     - CIGloom,
     - CIHatchedScreen,
     - CIHoleDistortion,
     - CILanczosScaleTransform,
     - CILightTunnel,
     - CILineScreen,
     - CIMaskToAlpha,
     - CIMaximumComponent,
     - CIMinimumComponent,
     - CIModTransition,
     - CIPerspectiveTile,
     - CIPerspectiveTransform,
     - CIPerspectiveTransformWithExtent,
     - CIPinchDistortion,
     - CIPixellate,
     - CIRandomGenerator,
     - CISharpenLuminance,
     - CISixfoldReflectedTile,
     - CISixfoldRotatedTile,
     - CISmoothLinearGradient,
     - CIStarShineGenerator,
     - CISwipeTransition,
     - CITriangleKaleidoscope,
     - CITwelvefoldReflectedTile,
     - CITwirlDistortion,
     - CIUnsharpMask,
     - CIVortexDistortion,
 */
@interface NBUCoreImageFilterProvider : NSObject <NBUFilterProvider>

@end

