//
//  ScrollViewController.m
//  NBUCompatibility
//
//  Created by Ernesto Rivera on 2012/02/07.
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

#import "ScrollViewController.h"
#import "NBUKitPrivate.h"

// Define module
#undef  NBUKIT_MODULE
#define NBUKIT_MODULE   NBUKIT_MODULE_COMPATIBILITY

#define kMinIntervalBetweenNotifications 1.0
#define kContentSizeCalculationInterval 1.0
#define kMinIntervalBetweenPromptUpdates 0.3

NSString * const ScrollViewContentOffsetChangedNotification = @"ScrollViewContentOffsetChangedNotification";
NSString * const ScrollViewDidScrollNotification = @"ScrollViewDidScrollNotification";
NSString * const ScrollViewEndScrollNotification = @"ScrollViewEndScrollNotification";

static NSString * customBackButtonTitle;

@implementation ScrollViewController
{
    BOOL _keyboardShown;
    NSTimer * _promptAutohideTimer;
    NSString * _prompt;
    NSDate * _lastPromptUpdate;
    NSTimer * _updatePromptTimer;
    UIBarButtonItem * _rightBarButtonItem;
    NSDate * _lastContentOffsetNotification;
    NSTimer * _sendNotificationTimer;
    BOOL _rightButtonSaved;
    BOOL _barsHidden;
}

+ (void)setCustomBackButtonTitle:(NSString *)title
{
    customBackButtonTitle = title;
}

- (UIScrollView *)createScrollView
{
    _scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.clipsToBounds = NO;
    return _scrollView;
}

