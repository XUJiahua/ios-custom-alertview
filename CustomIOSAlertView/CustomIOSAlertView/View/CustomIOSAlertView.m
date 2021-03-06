//
//  CustomIOSAlertView.m
//  CustomIOSAlertView
//
//  Created by Richard on 20/09/2013.
//  Copyright (c) 2013-2015 Wimagguc.
//
//  Lincesed under The MIT License (MIT)
//  http://opensource.org/licenses/MIT
//

#import "CustomIOSAlertView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+colorWithHex.h"
#import "UILabel+DynamicHeight.h"

// screen size
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define kCustomIOSAlertViewDefaultWidth kScreenWidth * 0.8
#define kCustomIOSAlertViewDefaultLeading kScreenWidth * 0.05
#define kCustomIOSAlertViewDefaultTrailing kScreenWidth * 0.05

#define kCustomIOSAlertViewDefaultVerticalSpace kScreenHeight * 0.02

// for title style
#define kCustomIOSAlertViewDefaultTitleTop                                     \
kCustomIOSAlertViewDefaultVerticalSpace
#define kCustomIOSAlertViewDefaultTitleBottom                                  \
kCustomIOSAlertViewDefaultVerticalSpace
#define kCustomIOSAlertViewDefaultTitleHeight 40

// for sub title style
#define kCustomIOSAlertViewDefaultSubTitleTop                                  \
kCustomIOSAlertViewDefaultVerticalSpace
#define kCustomIOSAlertViewDefaultSubTitleBottom                               \
kCustomIOSAlertViewDefaultVerticalSpace
#define kCustomIOSAlertViewDefaultSubTitleHeight 40

// for buttons array
#define kCustomIOSAlertViewDefaultButtonHeight 40
#define kCustomIOSAlertViewDefaultButtonsTop                                   \
kCustomIOSAlertViewDefaultVerticalSpace
#define kCustomIOSAlertViewDefaultButtonsBottom                                \
kCustomIOSAlertViewDefaultVerticalSpace
#define kCustomIOSAlertViewDefaultButtonsSpace kScreenWidth * 0.06

#define kCustomIOSAlertViewCornerRadius 7
#define kCustomIOS7MotionEffectExtent 10.0

// font size
#define kCustomTitleFontSize 18.0f
#define kCustomSubTitleFontSize 14.0f
#define kCustomButtonFontSize 16.0f

// icon size
#define kCustomIconWidth 40.0
#define kCustomIconHeight 40.0

@interface CustomIOSAlertView () {
    NSMutableArray *buttons;
}
@end
@implementation CustomIOSAlertView

CGFloat buttonHeight = 0;
// CGFloat buttonSpacerHeight = 0;

@synthesize parentView, containerView, dialogView, onButtonTouchUpInside;
@synthesize delegate;
@synthesize buttonTitles;
@synthesize useMotionEffects;

- (id)initWithParentView:(UIView *)_parentView {
    self = [self init];
    if (_parentView) {
        self.frame = _parentView.frame;
        self.parentView = _parentView;
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,
                                [UIScreen mainScreen].bounds.size.height);
        
        delegate = self;
        useMotionEffects = false;
        buttonTitles = @[ @"Close" ];
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(deviceOrientationDidChange:)
         name:UIDeviceOrientationDidChangeNotification
         object:nil];
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(keyboardWillShow:)
         name:UIKeyboardWillShowNotification
         object:nil];
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(keyboardWillHide:)
         name:UIKeyboardWillHideNotification
         object:nil];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)mTitle
                         icon:(UIImage *)mIcon
                     subTitle:(NSString *)mSubTitle
                 buttonTitles:(NSArray *)mButtonTitles
        onButtonTouchUpInside:
(void (^)(CustomIOSAlertView *alertView,
          int buttonIndex))mOnButtonTouchUpInside {
    self = [self init];
    if (self) {
        [self setIcon:mIcon];
        [self setTitle:mTitle];
        [self setSubTitle:mSubTitle];
        
        [self setButtonTitles:mButtonTitles];
        [self setOnButtonTouchUpInside:mOnButtonTouchUpInside];
        
        [self setUseMotionEffects:true];
    }
    return self;
}

