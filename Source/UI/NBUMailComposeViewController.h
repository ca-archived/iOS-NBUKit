//
//  NBUMailComposeViewController.h
//  NBUKit
//
//  Created by Ernesto Rivera on 2012/10/31.
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

#import <MessageUI/MFMailComposeViewController.h>

/**
 A MFMailComposeViewController with convenince methods.
 
 - Can be used with blocks instead of delegates.
 - Can be configured with a `mailto:` URL.
 */
@interface NBUMailComposeViewController : MFMailComposeViewController

/// Initialize and configure parameters by parsing a `mailto:` URL.
/// @param mailtoURL The `mailto:` URL.
/// @param resultBlock An optional block to be called instead of a using the usual delegate methods.
- (instancetype)initWithMailtoURL:(NSURL *)mailtoURL
                      resultBlock:(void (^)(MFMailComposeResult, NSError *))resultBlock;

@end