- (void)loadView
{
    // Try to load self.view
    
    // Let super load it
    NSString * nibName = self.nibName;
    if (self.storyboard &&                  // Has a Storyboard
        nibName &&                          // Has an assigned nibName
        ![NSBundle pathForResource:nibName  // But the nibName is not really Nib file but a Storyboard ID
                            ofType:@"nib"])
    {
        [super loadView];
        return;
    }
    
    // From a Nib
    if (!nibName || nibName.length == 0)
    {
        nibName = NSStringFromClass([self class]);
    }
    if([NSBundle pathForResource:nibName
                          ofType:@"nib"])
    {
        NBULogVerbose(@"Loading nib '%@' for class '%@'", nibName, NSStringFromClass([self class]));
        
        // Check if set with owner
        NSArray * loadedObjects = [NSBundle loadNibNamed:nibName
                                                   owner:self
                                                 options:nil];
        // Else set it to the first loaded object
        if (!self.isViewLoaded &&
            [loadedObjects[0] isKindOfClass:[UIView class]])
        {
            self.view = loadedObjects[0];
        }
        
        return;
    }
    
    // Else if still not set create an empty one
    NBULogInfo(@"~~~ Nib for class %@ didn't set a view. An empty scrollView will be created",
               NSStringFromClass([self class]));
    self.view = [self createScrollView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Make sure scrollView is set
    if (!_scrollView)
    {
        // Set it to self.view?
        if ([self.view isKindOfClass:[UIScrollView class]])
        {
            _scrollView = (UIScrollView *)self.view;
        }
        
        // Create a new one and set it as the new self.view
        else
        {
            // Save the current self.view?
            if (!_contentView)
            {
                _contentView = self.view;
            }
            self.view = [self createScrollView];
        }
    }
    
    // Set scrollView delegate
    _scrollView.delegate = self;
    
    // Register for KVO
    if (_hidesBarsOnScroll)
    {
        [_scrollView addObserver:self
                      forKeyPath:@"contentOffset"
                         options:NSKeyValueObservingOptionOld
                         context:nil];
    }
    
    // Make sure contentView is set
    if (!_contentView)
    {
        // If not set we expect it to be a scrollView's subview
        if ([_scrollView subviews].count == 0)
        {
            @throw [NSException exceptionWithName:@"ScrollViewControllerException"
                                           reason:[NSString stringWithFormat:@"%@ A contentView couldn't be found", self]
                                         userInfo:nil];
        }
        _contentView = (_scrollView.subviews)[0];
    }
    
    // Add contentView to scrollView if necessary
    if (_contentView.superview != _scrollView)
    {
        CGRect bounds = _scrollView.bounds;
        CGRect frame = _contentView.frame;
        _contentView.frame = CGRectMake(bounds.origin.x,
                                        bounds.origin.y,
                                        bounds.size.width, 
                                        frame.size.height);
        [_scrollView addSubview:_contentView];
    }
    
    // Make sure the controller's view autoresizes as needed
    self.view.autoresizingMask = (self.view.autoresizingMask |
                                  UIViewAutoresizingFlexibleHeight |
                                  UIViewAutoresizingFlexibleWidth);
    
    NBULogVerbose(@"~~~ %@ %p viewDidLoad", NSStringFromClass([self class]), self);
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view
    NBULogVerbose(@"~~~ %@ %p viewDidUnload", NSStringFromClass([self class]), self);
    
    // Unregister KVO
    self.hidesBarsOnScroll = NO;
    
    _scrollView = nil;
    _contentView = nil;
    _activeField = nil;
    _promptAutohideTimer = nil;
    _updatePromptTimer = nil;
//    _fireSizeToFitTimer = nil;
    _sendNotificationTimer = nil;
    
    [super viewDidUnload];
}

- (void)setHidesBarsOnScroll:(BOOL)hidesBarsOnScroll
{
    if (_hidesBarsOnScroll == hidesBarsOnScroll)
        return;
    
    _hidesBarsOnScroll = hidesBarsOnScroll;
    
    // If the view was already loaded we need to register/unregister for KVO again
    if (self.isViewLoaded)
    {
        if (hidesBarsOnScroll)
        {
            [_scrollView addObserver:self
                          forKeyPath:@"contentOffset"
                             options:NSKeyValueObservingOptionOld
                             context:nil];
        }
        else
        {
            [_scrollView removeObserver:self
                             forKeyPath:@"contentOffset"];
        }
    }
}

- (void)setScrollViewContentSize:(CGSize)size
{
    if (!CGSizeEqualToSize(size, _scrollView.contentSize))
    {
        NBULogVerbose(@">> %@ %@",
              NSStringFromCGSize(_scrollView.contentSize), NSStringFromCGPoint(_scrollView.contentOffset));
//        CGPoint offset = _scrollView.contentOffset;
        _scrollView.contentSize = size;
//        _scrollView.contentOffset = offset;
        NBULogVerbose(@"<< %@ %@",
              NSStringFromCGSize(_scrollView.contentSize), NSStringFromCGPoint(_scrollView.contentOffset));
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // Update scrollView content size
    [self setScrollViewContentSize:_contentView.bounds.size];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Set custom back button
    if (customBackButtonTitle || _customBackButtonTitle)
    {
        // Reset?
        if (_customBackButtonTitle && _customBackButtonTitle.length == 0)
        {
            self.navigationItem.backBarButtonItem = nil;
        }
        
        // Set
        else
        {
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:customBackButtonTitle ? customBackButtonTitle : _customBackButtonTitle
                                                                                     style:UIBarButtonItemStylePlain
                                                                                    target:nil
                                                                                    action:nil];
        }
    }
    
    // Observe subviews' size changes
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sizeThatFitsChanged:)
                                                 name:SizeThatFitsChangedNotification
                                               object:nil];
    
    // Observe scroll requests
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollToVisible:)
                                                 name:ScrollToVisibleNotification
                                               object:nil];
    
    // Observe keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    // Observe text view and text field notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateActiveField:)
                                                 name:UITextViewTextDidBeginEditingNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateActiveField:)
                                                 name:UITextFieldTextDidBeginEditingNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Update scrollView content size
    [self setScrollViewContentSize:_contentView.bounds.size];
    
    
    // Post a first notification
    [self postScrollViewContentOffsetChangedNotification];
    
    if (CGSizeEqualToSize(_scrollView.contentSize, CGSizeZero))
    {
        [self sizeToFitContentView:self];
//        _lastContentSizeCalculation = [NSDate dateWithTimeIntervalSince1970:0.0]; // Ignore first update date
    }
    
    NBULogVerbose(@"--- %@ %@", self.view, _scrollView);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self clearPrompt];
    [_activeField resignFirstResponder];
//    [_fireSizeToFitTimer invalidate];
    [_updatePromptTimer invalidate];
    [_promptAutohideTimer invalidate];
    [_sendNotificationTimer invalidate];
    
    // Show bars before disappearing
    if (_hidesBarsOnScroll && _barsHidden)
    {
        [self.navigationController setNavigationBarHidden:NO
                                                 animated:animated];
        [self.tabBarController setTabBarHidden:NO
                                      animated:animated];
        _barsHidden = NO;
    }
    
