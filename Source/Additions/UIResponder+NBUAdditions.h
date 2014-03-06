//
//  UIResponder+NBUAdditions.h
//  NBUKit
//
//  Created by Wirth Caesar on 2012/08/08.
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

/**
 Convenience methods to send actions through the responder chain.
 */
@interface UIResponder (NBUAdditions)

/// Send an action to through the object's responder chain.
/// @param action A selector to be invocated.
/// @param sender The sending object.
/// @param event An optional UIEvent.
/// @return Whether or not the action found a target.
- (BOOL)sendAction:(SEL)action
              from:(id)sender
          forEvent:(UIEvent*)event;

@end

