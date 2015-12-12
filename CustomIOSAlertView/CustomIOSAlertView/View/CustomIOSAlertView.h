//
//  CustomIOSAlertView.h
//  CustomIOSAlertView
//
//  Created by Richard on 20/09/2013.
//  Copyright (c) 2013-2015 Wimagguc.
//
//  Lincesed under The MIT License (MIT)
//  http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>

@protocol CustomIOSAlertViewDelegate

- (void)customIOS7dialogButtonTouchUpInside:(id)alertView
                       clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface CustomIOSAlertView : UIView <CustomIOSAlertViewDelegate>

@property(nonatomic, retain)
UIView *parentView; // The parent view this 'dialog' is attached to
@property(nonatomic, retain) UIView *dialogView; // Dialog's container view
@property(nonatomic, retain) UIView *
containerView; // Container within the dialog (place your ui elements here)

@property(nonatomic, assign) id<CustomIOSAlertViewDelegate> delegate;
@property(nonatomic, retain) NSArray *buttonTitles;

// customize for cardinfolink
// NOTE: if title font size is adjusted according to length of title
@property(nonatomic, strong) NSString *title;

// NOTE: detail message will be in multiple lines if it's too long
@property(nonatomic, strong) NSString *subTitle;
@property(nonatomic, strong) UIImage *icon;

@property(nonatomic, assign) BOOL useMotionEffects;

// exposed for customize style
@property(nonatomic, strong, readonly) UILabel *titleLabel;
@property(nonatomic, strong, readonly) UILabel *subTitleLabel;
@property(nonatomic, strong, readonly) UIImageView *iconImageView;

@property(nonatomic, strong, readonly) NSArray *buttons;

@property(copy) void (^onButtonTouchUpInside)
(CustomIOSAlertView *alertView, int buttonIndex);

- (id)init;
- (instancetype)initWithTitle:(NSString *)mTitle
                         icon:(UIImage *)mIcon
                     subTitle:(NSString *)mSubTitle
                 buttonTitles:(NSArray *)mButtonTitles
        onButtonTouchUpInside:(void (^)(CustomIOSAlertView *alertView,
                                        int buttonIndex))mOnButtonTouchUpInside;

/*!
 DEPRECATED: Use the [CustomIOSAlertView init] method without passing a parent
 view.
 */
//- (id)initWithParentView:(UIView *)_parentView __attribute__((deprecated));

- (void)show;
- (void)close;

- (IBAction)customIOS7dialogButtonTouchUpInside:(id)sender;

- (void)setOnButtonTouchUpInside:
(void (^)(CustomIOSAlertView *alertView,
          int buttonIndex))onButtonTouchUpInside;

- (void)deviceOrientationDidChange:(NSNotification *)notification;
- (void)dealloc;

@end
