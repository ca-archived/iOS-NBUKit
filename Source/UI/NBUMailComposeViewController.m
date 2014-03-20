//
//  NBUMailComposeViewController.m
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

#import "NBUMailComposeViewController.h"
#import "NBUKitPrivate.h"
#import "NSDictionary+RKAdditions.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_UI

// Class extension
@interface NBUMailComposeViewController () <MFMailComposeViewControllerDelegate>

@end


@implementation NBUMailComposeViewController
{
    void (^_resultBlock)(MFMailComposeResult result, NSError * error);
}

- (instancetype)initWithMailtoURL:(NSURL *)mailtoURL
                      resultBlock:(void (^)(MFMailComposeResult, NSError *))resultBlock
{
    // Handle errors
    NSInteger errorCode = 0;
    NSString * errorMessage;
    if (![mailtoURL.scheme isEqualToString:@"mailto"])
    {
        errorCode = -10;
        errorMessage = [NSString stringWithFormat:@"Not a proper mailto URL: %@", mailtoURL];
    }
    if (!MFMailComposeViewController.canSendMail)
    {
        errorCode = -20;
        errorMessage = @"No configured email account available.";
    }
    if (errorCode)
    {
        NSError * error = [NSError errorWithDomain:@"NBUMailComposeErrorDomain"
                                              code:errorCode
                                          userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
        NBULogError(@"%@", error);
        if (resultBlock) resultBlock(MFMailComposeResultFailed, error);
        return nil;
    }
    
    self = [super init];
    if (self)
    {
        // Parsing
        NSArray * components = [[mailtoURL.absoluteString substringFromIndex:@"mailto:".length] componentsSeparatedByString:@"?"];
        NSArray * recipients = components.count > 0 ? [components[0] componentsSeparatedByString:@","] : nil;
        NSDictionary * parameters = components.count == 2 ? [NSDictionary dictionaryWithURLEncodedString:components[1]] : nil;
        
        NBULogVerbose(@"Presenting email composer to: %@ with parameters: %@", recipients, parameters);
        
        // Set block
        _resultBlock = resultBlock;
        
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