- (NSArray *)buttons {
    return buttons;
}

// Create the dialog view, and animate opening the dialog
- (void)show {
    dialogView = [self createContainerView];
    
    dialogView.layer.shouldRasterize = YES;
    dialogView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
#if (defined(__IPHONE_7_0))
    if (useMotionEffects) {
        [self applyMotionEffects];
    }
#endif
    
    self.backgroundColor =
    [UIColor whiteColor]; //[UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
    [self addSubview:dialogView];
    
    // Can be attached to a view or to the top most window
    // Attached to a view:
    if (parentView != NULL) {
        [parentView addSubview:self];
        
        // Attached to the top most window
    } else {
        
        // On iOS7, calculate with orientation
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
            
            UIInterfaceOrientation interfaceOrientation =
            [[UIApplication sharedApplication] statusBarOrientation];
            switch (interfaceOrientation) {
                case UIInterfaceOrientationLandscapeLeft:
                    self.transform = CGAffineTransformMakeRotation(M_PI * 270.0 / 180.0);
                    break;
                    
                case UIInterfaceOrientationLandscapeRight:
                    self.transform = CGAffineTransformMakeRotation(M_PI * 90.0 / 180.0);
                    break;
                    
                case UIInterfaceOrientationPortraitUpsideDown:
                    self.transform = CGAffineTransformMakeRotation(M_PI * 180.0 / 180.0);
                    break;
                    
                default:
                    break;
            }
            
            [self setFrame:CGRectMake(0, 0, self.frame.size.width,
                                      self.frame.size.height)];
            
            // On iOS8, just place the dialog in the middle
        } else {
            
            CGSize screenSize = [self countScreenSize];
            CGSize dialogSize = [self countDialogSize];
            CGSize keyboardSize = CGSizeMake(0, 0);
            
            dialogView.frame = CGRectMake(
                                          (screenSize.width - dialogSize.width) / 2,
                                          (screenSize.height - keyboardSize.height - dialogSize.height) / 2,
                                          dialogSize.width, dialogSize.height);
        }
        
        [[[[UIApplication sharedApplication] windows] firstObject] addSubview:self];
    }
    
    dialogView.layer.opacity = 0.5f;
    dialogView.layer.transform = CATransform3DMakeScale(1.3f, 1.3f, 1.0);
    
    [UIView animateWithDuration:0.2f
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.backgroundColor = [[UIColor whiteColor]
                                                 colorWithAlphaComponent:0.5]; //[UIColor colorWithRed:0
                         // green:0 blue:0
                         // alpha:0.4f];
                         dialogView.layer.opacity = 1.0f;
                         dialogView.layer.transform =
                         CATransform3DMakeScale(1, 1, 1);
                     }
                     completion:NULL];
}

// Button has been touched
- (IBAction)customIOS7dialogButtonTouchUpInside:(id)sender {
    if (delegate != NULL) {
        [delegate customIOS7dialogButtonTouchUpInside:self
                                 clickedButtonAtIndex:[sender tag]];
    }
    
    if (onButtonTouchUpInside != NULL) {
        onButtonTouchUpInside(self, (int)[sender tag]);
    }
}

// Default button behaviour
- (void)customIOS7dialogButtonTouchUpInside:(CustomIOSAlertView *)alertView
                       clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"Button Clicked! %d, %d", (int)buttonIndex, (int)[alertView tag]);
    [self close];
}

// Dialog close animation then cleaning and removing the view from the parent
- (void)close {
    CATransform3D currentTransform = dialogView.layer.transform;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        CGFloat startRotation =
        [[dialogView valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
        CATransform3D rotation = CATransform3DMakeRotation(
                                                           -startRotation + M_PI * 270.0 / 180.0, 0.0f, 0.0f, 0.0f);
        
        dialogView.layer.transform =
        CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1));
    }
    
    dialogView.layer.opacity = 1.0f;
    
    [UIView animateWithDuration:0.2f
                          delay:0.0
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.backgroundColor =
                         [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
                         dialogView.layer.transform = CATransform3DConcat(
                                                                          currentTransform, CATransform3DMakeScale(0.6f, 0.6f, 1.0));
                         dialogView.layer.opacity = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         for (UIView *v in [self subviews]) {
                             [v removeFromSuperview];
                         }
                         [self removeFromSuperview];
                     }];
}

