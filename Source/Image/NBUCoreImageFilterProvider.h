//
//  NBUCoreImageFilterProvider.h
//  NBUKit
//
//  Created by Ernesto Rivera on 12/05/01.
//  Copyright (c) 2012 CyberAgent Inc.
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

