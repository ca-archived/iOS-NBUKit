//
//  NBUFilterGroup.h
//  NBUKit
//
//  Created by 利辺羅 on 2013/03/05.
//  Copyright (c) 2013年 CyberAgent Inc. All rights reserved.
//

#import "NBUFilter.h"

/// Predefined filter types
extern NSString * const NBUFilterTypeGroup;

/**
 A container for a group of NBUFilter objects.
 */
@interface NBUFilterGroup : NBUFilter

/// Create a new NBUFilterGroup of a given type, optionally setting a given name and initial filters.
/// @param name An optional filter group name.
/// @param type An optional filter group type.
/// @param filters The optional initial filters.
+ (id)filterGroupWithName:(NSString *)name
                     type:(NSString *)type
                  filters:(NSArray *)filters;

/// The group's filters.
@property (strong, nonatomic) NSArray * filters;

@end