- (void)setSubView:(UIView *)subView {
    containerView = subView;
}

// Creates the container view here: create the dialog, then add the custom
// content and buttons
- (UIView *)createContainerView {
    if (containerView == NULL) {
        CGFloat width = kCustomIOSAlertViewDefaultWidth;
        CGFloat height = 0;
        
        if ((self.title != nil && ![self.title isEqualToString:@""]) ||
            (self.subTitle != nil || ![self.subTitle isEqualToString:@""])) {
            CGFloat posX = kCustomIOSAlertViewDefaultLeading;
            
            if (self.icon != nil) {
                UIImageView *imageView = [[UIImageView alloc] initWithImage:self.icon];
                imageView.frame = CGRectMake(posX, kCustomIOSAlertViewDefaultTitleTop,
                                             kCustomIconWidth, kCustomIconHeight);
                posX += kCustomIconWidth + kCustomIOSAlertViewDefaultButtonsSpace;
                
                _iconImageView = imageView;
            }
            
            UILabel *label = [[UILabel alloc]
                              initWithFrame:CGRectMake(posX, kCustomIOSAlertViewDefaultTitleTop,
                                                       width - posX -
                                                       kCustomIOSAlertViewDefaultTrailing,
                                                       kCustomIOSAlertViewDefaultTitleHeight)];
            label.text = self.title;
            [label setFont:[UIFont systemFontOfSize:kCustomTitleFontSize]];
            label.adjustsFontSizeToFitWidth = YES;
            //            [label setMinimumScaleFactor:0.8];
            
            label.textColor = [UIColor blackColor];
            //            label.textAlignment = NSTextAlignmentCenter;
            //            [label sizeToFit];
            
            _titleLabel = label;
            
            //            [containerView addSubview:label];
        }
        
        if (self.subTitle != nil && ![self.subTitle isEqualToString:@""]) {
            UILabel *label = [[UILabel alloc]
                              initWithFrame:CGRectMake(kCustomIOSAlertViewDefaultLeading,
                                                       kCustomIOSAlertViewDefaultTitleTop +
                                                       kCustomIOSAlertViewDefaultTitleHeight +
                                                       kCustomIOSAlertViewDefaultTitleBottom +
                                                       kCustomIOSAlertViewDefaultSubTitleTop,
                                                       width - kCustomIOSAlertViewDefaultLeading -
                                                       kCustomIOSAlertViewDefaultTrailing,
                                                       kCustomIOSAlertViewDefaultSubTitleHeight)];
            label.text = self.subTitle;
            label.textColor = [UIColor blackColor];
            //            label.lineBreakMode = NSLineBreakMode;
            label.numberOfLines = 0;
            [label setFont:[UIFont systemFontOfSize:kCustomSubTitleFontSize]];
            label.textAlignment = NSTextAlignmentCenter;
            
            CGSize labelSize = [label sizeOfMultiLineLabel];
            label.frame = CGRectMake(kCustomIOSAlertViewDefaultLeading,
                                     kCustomIOSAlertViewDefaultTitleTop +
                                     kCustomIOSAlertViewDefaultTitleHeight +
                                     kCustomIOSAlertViewDefaultTitleBottom +
                                     kCustomIOSAlertViewDefaultSubTitleTop,
                                     width - kCustomIOSAlertViewDefaultLeading -
                                     kCustomIOSAlertViewDefaultTrailing,
                                     labelSize.height);
            //处理多行的问题
            
            _subTitleLabel = label;
            //            [containerView addSubview:label];
        }
        
        if (self.titleLabel != nil) {
            height += self.titleLabel.frame.size.height +
            kCustomIOSAlertViewDefaultTitleTop +
            kCustomIOSAlertViewDefaultTitleBottom;
        }
        
        if (self.subTitleLabel != nil) {
            height += self.subTitleLabel.frame.size.height +
            kCustomIOSAlertViewDefaultSubTitleTop +
            kCustomIOSAlertViewDefaultSubTitleBottom;
        }
        containerView =
        [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        if (self.titleLabel != nil) {
            if (self.iconImageView != nil) {
                [containerView addSubview:self.iconImageView];
            }
            [containerView addSubview:self.titleLabel];
        }
        if (self.subTitleLabel != nil) {
            [containerView addSubview:self.subTitleLabel];
        }
    }
    
    CGSize screenSize = [self countScreenSize];
    CGSize dialogSize = [self countDialogSize];
    
    // For the black background
    [self setFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    
    // This is the dialog's container; we attach the custom content and the
    // buttons to this one
    UIView *dialogContainer = [[UIView alloc]
                               initWithFrame:CGRectMake((screenSize.width - dialogSize.width) / 2,
                                                        (screenSize.height - dialogSize.height) / 2,
                                                        dialogSize.width, dialogSize.height)];
    
    // First, we style the dialog to match the iOS7 UIAlertView >>>
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = dialogContainer.bounds;
    gradient.colors = [NSArray
                       arrayWithObjects:
                       (id)[[UIColor whiteColor] CGColor],
                       (id)[[UIColor whiteColor] CGColor],
                       (id)[[UIColor whiteColor] CGColor],
                       //                       (id)[[UIColor colorWithRed:218.0/255.0
                       //                       green:218.0/255.0 blue:218.0/255.0
                       //                       alpha:1.0f] CGColor],
                       //                       (id)[[UIColor colorWithRed:233.0/255.0
                       //                       green:233.0/255.0 blue:233.0/255.0
                       //                       alpha:1.0f] CGColor],
                       //                       (id)[[UIColor colorWithRed:218.0/255.0
                       //                       green:218.0/255.0 blue:218.0/255.0
                       //                       alpha:1.0f] CGColor],
                       nil];
    
    CGFloat cornerRadius = kCustomIOSAlertViewCornerRadius;
    gradient.cornerRadius = cornerRadius;
    [dialogContainer.layer insertSublayer:gradient atIndex:0];
    
    dialogContainer.layer.cornerRadius = cornerRadius;
    dialogContainer.layer.borderColor = [[UIColor colorWithRed:198.0 / 255.0
                                                         green:198.0 / 255.0
                                                          blue:198.0 / 255.0
                                                         alpha:1.0f] CGColor];
    dialogContainer.layer.borderWidth = 1;
    dialogContainer.layer.shadowRadius = cornerRadius + 5;
    dialogContainer.layer.shadowOpacity = 0.1f;
    dialogContainer.layer.shadowOffset =
    CGSizeMake(0 - (cornerRadius + 5) / 2, 0 - (cornerRadius + 5) / 2);
    dialogContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    dialogContainer.layer.shadowPath =
    [UIBezierPath
     bezierPathWithRoundedRect:dialogContainer.bounds
     cornerRadius:dialogContainer.layer.cornerRadius].CGPath;
    
    // There is a line above the button
    // Custom for cardinfolink
    //    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0,
    //    dialogContainer.bounds.size.height - buttonHeight - buttonSpacerHeight,
    //    dialogContainer.bounds.size.width, buttonSpacerHeight)];
    //    lineView.backgroundColor = [UIColor colorWithRed:198.0/255.0
    //    green:198.0/255.0 blue:198.0/255.0 alpha:1.0f];
    //    [dialogContainer addSubview:lineView];
    // ^^^
    
    // Add the custom container if there is any
    [dialogContainer addSubview:containerView];
    
    // Add the buttons too
    [self addButtonsToView:dialogContainer];
    
    return dialogContainer;
}

// Helper function: add buttons to container
- (void)addButtonsToView:(UIView *)container {
    if (buttonTitles == NULL) {
        return;
    }
    
    buttons = [[NSMutableArray alloc] init];
    CGFloat buttonWidth =
    (container.bounds.size.width - kCustomIOSAlertViewDefaultLeading -
     kCustomIOSAlertViewDefaultTrailing -
     ([buttonTitles count] - 1) * kCustomIOSAlertViewDefaultButtonsSpace) /
    [buttonTitles count];
    
    CGFloat posX = 0;
    
    for (int i = 0; i < [buttonTitles count]; i++) {
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        if (i == 0) {
            posX = kCustomIOSAlertViewDefaultLeading;
        } else {
            posX = posX + i * buttonWidth + kCustomIOSAlertViewDefaultButtonsSpace;
        }
        
        [closeButton
         setFrame:CGRectMake(posX, container.bounds.size.height - buttonHeight +
                             kCustomIOSAlertViewDefaultButtonsTop,
                             buttonWidth,
                             kCustomIOSAlertViewDefaultButtonHeight)];
        
        [closeButton addTarget:self
                        action:@selector(customIOS7dialogButtonTouchUpInside:)
              forControlEvents:UIControlEventTouchUpInside];
        [closeButton setTag:i];
        
        [closeButton setTitle:[buttonTitles objectAtIndex:i]
                     forState:UIControlStateNormal];
        //        [closeButton setTitleColor:[UIColor colorWithRed:0.2f green:0.2f
        //        blue:0.2f alpha:0.5f] forState:UIControlStateHighlighted];
        [closeButton.titleLabel
         setFont:[UIFont systemFontOfSize:kCustomButtonFontSize]];
        [closeButton.layer setCornerRadius:kCustomIOSAlertViewCornerRadius];
        
        if (i == 0) {
            [closeButton setTitleColor:[UIColor blackColor]
                              forState:UIControlStateNormal];
            [closeButton setBackgroundColor:[UIColor colorWithHex:0xdadada]];
        } else {
            [closeButton setTitleColor:[UIColor whiteColor]
                              forState:UIControlStateNormal];
            [closeButton setBackgroundColor:[UIColor colorWithHex:0x228e9c]];
        }
        
        [container addSubview:closeButton];
        
        [buttons addObject:closeButton];
    }
}

// Helper function: count and return the dialog's size
- (CGSize)countDialogSize {
    CGFloat dialogWidth = containerView.frame.size.width;
    CGFloat dialogHeight =
    containerView.frame.size.height + buttonHeight; // + buttonSpacerHeight;
    
    return CGSizeMake(dialogWidth, dialogHeight);
}

// Helper function: count and return the screen's size
- (CGSize)countScreenSize {
    if (buttonTitles != NULL && [buttonTitles count] > 0) {
        buttonHeight = kCustomIOSAlertViewDefaultButtonHeight +
        kCustomIOSAlertViewDefaultButtonsTop +
        kCustomIOSAlertViewDefaultButtonsBottom;
        //        buttonSpacerHeight = kCustomIOSAlertViewDefaultButtonSpacerHeight;
    } else {
        buttonHeight = 0;
        //        buttonSpacerHeight = 0;
    }
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    // On iOS7, screen width and height doesn't automatically follow orientation
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        UIInterfaceOrientation interfaceOrientation =
        [[UIApplication sharedApplication] statusBarOrientation];
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            CGFloat tmp = screenWidth;
            screenWidth = screenHeight;
            screenHeight = tmp;
        }
    }
    
    return CGSizeMake(screenWidth, screenHeight);
}