#ifdef NBUCOMPATIBILITY
    // Cancel all image loads
    [[ImageLoader sharedLoader] cancelLoadForAllPaths];
#endif
    
    // Stop listening to notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:SizeThatFitsChangedNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:ScrollToVisibleNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidBeginEditingNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidBeginEditingNotification
                                                  object:nil];
}

- (void)didReceiveMemoryWarning
{
    NBULogVerbose(@"~~~ %@ %p didReceiveMemoryWarning. View %@ has superview %@",
               NSStringFromClass([self class]), self,
               NBUStringFromBOOL(self.isViewLoaded),
               NBUStringFromBOOL(self.isViewLoaded && self.view.superview));
    
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    NBULogVerbose(@"~~~ %@ %p dealloc. View %@ has superview %@",
               NSStringFromClass([self class]), self,
               NBUStringFromBOOL(self.isViewLoaded),
               NBUStringFromBOOL(self.isViewLoaded && self.view.superview));
    
    // Unregister KVO
    self.hidesBarsOnScroll = NO;
}

#pragma mark - Methods/Actions

- (void)sizeThatFitsChanged:(NSNotification *)notification
{
    [self sizeToFitContentView:self];
//    // Not too soon -> fire
//    if ([[NSDate date] timeIntervalSinceDate:_lastContentSizeCalculation] > kContentSizeCalculationInterval ||
//        [notification.object isKindOfClass:[ObjectTableView class]])
////        [notification.object isKindOfClass:[ObjectTableView class]] ||
////        [notification.object isKindOfClass:[ObjectGridView class]] )
//    {
//        NBULogVerbose(@"*** sizeToFitContentView direct");
//        [self sizeToFitContentView:self];
//    }
//    
//    // Too soon -> (re)schedule
//    else @synchronized(self)
//    {
//        NBULogVerbose(@"*** sizeToFitContentView scheduled");
//        [_fireSizeToFitTimer invalidate];
//        _fireSizeToFitTimer = [NSTimer scheduledTimerWithTimeInterval:kContentSizeCalculationInterval
//                                                               target:self
//                                                             selector:@selector(sizeToFitContentView:)
//                                                             userInfo:nil
//                                                              repeats:NO];
//    }
}

- (IBAction)sizeToFitContentView:(id)sender
{
//    if ([sender isKindOfClass:[NSTimer class]])
//    {
//        NBULogVerbose(@"*** sizeToFitContentView fired");
//    }
    
//    [_fireSizeToFitTimer invalidate];
//    _lastContentSizeCalculation = [NSDate date];
    
    CGSize sizeThatFits = [_contentView sizeThatFits:CGSizeMake(_scrollView.bounds.size.width,
                                                                CGFLOAT_MAX)];
    
    [UIView animateWithDuration:_animated ? 0.2 : 0.0
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         
                         _contentView.frame = CGRectMake(_contentView.frame.origin.x,
                                                         _contentView.frame.origin.y,
                                                         sizeThatFits.width,
                                                         sizeThatFits.height);
                         [self setScrollViewContentSize:sizeThatFits];
                         NBULogVerbose(@"*** sizeToFitContentView = %@", NSStringFromCGSize(_scrollView.contentSize));
                         
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)postScrollViewContentOffsetChangedNotification
{
    // Too soon?
    if ([[NSDate date] timeIntervalSinceDate:_lastContentOffsetNotification] < kMinIntervalBetweenNotifications)
    {
        // Schedule if not already scheduled
        if (!_sendNotificationTimer.isValid) @synchronized(self)
        {
            NBULogVerbose(@"postScrollViewContentOffsetChangedNotification scheduled");
            [_sendNotificationTimer invalidate];
            _sendNotificationTimer = [NSTimer scheduledTimerWithTimeInterval:kMinIntervalBetweenNotifications
                                                                      target:self
                                                                    selector:@selector(postScrollViewContentOffsetChangedNotification)
                                                                    userInfo:nil
                                                                     repeats:NO];
        }
        return;
    }
    
    NBULogVerbose(@"postScrollViewContentOffsetChangedNotification");
    
    _lastContentOffsetNotification = [NSDate date];
    [[NSNotificationCenter defaultCenter] postNotificationName:ScrollViewContentOffsetChangedNotification
                                                        object:_scrollView];
}

- (void)postScrollVieEndNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ScrollViewEndScrollNotification
                                                        object:_scrollView];
}

#pragma mark - Prompt methods

