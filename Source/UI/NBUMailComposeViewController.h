//
//  NBUMailComposeViewController.h
//  NBUKit
//
//  Created by 利辺羅 on 2012/10/31.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
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
- (id)initWithMailtoURL:(NSURL *)mailtoURL;

/// An optional block to be called instead of a using the usual delegate methods.
@property (nonatomic, strong) void(^resultBlock)(MFMailComposeResult result, NSError * error);

@end

