//
//  NBUMailComposeViewController.m
//  NBUKit
//
//  Created by 利辺羅 on 2012/10/31.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import "NBUMailComposeViewController.h"
#import "NSDictionary+RKAdditions.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_UI

// Private category
@interface NBUMailComposeViewController (Private) <MFMailComposeViewControllerDelegate>

@end


@implementation NBUMailComposeViewController

@synthesize resultBlock = _resultBlock;

- (id)initWithMailtoURL:(NSURL *)mailtoURL
{
    self = [super init];
    if (self &&
        [mailtoURL.scheme isEqualToString:@"mailto"])
    {
        // Parsing
        NSArray * components = [[mailtoURL.absoluteString substringFromIndex:@"mailto:".length] componentsSeparatedByString:@"?"];
        NSArray * recipients = components.count > 0 ? [components[0] componentsSeparatedByString:@","] : nil;
        NSDictionary * parameters = components.count == 2 ? [NSDictionary dictionaryWithURLEncodedString:components[1]] : nil;
        
        NBULogVerbose(@"Presenting email composer to: %@ with parameters: %@", recipients, parameters);
        
        // Configure self
        [self setToRecipients:recipients];
        [self setSubject:parameters[@"subject"]];
        [self setMessageBody:parameters[@"body"]
                      isHTML:NO];
        
        // Set default mailComposeDelete = self
        self.mailComposeDelegate = self;
    }
    return self;
}

- (void)setResultBlock:(void (^)(MFMailComposeResult result, NSError * error))resultBlock
{
    _resultBlock = resultBlock;
    
    if (resultBlock)
    {
        if (self.mailComposeDelegate &&
            self.mailComposeDelegate != self)
        {
            NBULogWarn(@"Compose delegate '%@' will be ignored because resultBlock was set.",
                         self.mailComposeDelegate);
        }
        self.mailComposeDelegate = self;
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    NBULogVerbose(@"Mail composer result: %d", result);
    if (error)
    {
        NBULogError(@"Mail composer error: %@", error);
    }
    
    if (_resultBlock) _resultBlock(result, error);
    
    // Try to dismiss ownself
    [self dismiss:self];
}

@end