- (void)setPrompt
{
    self.navigationItem.prompt = _prompt;
    _lastPromptUpdate = [NSDate date];
}

- (void)setPrompt:(NSString *)prompt
        autoClear:(BOOL)yesOrNo
{
    [_promptAutohideTimer invalidate];
    _prompt = prompt;
    
    // Not too soon?
    if ([[NSDate date] timeIntervalSinceDate:_lastPromptUpdate] >= kMinIntervalBetweenPromptUpdates)
    {
        [self setPrompt];
    }
    
    // Schedule update if not scheduled
    else if (![_updatePromptTimer isValid]) @synchronized(self)
    {
        [_updatePromptTimer invalidate];
        _updatePromptTimer = [NSTimer scheduledTimerWithTimeInterval:kMinIntervalBetweenPromptUpdates
                                                              target:self
                                                            selector:@selector(setPrompt)
                                                            userInfo:nil
                                                             repeats:NO];
    }
    
    // Autohide?
    if (yesOrNo) @synchronized(self)
    {
        [_promptAutohideTimer invalidate];
        _promptAutohideTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                                target:self
                                                              selector:@selector(clearPrompt)
                                                              userInfo:nil
                                                               repeats:NO];
    }
}

- (void)clearPrompt
{
    [_promptAutohideTimer invalidate];
    [_updatePromptTimer invalidate];
    
    self.navigationItem.prompt = nil;
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([_lastContentOffsetNotification timeIntervalSinceNow] < -kMinIntervalBetweenNotifications)
    {
        [self postScrollViewContentOffsetChangedNotification];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ScrollViewDidScrollNotification
                                                        object:_scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // *** Call from subclasses as may be implemented in the future ***
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self postScrollViewContentOffsetChangedNotification];
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self postScrollViewContentOffsetChangedNotification];
    
    [self postScrollVieEndNotification];
}

#pragma mark - Keyboard notifications handling

- (void)scrollViewToVisible:(UIView *)view
                  topMargin:(CGFloat)topMargin
               bottomMargin:(CGFloat)bottomMargin
{
    CGRect rect = [_scrollView convertRect:view.bounds
                                  fromView:view];
    rect.origin.x -= topMargin;
    rect.size.height += topMargin + bottomMargin;
    [_scrollView scrollRectToVisible:rect
                            animated:YES];
}

- (void)scrollToVisible:(NSNotification *)notification
{
    NBULogVerbose(@"scrollToVisible %@", notification.object);
    if ([notification.object isKindOfClass:[UIView class]])
    {
        [self scrollViewToVisible:notification.object
                        topMargin:5.0
                     bottomMargin:5.0];
    }
}

//- (void)scrollToActiveField
//{
//    NBULogVerbose(@"scrollToActiveField %@ (+ 10.0)", _activeField);
//    CGRect rect = [_scrollView convertRect:_activeField.bounds
//                                  fromView:_activeField];
//    rect.size.height += 10.0;
//    [_scrollView scrollRectToVisible:rect
//                            animated:YES];
//}

- (IBAction)hideKeyboard:(id)sender
{
    NBULogVerbose(@"hideKeyboard %@ %@",
               NBUStringFromBOOL(_activeField.isFirstResponder), _activeField);
    
    if (_activeField)
    {
        [_activeField resignFirstResponder];
    }
    else
    {
        // webview等の場合
        [self.view endEditing:YES];
    }
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    NBULogVerbose(@"keyboardWillShow %@ %@ %@",
               NBUStringFromBOOL(_activeField.isFirstResponder), _activeField, _activeField.inputAccessoryView);
    
    // Calculate the rect that gets hidden by the keyboard
    NSDictionary * info = [notification userInfo];
    CGRect rect = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    rect = [_scrollView convertRect:rect
                           fromView:nil];
    rect = CGRectIntersection(rect, _scrollView.bounds);
    
    // Adjust content insets to avoid hidding content
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 
                                                  0.0,
                                                  rect.size.height,
                                                  0.0);
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;

    // Scroll to activeField
    if (!_keyboardShown && _activeField)
    {
        [self scrollViewToVisible:_activeField
                        topMargin:5.0
                     bottomMargin:10.0];
    }
    
    // Switch right button
    if (!_rightButtonSaved)
    {
        _rightBarButtonItem = self.navigationItem.rightBarButtonItem;
        _rightButtonSaved = YES;
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                                 target:self
                                                                                                 action:@selector(hideKeyboard:)]
                                          animated:YES];
    }
    
    _keyboardShown = YES;
}