#if (defined(__IPHONE_7_0))
// Add motion effects
- (void)applyMotionEffects {
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        return;
    }
    
    UIInterpolatingMotionEffect *horizontalEffect = [
                                                     [UIInterpolatingMotionEffect alloc]
                                                     initWithKeyPath:@"center.x"
                                                     type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalEffect.minimumRelativeValue = @(-kCustomIOS7MotionEffectExtent);
    horizontalEffect.maximumRelativeValue = @(kCustomIOS7MotionEffectExtent);
    
    UIInterpolatingMotionEffect *verticalEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.y"
     type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalEffect.minimumRelativeValue = @(-kCustomIOS7MotionEffectExtent);
    verticalEffect.maximumRelativeValue = @(kCustomIOS7MotionEffectExtent);
    
    UIMotionEffectGroup *motionEffectGroup = [[UIMotionEffectGroup alloc] init];
    motionEffectGroup.motionEffects = @[ horizontalEffect, verticalEffect ];
    
    [dialogView addMotionEffect:motionEffectGroup];
}
#endif

- (void)dealloc {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIDeviceOrientationDidChangeNotification
     object:nil];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIKeyboardWillHideNotification
     object:nil];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIKeyboardWillShowNotification
     object:nil];
}

// Rotation changed, on iOS7
- (void)changeOrientationForIOS7 {
    
    UIInterfaceOrientation interfaceOrientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    
    CGFloat startRotation =
    [[self valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
    CGAffineTransform rotation;
    
    switch (interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            rotation =
            CGAffineTransformMakeRotation(-startRotation + M_PI * 270.0 / 180.0);
            break;
            
        case UIInterfaceOrientationLandscapeRight:
            rotation =
            CGAffineTransformMakeRotation(-startRotation + M_PI * 90.0 / 180.0);
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            rotation =
            CGAffineTransformMakeRotation(-startRotation + M_PI * 180.0 / 180.0);
            break;
            
        default:
            rotation = CGAffineTransformMakeRotation(-startRotation + 0.0);
            break;
    }
    
    [UIView animateWithDuration:0.2f
                          delay:0.0
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         dialogView.transform = rotation;
                         
                     }
                     completion:nil];
}

// Rotation changed, on iOS8
- (void)changeOrientationForIOS8:(NSNotification *)notification {
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    [UIView animateWithDuration:0.2f
                          delay:0.0
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         CGSize dialogSize = [self countDialogSize];
                         CGSize keyboardSize =
                         [[[notification userInfo]
                           objectForKey:
                           UIKeyboardFrameBeginUserInfoKey] CGRectValue]
                         .size;
                         self.frame = CGRectMake(0, 0, screenWidth, screenHeight);
                         dialogView.frame =
                         CGRectMake((screenWidth - dialogSize.width) / 2,
                                    (screenHeight - keyboardSize.height -
                                     dialogSize.height) /
                                    2,
                                    dialogSize.width, dialogSize.height);
                     }
                     completion:nil];
}

