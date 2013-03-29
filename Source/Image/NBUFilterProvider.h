//
//  NBUFilterProvider.h
//  NBUKit
//
//  Created by エルネスト 利辺羅 on 12/05/03.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

/**
 Protocol to be adopted by filter library wrappers.
 
 For each new library of filters a NBUFilterProvider compliant class whould be created
 (i.e. NBUCoreImageFilterProvider, NBUGPUImageFilterProvider).
 */
@protocol NBUFilterProvider <NSObject>

/// Each filter must be a NSMutableDictionary with the keys above
+ (NSArray *)availableFilterTypes;

/// Create a new NBUFilter of a given type, optionally setting a given name and initial values.
/// @param name An optional filter name.
/// @param type The desired filter type.
/// @param values The optional initial values.
+ (NBUFilter *)filterWithName:(NSString *)name
                         type:(NSString *)type
                       values:(NSArray *)values;

/// Apply filters to an image.
/// @param filters An array of NBUFilter objects to be applied sequentially.
/// @param image The source image.
/// @return A new image with the filters applied to.
+ (UIImage *)applyFilters:(NSArray *)filters
                  toImage:(UIImage *)image;

@end

/**
 The main filter provider wrapping class.
 
 This class will provide a mix of filters from different libraries and manage their usage.
 */
@interface NBUFilterProvider : NSObject <NBUFilterProvider>

/// Register a custom NBUFilterProvider.
/// @param provider The custom provider's class.
+ (void)addProvider:(Class<NBUFilterProvider>)provider;

@end