- (void)keyboardDidShow:(NSNotification*)notification
{
    // Make sure activeField is the first responder
    [_activeField becomeFirstResponder];
    
    NBULogVerbose(@"keyboardDidShow %@ %@ %@",
               NBUStringFromBOOL(_activeField.isFirstResponder), _activeField, _activeField.inputAccessoryView);
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    NBULogVerbose(@"keyboardWillHide %@ %@",
               NBUStringFromBOOL(_activeField.isFirstResponder), _activeField);
    
//    [UIView animateWithDuration:0.3
//                     animations:^{
                         
                         UIEdgeInsets contentInsets = UIEdgeInsetsZero;
                         _scrollView.contentInset = contentInsets;
                         _scrollView.scrollIndicatorInsets = contentInsets;
//                     }];

    // Restore accessoryView
//    if ([_activeField respondsToSelector:@selector(restoreAccessoryView)])
//    {
//        [_activeField performSelector:@selector(restoreAccessoryView)];
//    }
    
    // Restore back right button
    // 2012.07.04 modify start by Kubota
    // 「キーボードを出したまま戻るボタンを押すと右上のボタンが消える」対応
    //if (_rightBarButtonItem)
    
    // 2012.07.09 modify start by Caesar
    //　「完了」の前、右上のボタンなかった場合、完了ボタンが消えるため
    if(_rightButtonSaved) // end modify by Caesar
    {
        [self.navigationItem setRightBarButtonItem:_rightBarButtonItem
                                          animated:YES];
        _rightBarButtonItem = nil;
        _rightButtonSaved = NO;
    }

    // 2012.07.04 modify start by Kubota
    // 「アイテムサーチのアイテムID入力フィールドが上に上がらないことがある」対応
     _keyboardShown = NO;
}

- (void)keyboardDidHide:(NSNotification*)notification
{
    NBULogVerbose(@"keyboardDidHide %@ %@",
               NBUStringFromBOOL(_activeField.isFirstResponder), _activeField);
    
    // Restore accessoryView
//    if ([_activeField respondsToSelector:@selector(restoreAccessoryView)])
//    {
//        [_activeField performSelector:@selector(restoreAccessoryView)];
//    }

    // 2012.08.08 modify start by Kubota
    // テキスト入力で、変換候補一覧を表示して元の画面に戻ると完了ボタンが効かない
//    _activeField = nil;
    if( !_activeField.isFirstResponder 
       // 2012.08.16 Caesar. If the active field changes and then this is called, the 完了 button doesnt work
       // Just make sure that the object calling is the one you expect it to be
       && notification.object == _activeField )
    {
        _activeField = nil ;
    }

    // 2012.07.04 modify start by Kubota
    // 「アイテムサーチのアイテムID入力フィールドが上に上がらないことがある」対応
//    _keyboardShown = NO;
}

#pragma mark - Text view and field notifications handling

- (void)updateActiveField:(NSNotification*)notification
{
    if (![notification.object isKindOfClass:[UIView class]])
        return;
    
    _activeField = (UIView *)notification.object;
    
    if (_keyboardShown)
    {
        [self scrollViewToVisible:_activeField
                        topMargin:5.0
                     bottomMargin:10.0];
    }
}

#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    CGPoint oldOffset = [(NSValue *)change[NSKeyValueChangeOldKey] CGPointValue];
    
    if (!_hidesBarsOnScroll || _scrollView.contentOffset.y == oldOffset.y)
        return;
    
    // Show on scroll up
    if (_barsHidden &&
        _scrollView.contentOffset.y < oldOffset.y &&
        _scrollView.contentOffset.y + _scrollView.bounds.size.height < _scrollView.contentSize.height) // Skip on bottom
    {
        [self.navigationController setNavigationBarHidden:NO
                                                 animated:YES];
        [self.tabBarController setTabBarHidden:NO
                                      animated:YES];
        _barsHidden = NO;
    }
    
    // Hide on scroll down
    if (!_barsHidden &&
        _scrollView.contentOffset.y > 0 && // Skip on top
        _scrollView.contentOffset.y > oldOffset.y)
    {
        [self.navigationController setNavigationBarHidden:YES
                                                 animated:YES];
        [self.tabBarController setTabBarHidden:YES
                                      animated:YES];
        _barsHidden = YES;
    }
}

@end