// Handle device orientation changes
- (void)deviceOrientationDidChange:(NSNotification *)notification {
    // If dialog is attached to the parent view, it probably wants to handle the
    // orientation change itself
    if (parentView != NULL) {
        return;
    }
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        [self changeOrientationForIOS7];
    } else {
        [self changeOrientationForIOS8:notification];
    }
}

// Handle keyboard show/hide changes
- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize screenSize = [self countScreenSize];
    CGSize dialogSize = [self countDialogSize];
    CGSize keyboardSize =
    [[[notification userInfo]
      objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIInterfaceOrientation interfaceOrientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation) &&
        NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) {
        CGFloat tmp = keyboardSize.height;
        keyboardSize.height = keyboardSize.width;
        keyboardSize.width = tmp;
    }
    
    [UIView animateWithDuration:0.2f
                          delay:0.0
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         dialogView.frame =
                         CGRectMake((screenSize.width - dialogSize.width) / 2,
                                    (screenSize.height - keyboardSize.height -
                                     dialogSize.height) /
                                    2,
                                    dialogSize.width, dialogSize.height);
                     }
                     completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    CGSize screenSize = [self countScreenSize];
    CGSize dialogSize = [self countDialogSize];
    
    [UIView animateWithDuration:0.2f
                          delay:0.0
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         dialogView.frame =
                         CGRectMake((screenSize.width - dialogSize.width) / 2,
                                    (screenSize.height - dialogSize.height) / 2,
                                    dialogSize.width, dialogSize.height);
                     }
                     completion:nil];
}

@end
