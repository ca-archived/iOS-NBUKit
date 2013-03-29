//
//  ObjectView.h
//  NBUBase
//
//  Created by エルネスト 利辺羅 on 12/02/07.
//  Copyright (c) 2012年 CyberAgent Inc. All rights reserved.
//

#import "ActiveView.h"

@class ObjectViewController;

/// Notification that is posted when the view's preferred size changes
extern NSString * const ObjectDeletedNotification;

/**
 Abstract UIView that presents a non UI _object_.
 
 Should update its outlets, subviews and state when setObject: is called.
 
 Subclasses should:
 
 - Override the object property (.h file), i.e.:
 
        @property (strong, nonatomic, setter = setObject:, getter = object) UIImage * image;
 
 - Override the setObject setter calling first super (.m file), i.e.:
 
        - (void)setObject:(UIImage *)image
        {
            super.object = image;

            // Configure the view ocording to the object (in this case an image)
            _imageView.image = image;
 
            ...
        }
 
 @note Should be initialized from a Nib file.
 */
@interface ObjectView : ActiveView <UIActionSheetDelegate>
{
    UIActionSheet * _deleteActionSheet;
    UIView * _mask;
    BOOL _isShowMask;
}

/// @name Properties

/// Associated object.
///
/// Override in subclasses with a more concrete class and name, i.e.:
///     @property (strong, nonatomic, setter = setObject:, getter = object) UIImage * image;
@property (strong, nonatomic) id object;

/// Its expected class (including subclasses).
@property (nonatomic, readonly) Class expectedClass;

/// Reset the view outlets and properties.
- (void)reset;

/// @name Methods

/// Used to show the same object with another view in a new screen.
/// @param nibName The Nib file to where to load the ObjectView from.
/// @param title The title to be set to the UINavigationBar.
/// @note the calling view must be inside a UIViewController that is inside a UINavigationController.
- (void)pushObjectWithNibName:(NSString *)nibName
                        title:(NSString *)title;

/// Used to show the same object with another view in a new screen.
/// @param controller The controller to be pushed.
/// @param title The title to be set to the UINavigationBar.
/// @note the calling view must be inside a UIViewController that is inside a UINavigationController.
- (void)pushObjectWithController:(ObjectViewController *)controller
                           title:(NSString *)title;

- (void)hiddenMask;

/// @name Deleting the ObjectView

/// Ask the user to confirm deletion using a UIActionSheet.
/// @param sender The sender object.
- (IBAction)promptDelete:(id)sender;

/// Effectively remove the view
/// @param sender The sender object.
/// @note Subclasses should override this method to delete the underlying model object and then call the super method.
- (IBAction)deleteObject:(id)sender;



@end

